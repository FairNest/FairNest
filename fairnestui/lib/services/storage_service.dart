import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class StorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Token management
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  /// Save authentication token
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving token: $e');
      }
      throw Exception('Failed to save authentication token');
    }
  }

  /// Get stored authentication token
  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error reading token: $e');
      }
      return null;
    }
  }

  /// Clear authentication token
  static Future<void> clearToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing token: $e');
      }
    }
  }

  /// Save user data (user_id, email, etc.)
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final jsonString = jsonEncode(userData);
      await _storage.write(key: _userDataKey, value: jsonString);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user data: $e');
      }
      throw Exception('Failed to save user data');
    }
  }

  /// Get stored user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final jsonString = await _storage.read(key: _userDataKey);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error reading user data: $e');
      }
      return null;
    }
  }

  /// Clear user data
  static Future<void> clearUserData() async {
    try {
      await _storage.delete(key: _userDataKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing user data: $e');
      }
    }
  }

  /// Clear all stored data (logout)
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all data: $e');
      }
    }
  }

  /// Get current user ID
  static Future<int?> getCurrentUserId() async {
    final userData = await getUserData();
    return userData?['user_id'] as int?;
  }

  /// Get current user email
  static Future<String?> getCurrentUserEmail() async {
    final userData = await getUserData();
    return userData?['email'] as String?;
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
