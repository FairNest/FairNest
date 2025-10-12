// lib/services/user_dashboard_service.dart

import 'package:fairnestui/model/user_dashboard_model.dart';
import 'package:fairnestui/services/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class UserDashboardService {
  static UserDashboardService? _instance;

  UserDashboardService._internal();

  static UserDashboardService get instance {
    _instance ??= UserDashboardService._internal();
    return _instance!;
  }

  /// Get user dashboard data for the current authenticated user
  Future<UserDashboardData?> getUserDashboard() async {
    try {
      if (kDebugMode) {
        print('📊 Fetching user dashboard data...');
      }

      final response = await ApiClient.get('/user/dashboard');

      if (response.statusCode == 200) {
        final dashboardData = UserDashboardData.fromJson(
          response.data as Map<String, dynamic>,
        );

        if (kDebugMode) {
          print('✅ User dashboard data fetched successfully');
          print(
              '   - Overall Progress: ${dashboardData.yourProgress.overallCompleted}/${dashboardData.yourProgress.overallTotal}');
          print(
              '   - Progress: ${dashboardData.yourProgress.progressPercentage.toStringAsFixed(1)}%');
          print(
              '   - Today Unfinished: ${dashboardData.taskSummary.todayUnfinishedCount}');
          print('   - Completed: ${dashboardData.taskSummary.completedCount}');
          print(
              '   - Upcoming: ${dashboardData.taskSummary.upcomingUnfinishedCount}');
        }

        return dashboardData;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load user dashboard: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException fetching user dashboard: ${e.message}');
        print('   Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user dashboard: $e');
      }
      rethrow;
    }
  }

  /// Refresh user dashboard data
  Future<UserDashboardData?> refreshUserDashboard() async {
    if (kDebugMode) {
      print('🔄 Refreshing user dashboard data...');
    }
    return await getUserDashboard();
  }

  /// Get specific item details by type and ID
  Future<UserDashboardItem?> getItemDetails({
    required String itemType,
    required int itemId,
  }) async {
    try {
      final dashboard = await getUserDashboard();
      if (dashboard == null) return null;

      // Search in all item lists
      final allItems = [
        ...dashboard.taskSummary.todayUnfinishedItems,
        ...dashboard.taskSummary.completedItems,
        ...dashboard.taskSummary.upcomingUnfinishedItems,
      ];

      return allItems.firstWhere(
        (item) => item.itemType == itemType && item.itemId == itemId,
        orElse: () => throw Exception('Item not found'),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting item details: $e');
      }
      return null;
    }
  }
}
