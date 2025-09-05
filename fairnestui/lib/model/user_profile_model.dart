class UserProfile {
  final int userId;
  final String username;
  final String firstname;
  final String lastname;
  final String userPicture;
  final String userAboutMe;
  final double userTidiness;
  final double userNoiseActivity;
  final double userSchedule;
  final double userGuestFrequency;
  final double userTaskStructure;
  final double userMoneyAttitude;
  final int roommateScore;
  final int roomId;
  final DateTime lastUpdated;

  UserProfile({
    required this.userId,
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.userPicture,
    required this.userAboutMe,
    required this.userTidiness,
    required this.userNoiseActivity,
    required this.userSchedule,
    required this.userGuestFrequency,
    required this.userTaskStructure,
    required this.userMoneyAttitude,
    required this.roommateScore,
    required this.roomId,
    required this.lastUpdated,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'],
      username: json['username'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      userPicture: json['user_picture'],
      userAboutMe: json['user_about_me'],
      userTidiness: (json['user_tidiness'] as num).toDouble(),
      userNoiseActivity: (json['user_noise_activity'] as num).toDouble(),
      userSchedule: (json['user_schedule'] as num).toDouble(),
      userGuestFrequency: (json['user_guest_frequency'] as num).toDouble(),
      userTaskStructure: (json['user_task_structure'] as num).toDouble(),
      userMoneyAttitude: (json['user_money_attitude'] as num).toDouble(),
      roommateScore: json['roommate_score'],
      roomId: json['room_id'],
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'firstname': firstname,
      'lastname': lastname,
      'user_picture': userPicture,
      'user_about_me': userAboutMe,
      'user_tidiness': userTidiness,
      'user_noise_activity': userNoiseActivity,
      'user_schedule': userSchedule,
      'user_guest_frequency': userGuestFrequency,
      'user_task_structure': userTaskStructure,
      'user_money_attitude': userMoneyAttitude,
      'roommate_score': roommateScore,
      'room_id': roomId,
      'last_updated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory UserProfile.fromStorageJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'],
      username: json['username'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      userPicture: json['user_picture'],
      userAboutMe: json['user_about_me'],
      userTidiness: (json['user_tidiness'] as num).toDouble(),
      userNoiseActivity: (json['user_noise_activity'] as num).toDouble(),
      userSchedule: (json['user_schedule'] as num).toDouble(),
      userGuestFrequency: (json['user_guest_frequency'] as num).toDouble(),
      userTaskStructure: (json['user_task_structure'] as num).toDouble(),
      userMoneyAttitude: (json['user_money_attitude'] as num).toDouble(),
      roommateScore: json['roommate_score'],
      roomId: json['room_id'],
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['last_updated']),
    );
  }

  String get fullName => '$firstname $lastname';

  bool isCacheExpired({Duration maxAge = const Duration(hours: 24)}) {
    return DateTime.now().difference(lastUpdated) > maxAge;
  }
}
