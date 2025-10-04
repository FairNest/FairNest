// models/notification_model.dart
class NotificationModel {
  final int notificationId;
  final int senderId;
  final int receiverId;
  final String notificationMessage;
  final bool isRead;
  final int? voteNotificationRoomJoinRequestId;
  final DateTime createdAt;

  NotificationModel({
    required this.notificationId,
    required this.senderId,
    required this.receiverId,
    required this.notificationMessage,
    required this.isRead,
    this.voteNotificationRoomJoinRequestId,
    required this.createdAt,
  });

  // Check if this is a vote notification based on whether the ID exists
  bool get isVoteNotification => voteNotificationRoomJoinRequestId != null;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id'] as int,
      senderId: json['sender_id'] as int,
      receiverId: json['receiver_id'] as int,
      notificationMessage: json['notification_message'] as String,
      isRead: json['is_read'] as bool,
      voteNotificationRoomJoinRequestId:
          json['vote_notification_room_join_request_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
