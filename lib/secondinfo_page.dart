import 'package:flutter/material.dart';
import 'thirdinfo_page.dart';  // ThirdInfoPage dosyasını import ediyoruz.

class SecondInfoPage extends StatefulWidget {
  final String userId;
  final String token;
  final String name;
  final String surname;


  SecondInfoPage({required this.userId, required this.token, required this.name, required this.surname});

  @override
  _SecondInfoPageState createState() => _SecondInfoPageState();
}

class _SecondInfoPageState extends State<SecondInfoPage> {
  String? _selectedDay;
  String? _selectedMonth;
  String? _selectedYear;
  Map<String, dynamic> _infoTexts = {
    'page_title': 'Biraz Bilgi',
    'step_2_title': 'Tanıştığımıza memnun olduk, peki doğum tarihiniz nedir?'
  };
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
//testtggy
  void _submitBirthday() {
    if (_selectedDay != null && _selectedMonth != null && _selectedYear != null) {
      String birthday = '$_selectedDay/$_selectedMonth/$_selectedYear';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ThirdInfoPage(
            userId: widget.userId,
            token: widget.token,
            birthday: birthday, // Birthday information is passed to the next page
          ),
        ),
      );
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = 'Lütfen doğum tarihi bilgilerini tam olarak seçin.';
      });
    }
  }

  List<String> _generateDays() {
    return List<String>.generate(31, (index) => (index + 1).toString());
  }

  List<String> _generateMonths() {
    return List<String>.generate(12, (index) => (index + 1).toString());
  }

  List<String> _generateYears() {
    int currentYear = DateTime.now().year;
    return List<String>.generate(100, (index) => (currentYear - index).toString());
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
                  (_infoTexts['step_2_title'] as String).replaceFirst("[name]", widget.name) ?? 'Doğum tarihiniz nedir?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFE8E8ED),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      DropdownButton<String>(
                        hint: Text('Gün'),
                        value: _selectedDay,
                        items: _generateDays().map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedDay = newValue;
                          });
                        },
                      ),
                      DropdownButton<String>(
                        hint: Text('Ay'),
                        value: _selectedMonth,
                        items: _generateMonths().map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedMonth = newValue;
                          });
                        },
                      ),
                      DropdownButton<String>(
                        hint: Text('Yıl'),
                        value: _selectedYear,
                        items: _generateYears().map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedYear = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitBirthday,
                  child: Text('Sonraki'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
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
