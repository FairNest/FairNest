import 'dart:convert';
import 'package:fairnestui/model/user_profile_model.dart';
import 'package:fairnestui/services/storage_service.dart';
import 'package:fairnestui/services/api_client.dart';
import 'package:fairnestui/services/user_service.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class UserProfileService {
  static const String _userProfileKey = 'user_profile';
  static UserProfileService? _instance;

  UserProfileService._internal();

  static UserProfileService get instance {
    _instance ??= UserProfileService._internal();
    return _instance!;
  }

  /// Get user profile with hybrid approach (cache + network)
  /// If userId is not provided, it will get from the JWT token
  Future<UserProfile?> getUserProfile(
      {int? userId, bool forceRefresh = false}) async {
    try {
      // Get userId from token if not provided
      final targetUserId = userId ?? await UserService.getUserIdFromToken();

      if (targetUserId == null) {
        if (kDebugMode) {
          print('❌ No user ID found in token or provided');
        }
        return null;
      }

      // First, try to get from cache if not forcing refresh
      if (!forceRefresh) {
        final cachedProfile = await _getCachedProfile();
        if (cachedProfile != null &&
            cachedProfile.userId == targetUserId &&
            !cachedProfile.isCacheExpired()) {
          // Return cached data and optionally fetch in background
          _fetchAndUpdateProfile(targetUserId);
          return cachedProfile;
        }
      }

      // Fetch from network
      return await _fetchAndUpdateProfile(targetUserId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in getUserProfile: $e');
      }
      // Return cached data as fallback
      return await _getCachedProfile();
    }
  }

  /// Get current user profile (from JWT token)
  Future<UserProfile?> getCurrentUserProfile(
      {bool forceRefresh = false}) async {
    return await getUserProfile(forceRefresh: forceRefresh);
  }

  /// Fetch from network and update cache
  Future<UserProfile?> _fetchAndUpdateProfile(int userId) async {
    try {
      final response =
          await ApiClient.get('/GetCurrentUserDetailsByUserId/$userId');

      if (response.statusCode == 200) {
        final userProfile = UserProfile.fromJson(response.data);

        // Save to cache
        await _saveToCache(userProfile);

        if (kDebugMode) {
          print('✅ User profile fetched and cached for user: $userId');
        }

        return userProfile;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load user profile: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Network error fetching user profile: $e');
      }
      rethrow;
    }
  }

  /// Get cached profile only
  Future<UserProfile?> getCachedProfile() async {
    return await _getCachedProfile();
  }

  /// Private method to get cached profile using StorageService
  Future<UserProfile?> _getCachedProfile() async {
    try {
      final userData = await StorageService.getUserData();
      final profileJson = userData?[_userProfileKey] as String?;

      if (profileJson != null) {
        final jsonData = json.decode(profileJson);
        return UserProfile.fromStorageJson(jsonData);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading cached profile: $e');
      }
      return null;
    }
  }

  /// Save profile to cache using StorageService
  Future<void> _saveToCache(UserProfile profile) async {
    try {
      final userData = await StorageService.getUserData() ?? {};
      final profileJson = json.encode(profile.toJson());
      userData[_userProfileKey] = profileJson;

      await StorageService.saveUserData(userData);

      if (kDebugMode) {
        print('💾 User profile cached successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving profile to cache: $e');
      }
    }
  }

  /// Force refresh profile (call this after profile updates)
  Future<UserProfile?> refreshUserProfile({int? userId}) async {
    final targetUserId = userId ?? await UserService.getUserIdFromToken();
    if (targetUserId == null) return null;

    return await getUserProfile(userId: targetUserId, forceRefresh: true);
  }

  /// Refresh current user profile
  Future<UserProfile?> refreshCurrentUserProfile() async {
    return await getUserProfile(forceRefresh: true);
  }

  /// Clear cached profile (useful for logout)
  Future<void> clearCache() async {
    try {
      final userData = await StorageService.getUserData();
      if (userData != null) {
        userData.remove(_userProfileKey);
        await StorageService.saveUserData(userData);
      }

      if (kDebugMode) {
        print('🗑️ User profile cache cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing profile cache: $e');
      }
    }
  }

  /// Check if cached data exists
  Future<bool> hasCachedProfile() async {
    final userData = await StorageService.getUserData();
    return userData?.containsKey(_userProfileKey) ?? false;
  }

  /// Get cache age
  Future<Duration?> getCacheAge() async {
    final profile = await _getCachedProfile();
    if (profile != null) {
      return DateTime.now().difference(profile.lastUpdated);
    }
    return null;
  }

  /// Check if cached profile is expired
  Future<bool> isCacheExpired(
      {Duration maxAge = const Duration(hours: 24)}) async {
    final profile = await _getCachedProfile();
    return profile?.isCacheExpired(maxAge: maxAge) ?? true;
  }

  /// Update specific profile fields and refresh cache
  /// Call this after any profile update API calls
  Future<UserProfile?> updateAndRefresh() async {
    if (kDebugMode) {
      print('🔄 Updating user profile after modification...');
    }
    return await refreshCurrentUserProfile();
  }
}
