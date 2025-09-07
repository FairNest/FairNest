// lib/model/house_rules_model.dart
class HouseRules {
  final int roomId;
  final String? quietHoursStart;
  final String? guestStayOver;
  final String? handleCleaning;
  final String? sharedSpace;
  final bool? splitCosts;

  HouseRules({
    required this.roomId,
    this.quietHoursStart,
    this.guestStayOver,
    this.handleCleaning,
    this.sharedSpace,
    this.splitCosts,
  });

  factory HouseRules.fromJson(Map<String, dynamic> json) {
    return HouseRules(
      roomId: json['room_id'] as int,
      quietHoursStart: json['quiet_hours_start'] as String?,
      guestStayOver: json['guest_stay_over'] as String?,
      handleCleaning: json['handle_cleaning'] as String?,
      sharedSpace: json['shared_space'] as String?,
      splitCosts: json['split_costs'] as bool?,
    );
  }
}

/// Payload for PATCH /PatchEditHouseRulesByRoomId/:roomId
class HouseRulesPatch {
  final String? quietHoursStart; // e.g. "22:00" | "none" | "21:00"
  final String? guestStayOver; // text
  final String? handleCleaning; // text
  final String? sharedSpace; // comma separated list
  final bool? splitCosts; // true/false

  HouseRulesPatch({
    this.quietHoursStart,
    this.guestStayOver,
    this.handleCleaning,
    this.sharedSpace,
    this.splitCosts,
  });

  Map<String, dynamic> toJson() => {
        if (quietHoursStart != null) 'quiet_hours_start': quietHoursStart,
        if (guestStayOver != null) 'guest_stay_over': guestStayOver,
        if (handleCleaning != null) 'handle_cleaning': handleCleaning,
        if (sharedSpace != null) 'shared_space': sharedSpace,
        if (splitCosts != null) 'split_costs': splitCosts,
      };
}
