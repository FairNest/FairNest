import 'package:dio/dio.dart';
import 'package:fairnestui/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static late Dio _dio;
  static bool _isInitialized = false;

  /// Initialize the API client with base configuration
  static void initialize() {
    if (_isInitialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:8652', // Android emulator -> host machine
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          // Do NOT set Content-Type globally; let per-request logic decide.
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach bearer token if present
          final token = await StorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Auto content-type selection if caller didn't set one
          _applySmartContentType(options);

          if (kDebugMode) {
            _prettyLogRequest(options);
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            _prettyLogResponse(response);
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            _prettyLogError(error);
          }

          // Token expiry handling
          if (error.response?.statusCode == 401) {
            await _handleTokenExpiration();
          }

          handler.next(error);
        },
      ),
    );

    _isInitialized = true;
  }

  /// Ensure the Dio instance is initialized.
  static Dio get instance {
    if (!_isInitialized) {
      initialize();
    }
    return _dio;
  }

  /// Handle token expiration by clearing stored data
  static Future<void> _handleTokenExpiration() async {
    if (kDebugMode) {
      print('🔐 Token expired → clearing stored credentials');
    }
    await StorageService.clearAll();
    // Optionally: navigate to login screen via your own NavigationService
  }

  // ------------ Public HTTP helpers ------------

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

  static Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final effective = _withSmartContentType(data, options);
    return await instance.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: effective,
    );
  }

  static Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final effective = _withSmartContentType(data, options);
    return await instance.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: effective,
    );
  }

  static Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final effective = _withSmartContentType(data, options);
    return await instance.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: effective,
    );
  }

  // ------------ Private helpers ------------

  /// If caller didn't set a contentType, pick a sensible default:
  /// - multipart/form-data for FormData
  /// - application/json otherwise
  static Options _withSmartContentType(dynamic data, Options? options) {
    final o = (options ?? Options()).copyWith();
    if (o.contentType == null) {
      if (data is FormData) {
        o.contentType = Headers.multipartFormDataContentType;
      } else {
        o.contentType = Headers.jsonContentType;
      }
    }
    return o;
  }

  static void _applySmartContentType(RequestOptions options) {
    if (options.contentType != null) return; // caller already decided
    if (options.data is FormData) {
      options.contentType = Headers.multipartFormDataContentType;
    } else {
      options.contentType = Headers.jsonContentType;
    }
  }

  // ------------ Logging ------------

  static void _prettyLogRequest(RequestOptions options) {
    if (kDebugMode) {
      print('📤 ${options.method} ${options.uri}');
    }
    if (kDebugMode) {
      print('Headers: ${options.headers}');
    }
    final data = options.data;
    if (data is FormData) {
      final fields = data.fields.map((e) => '${e.key}=${e.value}').join(', ');
      final files = data.files.map((e) => e.key).join(', ');
      if (kDebugMode) {
        print('Body: FormData{ fields: {$fields}, files: [$files] }');
      }
    } else {
      if (kDebugMode) {
        print('Body: ${data ?? '(no body)'}');
      }
    }
  }

  static void _prettyLogResponse(Response response) {
    if (kDebugMode) {
      print('📥 ${response.statusCode} ${response.requestOptions.uri}');
    }
    if (kDebugMode) {
      print('Response: ${response.data}');
    }
  }

  static void _prettyLogError(DioException error) {
    if (kDebugMode) {
      print('❌ ${error.requestOptions.method} ${error.requestOptions.uri}');
    }
    if (kDebugMode) {
      print('Error: ${error.message}');
    }
    if (error.response != null) {
      if (kDebugMode) {
        print('Response: ${error.response?.data}');
      }
    }
  }
}
