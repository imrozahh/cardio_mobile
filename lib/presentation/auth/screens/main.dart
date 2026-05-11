import 'package:flutter/material.dart';

import 'login_page.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HeartCare',

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
      ),

      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) =>
            const ForgotPasswordPage(),
      },
    );
  }
}