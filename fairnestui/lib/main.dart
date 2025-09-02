import 'package:fairnestui/TestCardPage.dart';
import 'package:fairnestui/auth/welcome_page.dart';
import 'package:fairnestui/pages/FindRoommate/GroupCheckPage.dart';
import 'package:fairnestui/pages/FindRoommate/GroupHomePage.dart';
import 'package:fairnestui/pages/FindRoommate/RequestJoinRoomPage.dart';
import 'package:fairnestui/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fairnestui/pages/room_creation/room_creation_controller.dart';
import 'package:fairnestui/pages/room_creation/create_room_flow.dart';

// all your other imports …

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
      home: const GroupHomePage(),
    );
  }
}
