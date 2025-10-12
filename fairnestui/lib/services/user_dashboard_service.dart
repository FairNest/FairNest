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

  /// Get user progress data (overall completion stats)
  Future<YourProgressInfo?> getUserProgress() async {
    try {
      if (kDebugMode) {
        print('📊 Fetching user progress...');
      }

      final response = await ApiClient.get('/user/progress');

      if (response.statusCode == 200) {
        final progress = YourProgressInfo.fromJson(
          response.data as Map<String, dynamic>,
        );

        if (kDebugMode) {
          print('✅ User progress fetched successfully');
          print(
              '   - Overall: ${progress.overallCompleted}/${progress.overallTotal}');
          print(
              '   - Progress: ${progress.progressPercentage.toStringAsFixed(1)}%');
        }

        return progress;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load user progress: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException fetching user progress: ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user progress: $e');
      }
      rethrow;
    }
  }

  /// Get today's unfinished tasks (chores + finances separated)
  Future<UserTasksSeparatedResponse?> getTasksToday() async {
    try {
      if (kDebugMode) {
        print('📋 Fetching today\'s tasks...');
      }

      final response = await ApiClient.get('/user/tasks/today');

      if (response.statusCode == 200) {
        final tasks = UserTasksSeparatedResponse.fromJson(
          response.data as Map<String, dynamic>,
        );

        if (kDebugMode) {
          print('✅ Today\'s tasks fetched successfully');
          print('   - Chores: ${tasks.chores.length}');
          print('   - Finances: ${tasks.finances.length}');
        }

        return tasks;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load today\'s tasks: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching today\'s tasks: $e');
      }
      rethrow;
    }
  }

  /// Get completed tasks from today (chores + finances separated)
  Future<UserTasksSeparatedResponse?> getTasksCompleted() async {
    try {
      if (kDebugMode) {
        print('✅ Fetching completed tasks...');
      }

      final response = await ApiClient.get('/user/tasks/completed');

      if (response.statusCode == 200) {
        final tasks = UserTasksSeparatedResponse.fromJson(
          response.data as Map<String, dynamic>,
        );

        if (kDebugMode) {
          print('✅ Completed tasks fetched successfully');
          print('   - Chores: ${tasks.chores.length}');
          print('   - Finances: ${tasks.finances.length}');
        }

        return tasks;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load completed tasks: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching completed tasks: $e');
      }
      rethrow;
    }
  }

  /// Get upcoming tasks (next 7 days, chores + finances separated)
  Future<UserTasksSeparatedResponse?> getTasksUpcoming() async {
    try {
      if (kDebugMode) {
        print('📅 Fetching upcoming tasks...');
      }

      final response = await ApiClient.get('/user/tasks/upcoming');

      if (response.statusCode == 200) {
        final tasks = UserTasksSeparatedResponse.fromJson(
          response.data as Map<String, dynamic>,
        );

        if (kDebugMode) {
          print('✅ Upcoming tasks fetched successfully');
          print('   - Chores: ${tasks.chores.length}');
          print('   - Finances: ${tasks.finances.length}');
        }

        return tasks;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load upcoming tasks: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching upcoming tasks: $e');
      }
      rethrow;
    }
  }

  /// Get complete user dashboard (all data in one call)
  Future<UserDashboardData?> getUserDashboard() async {
    try {
      if (kDebugMode) {
        print('🔄 Fetching complete user dashboard...');
      }

      final progressFuture = getUserProgress();
      final todayFuture = getTasksToday();
      final completedFuture = getTasksCompleted();
      final upcomingFuture = getTasksUpcoming();

      final results = await Future.wait([
        progressFuture,
        todayFuture,
        completedFuture,
        upcomingFuture,
      ]);

      final progress = results[0] as YourProgressInfo?;
      final today = results[1] as UserTasksSeparatedResponse?;
      final completed = results[2] as UserTasksSeparatedResponse?;
      final upcoming = results[3] as UserTasksSeparatedResponse?;

      if (progress == null ||
          today == null ||
          completed == null ||
          upcoming == null) {
        throw Exception('Failed to load dashboard data');
      }

      final dashboard = UserDashboardData(
        yourProgress: progress,
        taskSummary: TaskSummaryInfo(
          todayUnfinishedCount: today.chores.length + today.finances.length,
          completedCount: completed.chores.length + completed.finances.length,
          upcomingUnfinishedCount:
              upcoming.chores.length + upcoming.finances.length,
          todayUnfinishedTasks: today,
          completedTasks: completed,
          upcomingUnfinishedTasks: upcoming,
        ),
      );

      if (kDebugMode) {
        print('✅ Complete dashboard loaded successfully');
      }

      return dashboard;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching complete dashboard: $e');
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
}
