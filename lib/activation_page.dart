import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'firstinfo_page.dart';

class ActivationPage extends StatelessWidget {
  final String userId;
  final String email;
  final String token;

  ActivationPage({required this.userId, required this.email, required this.token});

  Future<void> _resendActivation(BuildContext context) async {
    final String apiUrl = 'https://cizimmedya.com/chat/api/login/activation_resend.php';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Aktivasyon kodu gönderildi.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Hata oluştu')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sunucu hatası: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veriler yüklenirken hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 80,
              color: Colors.black54,
            ),
            SizedBox(height: 20),
            Text(
              'Son bir adım kaldı',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Hesabınızı aktif hale getirmek için $email adresine e-posta gönderdik. Lütfen e-posta hesabınızı kontrol edin.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _resendActivation(context),
              child: Text('Tekrar Gönder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Sayfayı yenile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                print("TOKENTOKENonpressed:"+token);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FirstInfoPage(
                      userId: userId,
                      token: token,
                    ),
                  ),
                );
              },
              child: Text('MANUEL AKTİVASYON YAP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Yardıma ihtiyacınız olursa istediğiniz zaman bize yazabilirsiniz.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
