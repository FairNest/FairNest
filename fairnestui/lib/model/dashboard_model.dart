// lib/model/dashboard_model.dart

class RoomDashboardData {
  final TodayRoomStatus todayRoomStatus;
  final List<RoommateOverviewItem> roommateOverview;

  RoomDashboardData({
    required this.todayRoomStatus,
    required this.roommateOverview,
  });

  factory RoomDashboardData.fromJson(Map<String, dynamic> json) {
    return RoomDashboardData(
      todayRoomStatus: TodayRoomStatus.fromJson(
        json['today_room_status'] as Map<String, dynamic>,
      ),
      roommateOverview: (json['roommate_overview'] as List<dynamic>)
          .map((item) =>
              RoommateOverviewItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today_room_status': todayRoomStatus.toJson(),
      'roommate_overview': roommateOverview.map((e) => e.toJson()).toList(),
    };
  }
}

class TodayRoomStatus {
  final RoomCompatibilityInfo roomCompatibility;
  final ChoresProgressInfo choresProgress;
  final FinancesProgressInfo financesProgress;

  TodayRoomStatus({
    required this.roomCompatibility,
    required this.choresProgress,
    required this.financesProgress,
  });

  factory TodayRoomStatus.fromJson(Map<String, dynamic> json) {
    return TodayRoomStatus(
      roomCompatibility: RoomCompatibilityInfo.fromJson(
        json['room_compatibility'] as Map<String, dynamic>,
      ),
      choresProgress: ChoresProgressInfo.fromJson(
        json['chores_progress'] as Map<String, dynamic>,
      ),
      financesProgress: FinancesProgressInfo.fromJson(
        json['finances_progress'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_compatibility': roomCompatibility.toJson(),
      'chores_progress': choresProgress.toJson(),
      'finances_progress': financesProgress.toJson(),
    };
  }
}

class RoomCompatibilityInfo {
  final double score; // 0.0 to 1.0

  RoomCompatibilityInfo({required this.score});

  factory RoomCompatibilityInfo.fromJson(Map<String, dynamic> json) {
    return RoomCompatibilityInfo(
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'score': score};
  }
}

class ChoresProgressInfo {
  final int completedTasks;
  final int totalTasks;

  ChoresProgressInfo({
    required this.completedTasks,
    required this.totalTasks,
  });

  factory ChoresProgressInfo.fromJson(Map<String, dynamic> json) {
    return ChoresProgressInfo(
      completedTasks: json['completed_tasks'] as int? ?? 0,
      totalTasks: json['total_tasks'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed_tasks': completedTasks,
      'total_tasks': totalTasks,
    };
  }

  double get progressPercentage {
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }
}

class FinancesProgressInfo {
  final int completedFinances;
  final int totalFinances;

  FinancesProgressInfo({
    required this.completedFinances,
    required this.totalFinances,
  });

  factory FinancesProgressInfo.fromJson(Map<String, dynamic> json) {
    return FinancesProgressInfo(
      completedFinances: json['completed_finances'] as int? ?? 0,
      totalFinances: json['total_finances'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed_finances': completedFinances,
      'total_finances': totalFinances,
    };
  }

  double get progressPercentage {
    if (totalFinances == 0) return 0.0;
    return completedFinances / totalFinances;
  }
}

class RoommateOverviewItem {
  final int userId;
  final String name;
  final String? userPicture;
  final double compatibilityScore; // 0-100 percentage
  final int tasksCompleted;
  final int tasksTotal;
  final int financeAmount;
  final String financeStatus; // Always "owes_you"

  RoommateOverviewItem({
    required this.userId,
    required this.name,
    this.userPicture,
    required this.compatibilityScore,
    required this.tasksCompleted,
    required this.tasksTotal,
    required this.financeAmount,
    required this.financeStatus,
  });

  factory RoommateOverviewItem.fromJson(Map<String, dynamic> json) {
    return RoommateOverviewItem(
      userId: json['user_id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      userPicture: json['user_picture'] as String?,
      compatibilityScore:
          (json['compatibility_score'] as num?)?.toDouble() ?? 0.0,
      tasksCompleted: json['tasks_completed'] as int? ?? 0,
      tasksTotal: json['tasks_total'] as int? ?? 0,
      financeAmount: json['finance_amount'] as int? ?? 0,
      financeStatus: json['finance_status'] as String? ?? 'owes_you',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'user_picture': userPicture,
      'compatibility_score': compatibilityScore,
      'tasks_completed': tasksCompleted,
      'tasks_total': tasksTotal,
      'finance_amount': financeAmount,
      'finance_status': financeStatus,
    };
  }

  // Helper getter for compatibility score as integer
  int get compatibilityScoreInt => compatibilityScore.round();

  // Helper getter to check if has outstanding debt
  bool get hasOutstandingDebt => financeAmount > 0;
}
