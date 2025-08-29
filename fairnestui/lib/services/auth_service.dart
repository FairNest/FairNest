import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// Import this in your AuthService file
import 'package:fairnestui/services/storage_service.dart';

class AuthService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8652',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/Login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Validate response structure
        if (data.containsKey('user_id') &&
            data.containsKey('email') &&
            data.containsKey('token')) {
          return data;
        } else {
          throw Exception('Invalid response format from server');
        }
      } else {
        throw Exception(
            'Login failed with status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
            'Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server response timeout. Please try again.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Invalid email or password.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid request. Please check your input.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  static Future<bool> logout() async {
    try {
      // Clear stored token and user data
      await StorageService.clearToken();
      await StorageService.clearUserData();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
      return false;
    }
  }

  static Future<bool> isLoggedIn() async {
    final token = await StorageService.getToken();
    return token != null && token.isNotEmpty;
  }
}
