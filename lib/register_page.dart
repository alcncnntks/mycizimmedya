import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'activation_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  Map<String, dynamic> _registerTexts = {};
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRegisterTexts();
  }

  Future<void> _fetchRegisterTexts() async {
    try {
      final response = await http.post(
        Uri.parse('https://cizimmedya.com/chat/api/general/texts.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'lang': 'tr'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['success'] == true && responseBody['result'] != null) {
          setState(() {
            _registerTexts = responseBody['result']['register'];
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
      print('Hata oluştu: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Veriler yüklenirken hata oluştu: $e';
      });
    }
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final String username = _usernameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('https://cizimmedya.com/chat/api/login/register.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'lang': 'tr',
          'username': username,
          'email': email,
          'password': password,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Cevabın JSON formatında olduğunu kontrol et
        try {
          final responseBody = json.decode(response.body);

          if (responseBody['success'] == true) {
            final result = responseBody['result'];
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ActivationPage(
                  userId: result['user_id'],
                  email: result['email'],
                  token: result['token'],
                ),
              ),
            );
          } else {
            _showErrorDialog(responseBody['message'] ?? 'Bilinmeyen bir hata oluştu');
          }
        } catch (e) {
          print("TOKENTOKEN: CATCH: "+e.toString());
          // JSON formatında değilse, doğrudan activation sayfasına yönlendir
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ActivationPage(
                userId: '', // userId ve email'i doğru bir şekilde sağlayın
                email: '',
                token: '',
              ),
            ),
          );
        }
      } else {
        _showErrorDialog('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('Hata oluştu: $e');
      _showErrorDialog('Kayıt sırasında hata oluştu: $e');
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
                  _registerTexts['title'] ?? 'E-posta ile kayıt ol',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  _registerTexts['subtitle'] ?? 'Lütfen bilgilerinizi doğru ve eksiksiz girin',
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
                      hintText: _registerTexts['username'] ?? 'Kullanıcı adı',
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
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: _registerTexts['email'] ?? 'E-posta adresi',
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
                      hintText: _registerTexts['password'] ?? 'Şifre',
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
                  onPressed: _register,
                  child: Text(_registerTexts['button'] ?? 'Kayıt Ol'),
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
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(_registerTexts['membership'] ?? 'Üyeliğin var mı? Giriş yap'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  _registerTexts['privacy_policy_text'] ?? 'Kayıt olarak, [Genel Kullanım Koşullarını], [Kişisel Verileri Koruma Kanununu] ve [Gizlilik Politikasını] kabul etmiş olursunuz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.white),
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
