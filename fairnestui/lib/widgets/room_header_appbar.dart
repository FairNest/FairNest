import 'package:fairnestui/Notification/NotificationPage.dart';
import 'package:fairnestui/pages/Settings/SettingPage.dart';
import 'package:fairnestui/pages/UserProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';

class RoomHeaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RoomHeaderAppBar({
    super.key,
    this.avatarImage =
        const AssetImage('assets/images/poke.png'), // 👈 default profile image
    this.avatarColor,
    required this.scoreText,
    required this.progress, // 0..1 (real value)
    this.onTapNotifications,
    this.onTapProfile,
    this.onTapSettings,
    this.height = 88,
  });

  final ImageProvider avatarImage; // ✅ no longer nullable, always has a value
  final Color? avatarColor; // ring/bg color behind avatar
  final String scoreText; // e.g., "78 Points"
  final double progress; // 0..1 (real value)
  final VoidCallback? onTapNotifications;
  final VoidCallback? onTapSettings;
  final VoidCallback? onTapProfile;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.background,
      toolbarHeight: height,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyProfilePage()),
                    );
                  }, // 🔗 fires your navigation
                  borderRadius: BorderRadius.circular(28),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        avatarColor ?? AppColors.textOrange.withOpacity(0.6),
                    backgroundImage: avatarImage,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Label + pill
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Roommate Score',
                      style: AppFonts.heading1.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPurple.withOpacity(0.9),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Use visualOffset to compensate the rounded-ends illusion
                    ScorePill(
                      scoreText: scoreText,
                      progress: progress,
                      visualOffset: 0.10, // ← tweak (e.g., 0.08–0.12) to taste
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Notificationpage()),
                  );
                },
                icon: const Icon(Icons.notifications_none_rounded),
                color: AppColors.textPurple.withOpacity(0.8),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()),
                  );
                },
                icon: const Icon(Icons.settings_rounded),
                color: AppColors.textPurple.withOpacity(0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScorePill extends StatelessWidget {
  const ScorePill({
    super.key,
    required this.scoreText,
    required this.progress, // real value 0..1
    this.visualOffset = 0.08, // max mid-range boost
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
  });

  final String scoreText;
  final double progress; // real value 0..1
  final double visualOffset;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    const double h = 28;
    final double pReal = progress.clamp(0.0, 1.0);

    // Fade the boost as we approach 1.0 (so 0.9 doesn't look like 1.0)
    final double scaledOffset = visualOffset * (1 - pReal);
    final double pVisual = (pReal + scaledOffset).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(h / 2),
      child: Stack(
        children: [
          // Track
          Container(
            height: h,
            color: const Color(0xFF3E3A4B),
          ),

          // Animate the FRACTION directly (keeps the “looks right” geometry)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: pVisual),
            duration: duration,
            curve: curve,
            builder: (context, animatedP, _) {
              return Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: animatedP, // ← animate the fraction
                  child: Container(
                    height: h,
                    color: const Color(0xFF645A80),
                  ),
                ),
              );
            },
          ),

          // Centered text
          SizedBox(
            height: h,
            child: Center(
              child: Text(
                scoreText,
                style: AppFonts.heading1.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFC7BDE2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
