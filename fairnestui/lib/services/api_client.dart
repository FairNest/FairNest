import 'package:dio/dio.dart';
import 'package:fairnestui/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static late Dio _dio;
  static bool _isInitialized = false;

  /// Initialize the API client with base configuration
  static void initialize() {
    if (_isInitialized) return;

    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8652',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add token to headers for authenticated requests
          final token = await StorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print('📤 ${options.method} ${options.uri}');
            print('Headers: ${options.headers}');
            if (options.data != null) {
              print('Body: ${options.data}');
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('📥 ${response.statusCode} ${response.requestOptions.uri}');
            print('Response: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print(
                '❌ ${error.requestOptions.method} ${error.requestOptions.uri}');
            print('Error: ${error.message}');
            if (error.response != null) {
              print('Response: ${error.response?.data}');
            }
          }

          // Handle token expiration
          if (error.response?.statusCode == 401) {
            _handleTokenExpiration();
          }

          handler.next(error);
        },
      ),
    );

    _isInitialized = true;
  }

  /// Get the configured Dio instance
  static Dio get instance {
    if (!_isInitialized) {
      initialize();
    }
    return _dio;
  }

  /// Handle token expiration by clearing stored data
  static Future<void> _handleTokenExpiration() async {
    if (kDebugMode) {
      print('Token expired, clearing stored data');
    }
    await StorageService.clearAll();
    // You might want to navigate to login page here
    // NavigationService.navigateToLogin(); // If you have a navigation service
  }

  /// Make authenticated GET request
  static Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await instance.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Make authenticated POST request
  static Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await instance.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Make authenticated PUT request
  static Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await instance.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Make authenticated DELETE request
  static Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await instance.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
