import 'package:fairnestui/RoommateVoting.dart';
import 'package:fairnestui/TestCardPage.dart';
import 'package:fairnestui/auth/CompleteProfilePage.dart';
import 'package:fairnestui/auth/SignUpPage.dart';
import 'package:fairnestui/auth/login_page.dart';
import 'package:fairnestui/pages/Compatibility/CompatibilityPage.dart';
import 'package:fairnestui/pages/FindRoommate/GroupCheckPage.dart';
import 'package:fairnestui/pages/FindRoommate/GroupHomePage.dart';
import 'package:fairnestui/pages/FindRoommate/RequestJoinRoomPage.dart';
import 'package:fairnestui/pages/FindRoommate/StartRoommatePage.dart';
import 'package:fairnestui/pages/Home/RoomDashboardPage.dart';
import 'package:fairnestui/pages/House%20Rules/EditHouseRulePage.dart';
import 'package:fairnestui/pages/UserProfilePage.dart';
import 'package:fairnestui/pages/room_creation/CreateLivingSetup.dart';
import 'package:fairnestui/pages/room_creation/CreateRoomDetails.dart';
import 'package:fairnestui/auth/LifestyleQuizPage.dart';
import 'package:fairnestui/pages/room_creation/GenerateInviteCode.dart';
import 'package:fairnestui/pages/room_creation/RoommateAgreement.dart';
import 'package:fairnestui/shell/app_shell.dart';
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
      home: const RoomDashboardPage(),
    );
  }
}
