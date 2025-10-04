// notification_service.dart
import 'package:fairnestui/model/notification_model.dart';
import 'package:fairnestui/services/api_client.dart';
import 'package:fairnestui/services/user_service.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  /// Get count of unread notifications for current user
  static Future<int> getUnreadNotificationCount() async {
    try {
      final userId = await UserService.getUserIdFromToken();
      if (userId == null) {
        if (kDebugMode) {
          print('❌ No user ID found in token');
        }
        return 0;
      }

      final response = await ApiClient.get(
        '/GetCountOfUnreadNotificationByUserId/$userId',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['count_of_unread_notification'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching unread notification count: $e');
      }
      return 0;
    }
  }

  /// Fetch the 3 most recent notifications for current user
  static Future<List<NotificationModel>> getThreeRecentNotifications() async {
    try {
      final userId = await UserService.getUserIdFromToken();
      if (userId == null) {
        if (kDebugMode) {
          print('❌ No user ID found in token');
        }
        return [];
      }

      final response = await ApiClient.get(
        '/FetchThreeNotificationByUserId/$userId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) =>
                NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching three recent notifications: $e');
      }
      return [];
    }
  }

  /// Fetch all unread notifications for current user
  static Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final userId = await UserService.getUserIdFromToken();
      if (userId == null) {
        if (kDebugMode) {
          print('❌ No user ID found in token');
        }
        return [];
      }

      final response = await ApiClient.get(
        '/FetchAllUnreadNotificationByUserId/$userId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) =>
                NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching unread notifications: $e');
      }
      return [];
    }
  }

  /// Mark notification as read
  static Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await ApiClient.put(
        '/PutMarkAsReadByNotificationId/$notificationId',
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Notification $notificationId marked as read');
        }
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error marking notification as read: $e');
      }
      return false;
    }
  }
}
