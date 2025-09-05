import 'package:fairnestui/Notification/NotificationPage.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';

enum AppHeaderRightType {
  none,
  notification,
  profile,
}

class AppHeader extends StatelessWidget {
  final String title;
  final AppHeaderRightType rightType;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final String? profileImageAsset; // asset path for profile picture

  final bool showBack; // NEW
  final VoidCallback? onBackTap; // NEW

  const AppHeader({
    super.key,
    required this.title,
    this.rightType = AppHeaderRightType.none,
    this.onNotificationTap,
    this.onProfileTap,
    this.profileImageAsset,
    this.showBack = false, // default no back arrow
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      height: topPadding + 69,
      padding: EdgeInsets.only(top: topPadding, left: 16, right: 16),
      color: AppColors.primary,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Title (centered)
          Text(
            title,
            style: AppFonts.heading1.copyWith(
              color: const Color(0xFF645A80),
            ),
            textAlign: TextAlign.center,
          ),

          // Back arrow (if enabled)
          if (showBack)
            Positioned(
              left: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    size: 20, color: Colors.black87),
                onPressed: onBackTap ?? () => Navigator.of(context).maybePop(),
              ),
            ),

          // Right-side widget (notification, profile, or none)
          Positioned(
            right: 0,
            child: _buildRightWidget(context), // ← pass context in
          ),
        ],
      ),
    );
  }

  // Accept BuildContext so Navigator works here
  Widget _buildRightWidget(BuildContext context) {
    switch (rightType) {
      case AppHeaderRightType.notification:
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const Notificationpage()),
            );
          },
          child: Image.asset(
            'assets/images/Notification.png',
            width: 40,
            height: 40,
          ),
        );

      case AppHeaderRightType.profile:
        return GestureDetector(
          onTap: onProfileTap,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: Image.asset(
                profileImageAsset ?? 'assets/images/fairnest.png',
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );

      case AppHeaderRightType.none:
      default:
        return const SizedBox.shrink();
    }
  }
}
