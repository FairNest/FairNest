import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:fairnestui/services/storage_service.dart';

class UserService {
  /// Get userId (from `iss` claim) decoded from the JWT stored in StorageService.
  static Future<int?> getUserIdFromToken() async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      Map<String, dynamic> decoded = JwtDecoder.decode(token);
      // In your backend, `iss` is set as the user ID (string). Convert to int.
      final iss = decoded['iss'];
      if (iss == null) return null;
      return int.tryParse(iss.toString());
    } catch (e) {
      if (kDebugMode) {
        print("❌ Failed to decode token: $e");
      }
      return null;
    }
  }

  /// Get email (if available) decoded from the JWT
  static Future<String?> getEmailFromToken() async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      Map<String, dynamic> decoded = JwtDecoder.decode(token);
      return decoded['email']?.toString();
    } catch (e) {
      if (kDebugMode) {
        print("❌ Failed to decode token: $e");
      }
      return null;
    }
  }
}
