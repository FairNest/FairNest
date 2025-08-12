import 'package:fairnestui/pages/LifestyleQuizPage.dart';
import 'package:fairnestui/pages/groupcheckpage.dart';
import 'package:flutter/material.dart';
import 'auth/welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FairNest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LifestyleQuizPage(),
    );
  }
}
