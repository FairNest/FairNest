// lib/services/dashboard_service.dart

import 'package:fairnestui/model/dashboard_model.dart';
import 'package:fairnestui/services/api_client.dart';
import 'package:fairnestui/services/user_profile_service.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class DashboardService {
  static DashboardService? _instance;

  DashboardService._internal();

  static DashboardService get instance {
    _instance ??= DashboardService._internal();
    return _instance!;
  }

  /// Get room dashboard data for the current user's room
  Future<RoomDashboardData?> getRoomDashboard({int? roomId}) async {
    try {
      // Get room ID from user profile if not provided
      final targetRoomId = roomId ?? await _getCurrentUserRoomId();

      if (targetRoomId == null) {
        if (kDebugMode) {
          print('❌ No room ID found for current user');
        }
        return null;
      }

      if (kDebugMode) {
        print('📊 Fetching dashboard data for room: $targetRoomId');
      }

      final response = await ApiClient.get('/rooms/$targetRoomId/dashboard');

      if (response.statusCode == 200) {
        final dashboardData = RoomDashboardData.fromJson(
          response.data as Map<String, dynamic>,
        );

        if (kDebugMode) {
          print('✅ Dashboard data fetched successfully');
          print(
              '   - Room Compatibility: ${dashboardData.todayRoomStatus.roomCompatibility.score}');
          print(
              '   - Chores: ${dashboardData.todayRoomStatus.choresProgress.completedTasks}/${dashboardData.todayRoomStatus.choresProgress.totalTasks}');
          print(
              '   - Finances: ${dashboardData.todayRoomStatus.financesProgress.completedFinances}/${dashboardData.todayRoomStatus.financesProgress.totalFinances}');
          print('   - Roommates: ${dashboardData.roommateOverview.length}');
        }

        return dashboardData;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load dashboard data: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException fetching dashboard: ${e.message}');
        print('   Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching dashboard: $e');
      }
      rethrow;
    }
  }

  /// Get current user's room ID from profile
  Future<int?> _getCurrentUserRoomId() async {
    try {
      // Try cache first
      final cachedProfile =
          await UserProfileService.instance.getCachedProfile();
      if (cachedProfile != null && cachedProfile.roomId != 0) {
        return cachedProfile.roomId;
      }

      // Fetch from network
      final profile = await UserProfileService.instance.getCurrentUserProfile();
      if (profile != null && profile.roomId != 0) {
        return profile.roomId;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting room ID from profile: $e');
      }
      return null;
    }
  }

  /// Refresh dashboard data
  Future<RoomDashboardData?> refreshDashboard({int? roomId}) async {
    if (kDebugMode) {
      print('🔄 Refreshing dashboard data...');
    }
    return await getRoomDashboard(roomId: roomId);
  }
}
