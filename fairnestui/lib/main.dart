import 'package:fairnestui/auth/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fairnestui/pages/room_creation/room_creation_controller.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => RoomCreationController(),
      child: const MyApp(),
    ),
  );
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
      home: const WelcomePage(),
    );
  }
}
