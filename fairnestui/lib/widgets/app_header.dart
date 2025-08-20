import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onNotificationTap;

  const AppHeader({
    super.key,
    required this.title,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      height: topPadding + 69, // Shortened from 72 to 69
      padding: EdgeInsets.only(top: topPadding, left: 24, right: 24),
      color: AppColors.primary,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center title
          Text(
            title,
            style: AppFonts.heading1.copyWith(
              color: const Color(0xFF645A80),
            ),
            textAlign: TextAlign.center,
          ),

          // Tappable notification icon
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: onNotificationTap,
              child: Image.asset(
                'assets/images/Notification.png',
                width: 40,
                height: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
