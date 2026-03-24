import 'package:flutter/material.dart';

import 'pages/login/email_login_page.dart';

void main() {
  runApp(const TestProjectApp());
}

class TestProjectApp extends StatelessWidget {
  const TestProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Email Login Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6E8DF5)),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const EmailLoginPage(),
    );
  }
}
