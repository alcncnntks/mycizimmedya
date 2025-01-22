import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'feed_page.dart';

class ThirdInfoPage extends StatefulWidget {
  final String userId;
  final String token;
  final String birthday;

  ThirdInfoPage({required this.userId, required this.token, required this.birthday});

  @override
  _ThirdInfoPageState createState() => _ThirdInfoPageState();
}

class _ThirdInfoPageState extends State<ThirdInfoPage> {
  Map<String, dynamic> _infoTexts = {};
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchInfoTexts();
  }

  Future<void> _fetchInfoTexts() async {
    try {
      final response = await http.post(
        Uri.parse('https://cizimmedya.com/chat/api/general/texts.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'lang': 'tr'},
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['success'] == true && responseBody['result'] != null) {
          setState(() {
            _infoTexts = responseBody['result']['info'];
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

  Future<void> _submitGender(String gender) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http.post(
        Uri.parse('https://cizimmedya.com/chat/api/info/index.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'lang': 'tr',
          'user_id': widget.userId,
          'token': widget.token,
          'gender': gender,
          'birthday': widget.birthday,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bilgileriniz başarıyla kaydedildi!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FeedPage(
                userId: widget.userId,
                token: widget.token,
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
        _errorMessage = 'Bilgiler gönderilirken hata oluştu: $e';
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
      appBar: AppBar(
        title: Text(_infoTexts['page_title'] ?? 'Biraz Bilgi'),
        centerTitle: true,
      ),
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
                SizedBox(height: 50),
                Text(
                  _infoTexts['step_3_title'] ?? 'Harika, son olarak kendinizi nasıl tanımlarsınız?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _submitGender('male'),
                  child: Text(_infoTexts['male'] ?? 'Erkek'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFFFF4088),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _submitGender('female'),
                  child: Text(_infoTexts['female'] ?? 'Kadın'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFFFF4088),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _submitGender('other'),
                  child: Text(_infoTexts['dont_want'] ?? 'Belirtmek istemiyorum'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFFFF4088),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
