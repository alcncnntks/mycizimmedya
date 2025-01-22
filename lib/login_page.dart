import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register_page.dart';
import 'firstinfo_page.dart';
import 'feed_page.dart'; // FeedPage dosyasını import ediyoruz

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  Map<String, dynamic> _loginTexts = {};
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchLoginTexts();
  }

  Future<void> _fetchLoginTexts() async {
    try {
      final response = await http.post(
        Uri.parse('https://cizimmedya.com/chat/api/general/texts.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded', 'Accept': '*/*'},
        body: {'lang': 'tr'},
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['success'] == true && responseBody['result'] != null) {
          setState(() {
            _loginTexts = responseBody['result']['login'];
            _isLoading = false;
            _hasError = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = responseBody['message'] ?? 'Bilinmeyen bir hata oluştu';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Sunucu hatası: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Veriler yüklenirken hata oluştu: $e';
      });
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final String emailUsername = _usernameController.text;
    final String password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('https://cizimmedya.com/chat/api/login/index.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'lang': 'tr',
          'email_username': emailUsername,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Giriş başarılı!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FeedPage(
                userId: responseBody['result']['user_id'],
                token: responseBody['result']['token'],
              ),
            ),
          );
        } else {
          setState(() {
            _hasError = true;
            _errorMessage = responseBody['message'] ?? 'Bilinmeyen bir hata oluştu';
          });
          _showErrorDialog(_errorMessage);
        }
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Sunucu hatası: ${response.statusCode}';
        });
        _showErrorDialog(_errorMessage);
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Giriş sırasında hata oluştu: $e';
      });
      _showErrorDialog(_errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hata'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(child: Text('Veriler yüklenirken hata oluştu: $_errorMessage'))
          : SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 50), // Üstten biraz boşluk ekleyelim
                Text(
                  _loginTexts['title'] ?? 'Hoş geldiniz!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  _loginTexts['subtitle'] ?? 'E-posta adresinizi ve şifrenizi girin',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFE8E8ED),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: _loginTexts['email_username'] ?? 'E-posta veya kullanıcı adı',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    style: TextStyle(fontSize: 18), // Yazı boyutu büyütüldü
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFE8E8ED),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: _loginTexts['password'] ?? 'Şifre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    obscureText: !_passwordVisible,
                    style: TextStyle(fontSize: 18), // Yazı boyutu büyütüldü
                  ),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _login,
                  child: Text(_loginTexts['button'] ?? 'Giriş Yap'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFFFF4088), // Renk değiştirildi
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                if (_hasError)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Image.asset('assets/google_logo.png', width: 24, height: 24),
                  label: Text(_loginTexts['google_button'] ?? 'Google ile bağlan', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.grey.shade400), // Çerçeve şeffaflığı artırıldı
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Image.asset('assets/facebook_logo.png', width: 24, height: 24),
                  label: Text(_loginTexts['facebook_button'] ?? 'Facebook ile bağlan', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.grey.shade400), // Çerçeve şeffaflığı artırıldı
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  icon: Icon(Icons.email),
                  label: Text(_loginTexts['email_button'] ?? 'E-posta adresi ile kayıt ol', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.grey.shade400), // Çerçeve şeffaflığı artırıldı
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {},
                  child: Text(_loginTexts['forgot_password'] ?? 'Şifrenizi mi unuttunuz?'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  _loginTexts['privacy_policy_text'] ?? 'Bu uygulamayı kullanarak, [Genel Kullanım Koşullarını], [Kişisel Verileri Koruma Kanununu] ve [Gizlilik Politikasını] kabul etmiş olursunuz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 16), // Alt kısmına da biraz boşluk ekleyelim
              ],
            ),
          ),
        ),
      ),
    );
  }
}
