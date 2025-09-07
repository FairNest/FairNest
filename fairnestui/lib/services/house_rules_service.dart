// lib/services/house_rules_service.dart
import 'package:fairnestui/model/house_rules_model.dart';
import 'package:fairnestui/services/api_client.dart';
import 'package:fairnestui/services/user_profile_service.dart';

class HouseRulesService {
  Future<HouseRules?> getForCurrentRoom() async {
    final cached = await UserProfileService.instance.getCachedProfile();
    final profile =
        cached ?? await UserProfileService.instance.getCurrentUserProfile();
    if (profile == null || profile.roomId == 0) return null;

    final res = await ApiClient.get('/GetHouseRulesByRoomId/${profile.roomId}');
    if (res.statusCode == 200 && res.data != null) {
      return HouseRules.fromJson(res.data as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> patchForCurrentRoom(HouseRulesPatch patch) async {
    final cached = await UserProfileService.instance.getCachedProfile();
    final profile =
        cached ?? await UserProfileService.instance.getCurrentUserProfile();
    if (profile == null || profile.roomId == 0) {
      throw StateError('No roomId found for current user');
    }

    // ApiClient has no patch helper — use the Dio instance directly.
    await ApiClient.instance.patch(
      '/PatchEditHouseRulesByRoomId/${profile.roomId}',
      data: patch.toJson(),
    );
  }
}
