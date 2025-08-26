import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';

class RoomHeaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RoomHeaderAppBar({
    super.key,
    this.avatarImage,
    this.avatarColor,
    required this.scoreText,
    required this.progress, // 0..1
    this.onTapNotifications,
    this.onTapSettings,
    this.height = 88,
  });

  final ImageProvider? avatarImage; // AssetImage / NetworkImage
  final Color? avatarColor; // ring/bg color behind avatar
  final String scoreText; // e.g., "78 Points"
  final double progress; // 0..1
  final VoidCallback? onTapNotifications;
  final VoidCallback? onTapSettings;
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
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    avatarColor ?? AppColors.textOrange.withOpacity(0.6),
                backgroundImage: avatarImage,
                child: avatarImage == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
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
                    ScorePill(scoreText: scoreText, progress: progress),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: onTapNotifications,
                icon: const Icon(Icons.notifications_none_rounded),
                color: AppColors.textPurple.withOpacity(0.8),
              ),
              IconButton(
                onPressed: onTapSettings,
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
  const ScorePill({super.key, required this.scoreText, required this.progress});

  final String scoreText;
  final double progress; // 0..1

  @override
  Widget build(BuildContext context) {
    const double h = 28;
    return LayoutBuilder(
      builder: (context, c) {
        final total = c.maxWidth;
        final clamped = progress.clamp(0.0, 1.0);
        return Stack(
          children: [
            Container(
              height: h,
              decoration: BoxDecoration(
                color: const Color(0xFF3E3A4B),
                borderRadius: BorderRadius.circular(h / 2),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(h / 2),
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: clamped,
                child: Container(
                  height: h,
                  width: total * clamped,
                  color: const Color(0xFF7A6B95),
                ),
              ),
            ),
            SizedBox(
              height: h,
              child: Center(
                child: Text(
                  scoreText,
                  style: AppFonts.heading1.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
