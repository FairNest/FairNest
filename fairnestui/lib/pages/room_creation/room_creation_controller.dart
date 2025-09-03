// lib/pages/room_creation/room_creation_controller.dart
import 'dart:convert';
import 'package:fairnestui/services/user_service.dart';
import 'package:flutter/foundation.dart';
import 'package:fairnestui/services/storage_service.dart'; // Change from user_service to storage_service
import 'package:fairnestui/services/api_client.dart'; // Add ApiClient import
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart'; // Add Dio import for Response type

// Reuse your existing models/enums from the pages you already wrote.
import 'package:fairnestui/pages/room_creation/RoommateAgreement.dart'
    show
        QuietHoursOption,
        GuestPolicyOption,
        CleaningMethodOption,
        ResponsibilityOption,
        SplitCostsOption;

/// Living setup model (your fields)
///

enum GroupType { private, public }

class CreateRoomData {
  final String name;
  final GroupType type;
  final int roommateCount;
  final String description;

  CreateRoomData({
    required this.name,
    required this.type,
    required this.roommateCount,
    required this.description,
  });
}

class CreateLivingSetupData {
  final String livingSpaceName;
  final double rentCost;
  final double electricityCostPerUnit;
  final double waterCostPerUnit;
  final String otherUtilityDetails;

  const CreateLivingSetupData({
    required this.livingSpaceName,
    required this.rentCost,
    required this.electricityCostPerUnit,
    required this.waterCostPerUnit,
    required this.otherUtilityDetails,
  });

  Map<String, dynamic> toJson() => {
        'livingSpaceName': livingSpaceName,
        'rentCost': rentCost,
        'electricityCostPerUnit': electricityCostPerUnit,
        'waterCostPerUnit': waterCostPerUnit,
        'otherUtilityDetails': otherUtilityDetails,
      };
}

/// =============================== Controller =================================

class RoomCreationController extends ChangeNotifier {
  // Step 1 — Details
  String? _roomName;
  GroupType? _groupType;
  int? _roommateCount;
  String? _roomDescription;

  // Step 2 — Living Setup
  CreateLivingSetupData? _living;

  // Step 3 — Agreement
  QuietHoursOption? _quietHours;
  String? _quietHoursCustom;
  GuestPolicyOption? _guestPolicy;
  CleaningMethodOption? _cleaningMethod;
  final Set<ResponsibilityOption> _responsibilities = {};
  SplitCostsOption? _splitCosts;

  // ================================ Getters ==================================
  String? get roomName => _roomName;
  GroupType? get groupType => _groupType;
  int? get roommateCount => _roommateCount;
  String? get roomDescription => _roomDescription;

  CreateLivingSetupData? get living => _living;

  QuietHoursOption? get quietHours => _quietHours;
  String? get quietHoursCustom => _quietHoursCustom;
  GuestPolicyOption? get guestPolicy => _guestPolicy;
  CleaningMethodOption? get cleaningMethod => _cleaningMethod;
  List<ResponsibilityOption> get responsibilities =>
      _responsibilities.toList(growable: false);
  SplitCostsOption? get splitCosts => _splitCosts;

  // ============================== Status flags ===============================
  bool get hasDetails =>
      _roomName != null && _groupType != null && (_roommateCount ?? 0) > 0;

  bool get hasLiving => _living != null;

  bool get hasAgreement =>
      _quietHours != null &&
      _guestPolicy != null &&
      _cleaningMethod != null &&
      _splitCosts != null;

  bool get isComplete => hasDetails && hasLiving && hasAgreement;
  // =============================== Debug utils ===============================

  /// Returns a list of missing fields so you know exactly what’s incomplete
  List<String> debugMissingFields() {
    final missing = <String>[];

    if (_roomName == null || _roomName!.isEmpty) missing.add("roomName");
    if (_groupType == null) missing.add("groupType");
    if (_roommateCount == null || _roommateCount! <= 0) {
      missing.add("roommateCount");
    }
    if (_roomDescription == null || _roomDescription!.isEmpty) {
      missing.add("roomDescription");
    }

    if (_living == null) {
      missing.addAll([
        "livingSpaceName",
        "rentCost",
        "electricityCostPerUnit",
        "waterCostPerUnit",
        "otherUtilityDetails",
      ]);
    } else {
      if (_living!.livingSpaceName.isEmpty) missing.add("livingSpaceName");
      if (_living!.rentCost <= 0) missing.add("rentCost");
      if (_living!.electricityCostPerUnit <= 0) {
        missing.add("electricityCostPerUnit");
      }
      if (_living!.waterCostPerUnit <= 0) missing.add("waterCostPerUnit");
      if (_living!.otherUtilityDetails.isEmpty) {
        missing.add("otherUtilityDetails");
      }
    }

    if (_quietHours == null) missing.add("quietHours");
    if (_quietHours == QuietHoursOption.custom &&
        (_quietHoursCustom == null || _quietHoursCustom!.isEmpty)) {
      missing.add("quietHoursCustom");
    }
    if (_guestPolicy == null) missing.add("guestPolicy");
    if (_cleaningMethod == null) missing.add("cleaningMethod");
    if (_responsibilities.isEmpty) missing.add("responsibilities");
    if (_splitCosts == null) missing.add("splitCosts");

    return missing;
  }

  /// Print current state + missing fields to console
  void debugPrintState() {
    print("=== RoomCreationController Debug ===");
    print("RoomName: $_roomName");
    print("GroupType: $_groupType");
    print("RoommateCount: $_roommateCount");
    print("RoomDescription: $_roomDescription");
    print("Living: ${_living?.toJson()}");
    print("QuietHours: $_quietHours");
    print("QuietHoursCustom: $_quietHoursCustom");
    print("GuestPolicy: $_guestPolicy");
    print("CleaningMethod: $_cleaningMethod");
    print("Responsibilities: $_responsibilities");
    print("SplitCosts: $_splitCosts");
    print("Missing fields: ${debugMissingFields()}");
    print("===================================");
  }

  // ================================= Setters =================================
  void setDetails(CreateRoomData data) {
    print("DEBUG: setDetails called - name: ${data.name}, type: ${data.type}");
    _roomName = data.name;
    _groupType = data.type;
    _roommateCount = data.roommateCount;
    _roomDescription = data.description;
    notifyListeners();
  }

  void setLiving(CreateLivingSetupData living) {
    _living = living;
    notifyListeners();
  }

  void setAgreement({
    required QuietHoursOption? quietHours,
    required String? quietHoursCustom,
    required GuestPolicyOption? guestPolicy,
    required CleaningMethodOption? cleaningMethod,
    required Iterable<ResponsibilityOption> responsibilities,
    required SplitCostsOption? splitCosts,
  }) {
    _quietHours = quietHours;
    _quietHoursCustom = quietHoursCustom;
    _guestPolicy = guestPolicy;
    _cleaningMethod = cleaningMethod;
    _responsibilities
      ..clear()
      ..addAll(responsibilities);
    _splitCosts = splitCosts;
    notifyListeners();
  }

  // ========================== Enum → Backend values ==========================
  // NOTE: Adjust these strings if your backend expects different phrasing.

  /// Backend expects "22:00" / "23:00" / "" or a custom string like "9 PM – 7 AM"
  String _quietHoursValue() {
    if (_quietHours == null) return '';
    if (_quietHours == QuietHoursOption.custom) {
      return (_quietHoursCustom ?? '').trim();
    }
    switch (_quietHours!) {
      case QuietHoursOption.tenToSeven:
        return '22:00';
      case QuietHoursOption.elevenToSix:
        return '23:00';
      case QuietHoursOption.none:
        return ''; // or "none"
      case QuietHoursOption.custom:
        return (_quietHoursCustom ?? '').trim();
    }
  }

  String _guestStayOverValue() {
    switch (_guestPolicy) {
      case GuestPolicyOption.noOvernight:
        return 'No overnight guests';
      case GuestPolicyOption.max1NightWeek:
        return 'Max 1 night/week';
      case GuestPolicyOption.max3NightsMonth:
        return 'Max 3 nights/month';
      case GuestPolicyOption.noRestriction:
        return 'No restriction (notify group)';
      default:
        return '';
    }
  }

  String _handleCleaningValue() {
    switch (_cleaningMethod) {
      case CleaningMethodOption.weekly:
        return 'Weekly rotation';
      case CleaningMethodOption.biweekly:
        return 'Bi-weekly rotation';
      case CleaningMethodOption.assigned:
        return 'Assigned to specific people';
      case CleaningMethodOption.flexible:
        return 'Flexible';
      default:
        return '';
    }
  }

  /// Join responsibilities by comma for "shared_space"
  String _sharedSpaceValue() {
    if (_responsibilities.isEmpty) return '';
    final labels = _responsibilities.map((r) {
      switch (r) {
        case ResponsibilityOption.kitchen:
          return 'kitchen';
        case ResponsibilityOption.livingRoom:
          return 'living room';
        case ResponsibilityOption.bathroom:
          return 'bathroom';
        case ResponsibilityOption.trash:
          return 'trash';
      }
    }).toList();
    return labels.join(', ');
  }

  /// per backend: true = Private, false = Public
  bool _roomTypeBool() => _groupType == GroupType.private;

  /// per backend: true = Equal split, false = By usage/room size
  bool _splitCostsBool() => _splitCosts == SplitCostsOption.equal;

  // =============================== Serialization =============================

  /// Build the flat JSON your Go backend expects.
  /// (You can add more fields if your backend starts requiring them.)
  Map<String, dynamic> toBackendJson({
    int roomCurrentCapacity = 1,
    int roomCompatibilityScore = 85,
    String? roomPicture,
  }) {
    // Provide a fallback picture if one isn't given.
    final fallbackPicture =
        'https://minio.bocchikitsunei.com/fairnest/rng_room_3.png';

    return {
      // RoomDetails
      'room_name': _roomName,
      'room_type': _roomTypeBool(), // true=Private, false=Public
      'room_max_capacity': _roommateCount,
      'room_current_capacity': roomCurrentCapacity,
      'room_description': _roomDescription,
      'room_compatibility_score': roomCompatibilityScore,
      'room_picture': roomPicture ?? fallbackPicture,

      // LivingSpaceDetails (cast to int for backend)
      'living_space_name': _living?.livingSpaceName,
      'rent_cost': _living?.rentCost.round(),
      'electricity_cost_per_unit': _living?.electricityCostPerUnit.round(),
      'water_cost_per_unit': _living?.waterCostPerUnit.round(),
      'other_utility_details': _living?.otherUtilityDetails,

      // RoommateAgreements
      'quiet_hours_start': _quietHoursValue(),
      'guest_stay_over': _guestStayOverValue(),
      'handle_cleaning': _handleCleaningValue(),
      'shared_space': _sharedSpaceValue(),
      'split_costs': _splitCostsBool(),
    };
  }

  // ================================= Submit ==================================

  /// POST http://localhost:8652/CreateRoomByUserId/{userId}
  /// Uses UserService.getUserIdFromToken() to resolve the path.
  Future<Response<dynamic>> submitRoom({
    int roomCurrentCapacity = 1,
    int roomCompatibilityScore = 85,
    String? roomPicture,
  }) async {
    if (!isComplete) {
      throw StateError('Room draft is incomplete');
    }

    // Get user ID from StorageService instead of UserService
    final userId = await StorageService.getCurrentUserId();
    if (userId == null) {
      throw StateError('Could not determine current user id');
    }

    final uri = Uri.parse('http://10.0.2.2:8652/CreateRoomByUserId/$userId');

    final payload = toBackendJson(
      roomCurrentCapacity: roomCurrentCapacity,
      roomCompatibilityScore: roomCompatibilityScore,
      roomPicture: roomPicture,
    );

    try {
      // Use ApiClient.post() - bearer token automatically attached
      final response = await ApiClient.post(
        '/CreateRoomByUserId/$userId',
        data: payload,
      );

      return response;
    } on DioException catch (e) {
      // Handle Dio-specific errors
      final statusCode = e.response?.statusCode ?? 0;
      final responseBody = e.response?.data?.toString() ?? e.message;
      throw StateError('Create room failed ($statusCode): $responseBody');
    } catch (e) {
      // Handle any other errors
      throw StateError('Create room failed: $e');
    }
  }

  // ================================= Utils ===================================

  void reset() {
    _roomName = null;
    _groupType = null;
    _roommateCount = null;
    _roomDescription = null;

    _living = null;

    _quietHours = null;
    _quietHoursCustom = null;
    _guestPolicy = null;
    _cleaningMethod = null;
    _responsibilities.clear();
    _splitCosts = null;

    notifyListeners();
  }
}
