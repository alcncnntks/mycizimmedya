import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'firstinfo_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

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

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['success'] == true) {
          final result = responseBody['result'];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FirstInfoPage(
                userId: result['user_id'],
                token: result['token'],
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
        _errorMessage = 'Kayıt sırasında hata oluştu: $e';
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
          : SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 50),
                      Text(
                        'E-posta ile kayıt ol',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Lütfen bilgilerinizi doğru ve eksiksiz girin',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 32),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Kullanıcı adı',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'E-posta adresi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          hintText: 'Şifre',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
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
                      ),
                      SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _register,
                        child: Text('Kayıt Ol'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.pink, // Renk değiştirildi
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
                        child: Text('Üyeliğin var mı? Giriş yap'),
                        style: TextButton.styleFrom(
                          primary: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Kayıt olarak, [Genel Kullanım Koşullarını], [Kişisel Verileri Koruma Kanununu] ve [Gizlilik Politikasını] kabul etmiş olursunuz.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
