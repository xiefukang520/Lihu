import 'package:flutter/material.dart';

import 'pages/home_page.dart';
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
        // 方案 A：全局默认中文/英文字体。
        fontFamily: 'PingFang SC',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6E8DF5)),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) => EmailLoginPage(
          onSkipLogin: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          },
        ),
      ),
    );
  }
}
