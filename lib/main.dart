import 'package:flutter/material.dart';
import 'languagetranslation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Language Translation Application',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: const LanguagetraslationPage(),
        bottomNavigationBar: Container(
          color: const Color(0xFF333333),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: const Text(
            '©2025 All Rights Reserved. Anurag Bhadra®',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
