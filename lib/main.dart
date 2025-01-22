import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'activation_page.dart';
import 'firstinfo_page.dart';
import 'secondinfo_page.dart';
import 'thirdinfo_page.dart';
import 'feed_page.dart';  // FeedPage dosyasını import ediyoruz.

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      routes: {
        '/register': (context) => RegisterPage(),
        '/activation': (context) => ActivationPage(
          userId: (ModalRoute.of(context)?.settings.arguments as Map<String, String>?)?['userId'] ?? '',
          email: (ModalRoute.of(context)?.settings.arguments as Map<String, String>?)?['email'] ?? '',
          token: (ModalRoute.of(context)?.settings.arguments as Map<String, String>?)?['token'] ?? '',
        ),
        '/firstinfo': (context) => FirstInfoPage(
          userId: (ModalRoute.of(context)?.settings.arguments as Map<String, String>?)?['userId'] ?? '',
          token: (ModalRoute.of(context)?.settings.arguments as Map<String, String>?)?['token'] ?? '',
        ),
        '/secondinfo': (context) => SecondInfoPage(
          userId: (ModalRoute.of(context)?.settings.arguments as Map<String, String>?)?['userId'] ?? '',
          token: (ModalRoute.of(context)?.settings.arguments as Map<String, String>?)?['token'] ?? '',
          name: (ModalRoute.of(context)?.settings.arguments as Map<String, String>?)?['name'] ?? '',
          surname: (ModalRoute.of(context)?.settings.arguments as Map<String, String>?)?['surname'] ?? '',
        ),
        '/thirdinfo': (context) => ThirdInfoPage(
          userId: (ModalRoute.of(context)?.settings.arguments as Map<String, String>?)?['userId'] ?? '',
          token: (ModalRoute.of(context)?.settings.arguments as Map<String, String>?)?['token'] ?? '',
          birthday: (ModalRoute.of(context)?.settings.arguments as Map<String, String>?)?['birthday'] ?? '',
        ),
        '/feed': (context) => FeedPage(
          userId: (ModalRoute.of(context)?.settings.arguments as Map<String, String>?)?['userId'] ?? '',
          token: (ModalRoute.of(context)?.settings.arguments as Map<String, String>?)?['token'] ?? '',
        ),
      },
    );
  }
}
