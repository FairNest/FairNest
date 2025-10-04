// models/pending_room_model.dart
class PendingRoomModel {
  final int roomId;
  final String roomName;
  final bool roomType; // Changed from String to bool
  final int roomMaxCapacity;
  final int roomCurrentCapacity;
  final String roomDescription;
  final String roomCode;
  final int roomCompatibilityScore;
  final String? roomPicture;
  final double compatibilityPercent;
  final int roomJoinRequestId;

  PendingRoomModel({
    required this.roomId,
    required this.roomName,
    required this.roomType,
    required this.roomMaxCapacity,
    required this.roomCurrentCapacity,
    required this.roomDescription,
    required this.roomCode,
    required this.roomCompatibilityScore,
    this.roomPicture,
    required this.compatibilityPercent,
    required this.roomJoinRequestId,
  });

  factory PendingRoomModel.fromJson(Map<String, dynamic> json) {
    return PendingRoomModel(
      roomId: json['room_id'] as int,
      roomName: json['room_name'] as String,
      roomType: json['room_type'] as bool, // Changed to bool
      roomMaxCapacity: json['room_max_capacity'] as int,
      roomCurrentCapacity: json['room_current_capacity'] as int,
      roomDescription: json['room_description'] as String,
      roomCode: json['room_code'] as String,
      roomCompatibilityScore: json['room_compatibility_score'] as int,
      roomPicture: json['room_picture'] as String?,
      compatibilityPercent: (json['compatibility_percent'] as num).toDouble(),
      roomJoinRequestId: json['room_join_request_id'] as int,
    );
  }
}
