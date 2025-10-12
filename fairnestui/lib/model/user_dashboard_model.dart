// lib/model/user_dashboard_model.dart

class UserDashboardData {
  final YourProgressInfo yourProgress;
  final TaskSummaryInfo taskSummary;

  UserDashboardData({
    required this.yourProgress,
    required this.taskSummary,
  });

  factory UserDashboardData.fromJson(Map<String, dynamic> json) {
    return UserDashboardData(
      yourProgress: YourProgressInfo.fromJson(
        json['your_progress'] as Map<String, dynamic>,
      ),
      taskSummary: TaskSummaryInfo.fromJson(
        json['task_summary'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'your_progress': yourProgress.toJson(),
      'task_summary': taskSummary.toJson(),
    };
  }
}

class YourProgressInfo {
  final int completedTasks;
  final int totalTasks;
  final int completedPayments;
  final int totalPayments;
  final int overallCompleted;
  final int overallTotal;
  final double progressPercentage;

  YourProgressInfo({
    required this.completedTasks,
    required this.totalTasks,
    required this.completedPayments,
    required this.totalPayments,
    required this.overallCompleted,
    required this.overallTotal,
    required this.progressPercentage,
  });

  factory YourProgressInfo.fromJson(Map<String, dynamic> json) {
    return YourProgressInfo(
      completedTasks: json['completed_tasks'] as int? ?? 0,
      totalTasks: json['total_tasks'] as int? ?? 0,
      completedPayments: json['completed_payments'] as int? ?? 0,
      totalPayments: json['total_payments'] as int? ?? 0,
      overallCompleted: json['overall_completed'] as int? ?? 0,
      overallTotal: json['overall_total'] as int? ?? 0,
      progressPercentage:
          (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed_tasks': completedTasks,
      'total_tasks': totalTasks,
      'completed_payments': completedPayments,
      'total_payments': totalPayments,
      'overall_completed': overallCompleted,
      'overall_total': overallTotal,
      'progress_percentage': progressPercentage,
    };
  }

  // Helper getter for progress as 0-1 decimal (for progress bars)
  double get progressDecimal {
    if (overallTotal == 0) return 0.0;
    return overallCompleted / overallTotal;
  }
}

class TaskSummaryInfo {
  final int todayUnfinishedCount;
  final int completedCount;
  final int upcomingUnfinishedCount;
  final List<UserDashboardItem> todayUnfinishedItems;
  final List<UserDashboardItem> completedItems;
  final List<UserDashboardItem> upcomingUnfinishedItems;

  TaskSummaryInfo({
    required this.todayUnfinishedCount,
    required this.completedCount,
    required this.upcomingUnfinishedCount,
    required this.todayUnfinishedItems,
    required this.completedItems,
    required this.upcomingUnfinishedItems,
  });

  factory TaskSummaryInfo.fromJson(Map<String, dynamic> json) {
    return TaskSummaryInfo(
      todayUnfinishedCount: json['today_unfinished_count'] as int? ?? 0,
      completedCount: json['completed_count'] as int? ?? 0,
      upcomingUnfinishedCount: json['upcoming_unfinished_count'] as int? ?? 0,
      todayUnfinishedItems: (json['today_unfinished_items'] as List<dynamic>?)
              ?.map((item) =>
                  UserDashboardItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      completedItems: (json['completed_items'] as List<dynamic>?)
              ?.map((item) =>
                  UserDashboardItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      upcomingUnfinishedItems:
          (json['upcoming_unfinished_items'] as List<dynamic>?)
                  ?.map((item) =>
                      UserDashboardItem.fromJson(item as Map<String, dynamic>))
                  .toList() ??
              [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today_unfinished_count': todayUnfinishedCount,
      'completed_count': completedCount,
      'upcoming_unfinished_count': upcomingUnfinishedCount,
      'today_unfinished_items':
          todayUnfinishedItems.map((e) => e.toJson()).toList(),
      'completed_items': completedItems.map((e) => e.toJson()).toList(),
      'upcoming_unfinished_items':
          upcomingUnfinishedItems.map((e) => e.toJson()).toList(),
    };
  }
}

class UserDashboardItem {
  final String itemType; // "chore" or "payment"
  final int itemId;
  final String title;
  final String? description;
  final String dueDate; // "YYYY-MM-DD"
  final String? dueTime; // "HH:MM" for chores
  final int? amount; // For payments only
  final String? category;
  final String status; // "pending", "completed", "overdue"
  final String? completedAt; // ISO timestamp

  UserDashboardItem({
    required this.itemType,
    required this.itemId,
    required this.title,
    this.description,
    required this.dueDate,
    this.dueTime,
    this.amount,
    this.category,
    required this.status,
    this.completedAt,
  });

  factory UserDashboardItem.fromJson(Map<String, dynamic> json) {
    return UserDashboardItem(
      itemType: json['item_type'] as String? ?? 'chore',
      itemId: json['item_id'] as int,
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String?,
      dueDate: json['due_date'] as String? ?? '',
      dueTime: json['due_time'] as String?,
      amount: json['amount'] as int?,
      category: json['category'] as String?,
      status: json['status'] as String? ?? 'pending',
      completedAt: json['completed_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_type': itemType,
      'item_id': itemId,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'due_time': dueTime,
      'amount': amount,
      'category': category,
      'status': status,
      'completed_at': completedAt,
    };
  }

  // Helper getters
  bool get isChore => itemType == 'chore';
  bool get isPayment => itemType == 'payment';
  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isOverdue => status == 'overdue';

  // Parse due date
  DateTime? get dueDateParsed {
    try {
      return DateTime.parse(dueDate);
    } catch (e) {
      return null;
    }
  }

  // Parse completed at
  DateTime? get completedAtParsed {
    if (completedAt == null) return null;
    try {
      return DateTime.parse(completedAt!);
    } catch (e) {
      return null;
    }
  }

  // Format display text
  String get displayDateTime {
    final date = dueDateParsed;
    if (date == null) return dueDate;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return dueTime != null ? 'Today at $dueTime' : 'Today';
    } else if (itemDate == today.add(const Duration(days: 1))) {
      return dueTime != null ? 'Tomorrow at $dueTime' : 'Tomorrow';
    } else {
      // Format as "Mon, Oct 15"
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final dayName = days[date.weekday - 1];
      final monthName = months[date.month - 1];

      if (dueTime != null) {
        return '$dayName, $monthName ${date.day} at $dueTime';
      }
      return '$dayName, $monthName ${date.day}';
    }
  }
}
