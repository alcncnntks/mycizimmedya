import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'secondinfo_page.dart';

class FirstInfoPage extends StatefulWidget {
  final String userId;
  final String token;

  FirstInfoPage({required this.userId, required this.token});

  @override
  _FirstInfoPageState createState() => _FirstInfoPageState();
}

class _FirstInfoPageState extends State<FirstInfoPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
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

  void _submitNameSurname() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('İsim ve soyisim başarıyla kaydedildi!')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SecondInfoPage(
          userId: widget.userId,
          token: widget.token,
          name: _nameController.text,
          surname: _surnameController.text
        ),
      ),
    );
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
                  _infoTexts['step_1_title'] ?? 'İlk olarak, adınız ve soyadınız nedir?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFE8E8ED),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: _infoTexts['name'] ?? 'İsim',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFE8E8ED),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _surnameController,
                    decoration: InputDecoration(
                      hintText: _infoTexts['surname'] ?? 'Soyisim',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitNameSurname,
                  child: Text('Sonraki'),
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
