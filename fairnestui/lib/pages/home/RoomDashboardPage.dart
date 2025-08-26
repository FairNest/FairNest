import 'package:fairnestui/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/widgets/room_header_appbar.dart';

class RoomDashboardPage extends StatefulWidget {
  const RoomDashboardPage({super.key});

  @override
  State<RoomDashboardPage> createState() => _RoomDashboardPageState();
}

class _RoomDashboardPageState extends State<RoomDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: RoomHeaderAppBar(
          avatarImage: const AssetImage('assets/images/sample_face.jpg'),
          scoreText: '78 Points',
          progress: 0.78,
          onTapNotifications: () {},
          onTapSettings: () {},
        ),
        body: Row(
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Container(
                    child: Text(
                      "Welcome Back, George!",
                      style: AppFonts.heading1.copyWith(
                        color: AppColors.textPurple,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
