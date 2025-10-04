import 'package:fairnestui/Notification/NotificationPage.dart';
import 'package:fairnestui/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';

enum AppHeaderRightType {
  none,
  notification,
  profile,
}

class AppHeader extends StatefulWidget {
  final String title;
  final AppHeaderRightType rightType;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final String? profileImageAsset;
  final bool showBack;
  final VoidCallback? onBackTap;

  const AppHeader({
    super.key,
    required this.title,
    this.rightType = AppHeaderRightType.none,
    this.onNotificationTap,
    this.onProfileTap,
    this.profileImageAsset,
    this.showBack = false,
    this.onBackTap,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.rightType == AppHeaderRightType.notification) {
      _loadUnreadCount();
    }
  }

  @override
  void didUpdateWidget(AppHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if rightType changed to notification
    if (widget.rightType == AppHeaderRightType.notification &&
        oldWidget.rightType != AppHeaderRightType.notification) {
      _loadUnreadCount();
    }
  }

  Future<void> _loadUnreadCount() async {
    final count = await NotificationService.getUnreadNotificationCount();
    if (mounted) {
      setState(() {
        _unreadCount = count;
      });
    }
  }

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
            widget.title,
            style: AppFonts.heading1.copyWith(
              color: const Color(0xFF645A80),
            ),
            textAlign: TextAlign.center,
          ),

          // Back arrow (if enabled)
          if (widget.showBack)
            Positioned(
              left: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    size: 20, color: Colors.black87),
                onPressed:
                    widget.onBackTap ?? () => Navigator.of(context).maybePop(),
              ),
            ),

          // Right-side widget (notification, profile, or none)
          Positioned(
            right: 0,
            child: _buildRightWidget(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRightWidget(BuildContext context) {
    switch (widget.rightType) {
      case AppHeaderRightType.notification:
        return Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const Notificationpage()),
                );
                // Refresh count when returning from notification page
                _loadUnreadCount();
              },
              child: Image.asset(
                'assets/images/Notification.png',
                width: 40,
                height: 40,
              ),
            ),
            if (_unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
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
        );

      case AppHeaderRightType.profile:
        return GestureDetector(
          onTap: widget.onProfileTap,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: Image.asset(
                widget.profileImageAsset ?? 'assets/images/fairnest.png',
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
