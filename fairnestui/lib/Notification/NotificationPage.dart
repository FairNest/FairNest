import 'package:fairnestui/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Notificationpage extends StatefulWidget {
  const Notificationpage({super.key});

  // Make this a compile-time constant so it can be used in const Text(...)
  static const TextStyle _titleStyle = TextStyle(
    fontFamily: 'Krub',
    fontWeight: FontWeight.w700,
    color: AppColors.darkPurple,
  );

  @override
  State<Notificationpage> createState() => _NotificationpageState();
}

class _NotificationpageState extends State<Notificationpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        // Now both the Text and the style are const-friendly
        title: const Text('Notifications', style: Notificationpage._titleStyle),
        elevation: 0,
      ),
      body: const SizedBox.shrink(),
    );
  }
}
