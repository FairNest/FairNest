import 'package:fairnestui/model/notification_model.dart';
import 'package:fairnestui/services/notification_service.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/RoommateVoting.dart';
import 'package:flutter/material.dart';

class Notificationpage extends StatefulWidget {
  const Notificationpage({super.key});

  static const TextStyle _titleStyle = TextStyle(
    fontFamily: 'Krub',
    fontWeight: FontWeight.w700,
    color: AppColors.darkPurple,
  );

  @override
  State<Notificationpage> createState() => _NotificationpageState();
}

class _NotificationpageState extends State<Notificationpage> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    final notifications = await NotificationService.getUnreadNotifications();

    if (mounted) {
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsReadAndRemove(int notificationId) async {
    // Mark as read on the server
    final success = await NotificationService.markAsRead(notificationId);

    if (success && mounted) {
      // Remove from the list immediately for smooth UX
      setState(() {
        _notifications.removeWhere(
          (notification) => notification.notificationId == notificationId,
        );
      });
    }
  }

  Future<void> _handleNotificationTap(NotificationModel notification) async {
    if (notification.isVoteNotification &&
        notification.voteNotificationRoomJoinRequestId != null) {
      // Navigate to voting page for vote notifications
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoommateVotingPage(
            roomJoinRequestId: notification.voteNotificationRoomJoinRequestId!,
          ),
        ),
      );
      // After returning from voting page, mark as read and refresh
      await _markAsReadAndRemove(notification.notificationId);
    } else {
      // For non-vote notifications, just mark as read
      await _markAsReadAndRemove(notification.notificationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: const Text('Notifications', style: Notificationpage._titleStyle),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.darkPurple,
              ),
            )
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No new notifications',
                        style: TextStyle(
                          fontFamily: 'Krub',
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Hint text
                    if (_notifications.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text(
                          'Tap a notification to mark as read',
                          style: TextStyle(
                            fontFamily: 'Krub',
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadNotifications,
                        color: AppColors.darkPurple,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _notifications.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            return NotificationCard(
                              notification: notification,
                              onTap: () => _handleNotificationTap(notification),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFDED6CB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and time
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    notification.isVoteNotification
                        ? 'New Roommate Request'
                        : 'Notification',
                    style: const TextStyle(
                      fontFamily: 'Krub',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5C5C5C),
                    ),
                  ),
                ),
                Text(
                  _getTimeAgo(notification.createdAt),
                  style: const TextStyle(
                    fontFamily: 'Krub',
                    fontSize: 12,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              notification.notificationMessage,
              style: const TextStyle(
                fontFamily: 'Krub',
                fontSize: 16,
                color: Color(0xFF8D8B8B),
                height: 1.4,
              ),
            ),

            // Additional message for room join notifications
            if (notification.isVoteNotification) ...[
              const SizedBox(height: 12),
              Text(
                'Click here to see the newcomer',
                style: TextStyle(
                  fontFamily: 'Krub',
                  fontSize: 14,
                  color: AppColors.darkPurple.withValues(alpha: .8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
