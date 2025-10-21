// room_header_app_bar.dart
import 'package:fairnestui/Notification/NotificationPage.dart';
import 'package:fairnestui/pages/Settings/SettingPage.dart';
import 'package:fairnestui/pages/UserProfilePage.dart';
import 'package:fairnestui/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';

class RoomHeaderAppBar extends StatefulWidget {
  const RoomHeaderAppBar({
    super.key,
    this.avatarImage = const AssetImage('assets/images/poke.png'),
    this.avatarColor,
    required this.scoreText,
    required this.progress,
    this.onTapNotifications,
    this.onTapProfile,
    this.onTapSettings,
    this.height = 88,
  });

  final ImageProvider avatarImage;
  final Color? avatarColor;
  final String scoreText;
  final double progress;
  final VoidCallback? onTapNotifications;
  final VoidCallback? onTapSettings;
  final VoidCallback? onTapProfile;
  final double height;

  @override
  State<RoomHeaderAppBar> createState() => _RoomHeaderAppBarState();
}

class _RoomHeaderAppBarState extends State<RoomHeaderAppBar> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await NotificationService.getUnreadNotificationCount();
    if (mounted) {
      setState(() {
        _unreadCount = count;
      });
    }
  }

  Size get preferredSize => Size.fromHeight(widget.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.background,
      toolbarHeight: widget.height,
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
                  },
                  borderRadius: BorderRadius.circular(28),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: widget.avatarColor ??
                        AppColors.textOrange.withValues(alpha: .6),
                    backgroundImage: widget.avatarImage,
                  ),
                ),
              ),
              const SizedBox(width: 12),

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
                        color: AppColors.textPurple.withValues(alpha: .9),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ScorePill(
                      scoreText: widget.scoreText,
                      progress: widget.progress,
                      visualOffset: 0.10,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Notification button with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Notificationpage()),
                      );
                      // Refresh count when returning from notification page
                      _loadUnreadCount();
                    },
                    icon: const Icon(Icons.notifications_none_rounded),
                    color: AppColors.textPurple.withValues(alpha: .8),
                  ),
                  if (_unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            _unreadCount > 99 ? '99+' : '$_unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
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
                color: AppColors.textPurple.withValues(alpha: .8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ScorePill remains the same...
class ScorePill extends StatelessWidget {
  const ScorePill({
    super.key,
    required this.scoreText,
    required this.progress,
    this.visualOffset = 0.08,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
  });

  final String scoreText;
  final double progress;
  final double visualOffset;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    const double h = 28;
    final double pReal = progress.clamp(0.0, 1.0);
    final double scaledOffset = visualOffset * (1 - pReal);
    final double pVisual = (pReal + scaledOffset).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(h / 2),
      child: Stack(
        children: [
          Container(
            height: h,
            color: const Color(0xFF3E3A4B),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: pVisual),
            duration: duration,
            curve: curve,
            builder: (context, animatedP, _) {
              return Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: animatedP,
                  child: Container(
                    height: h,
                    color: const Color(0xFF645A80),
                  ),
                ),
              );
            },
          ),
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
