// lib/model/user_dashboard_model.dart

class UserDashboardData {
  final YourProgressInfo yourProgress;
  final TaskSummaryInfo taskSummary;

  UserDashboardData({
    required this.yourProgress,
    required this.taskSummary,
  });
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

  double get progressDecimal {
    if (overallTotal == 0) return 0.0;
    return overallCompleted / overallTotal;
  }
}

class TaskSummaryInfo {
  final int todayUnfinishedCount;
  final int completedCount;
  final int upcomingUnfinishedCount;
  final UserTasksSeparatedResponse todayUnfinishedTasks;
  final UserTasksSeparatedResponse completedTasks;
  final UserTasksSeparatedResponse upcomingUnfinishedTasks;

  TaskSummaryInfo({
    required this.todayUnfinishedCount,
    required this.completedCount,
    required this.upcomingUnfinishedCount,
    required this.todayUnfinishedTasks,
    required this.completedTasks,
    required this.upcomingUnfinishedTasks,
  });
}

/// Response containing separated chores and finances
class UserTasksSeparatedResponse {
  final List<UserChoreItem> chores;
  final List<UserFinanceItem> finances;

  UserTasksSeparatedResponse({
    required this.chores,
    required this.finances,
  });

  factory UserTasksSeparatedResponse.fromJson(Map<String, dynamic> json) {
    return UserTasksSeparatedResponse(
      chores: (json['chores'] as List<dynamic>?)
              ?.map((item) =>
                  UserChoreItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      finances: (json['finances'] as List<dynamic>?)
              ?.map((item) =>
                  UserFinanceItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Get total count
  int get totalCount => chores.length + finances.length;

  /// Check if empty
  bool get isEmpty => chores.isEmpty && finances.isEmpty;
}

/// Chore item from backend
class UserChoreItem {
  final int choreAssignmentId;
  final int choreId;
  final String title;
  final String status; // "pending", "completed", "overdue"
  final String dueDate; // "YYYY-MM-DD"
  final String? dueTime; // "HH:MM"
  final String? category;
  final int points;
  final String? assignedName;
  final String? assignedAvatar;
  final bool? autoRotate;
  final String? recurrence;
  final String? reminderTime;
  final String? reminderRepeat;

  UserChoreItem({
    required this.choreAssignmentId,
    required this.choreId,
    required this.title,
    required this.status,
    required this.dueDate,
    this.dueTime,
    this.category,
    required this.points,
    this.assignedName,
    this.assignedAvatar,
    this.autoRotate,
    this.recurrence,
    this.reminderTime,
    this.reminderRepeat,
  });

  factory UserChoreItem.fromJson(Map<String, dynamic> json) {
    return UserChoreItem(
      choreAssignmentId: json['chore_assignment_id'] as int,
      choreId: json['chore_id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled',
      status: json['status'] as String? ?? 'pending',
      dueDate: json['due_date'] as String? ?? '',
      dueTime: json['due_time'] as String?,
      category: json['category'] as String?,
      points: json['points'] as int? ?? 0,
      assignedName: json['assigned_name'] as String?,
      assignedAvatar: json['assigned_avatar'] as String?,
      autoRotate: json['auto_rotate'] as bool?,
      recurrence: json['recurrence'] as String?,
      reminderTime: json['reminder_time'] as String?,
      reminderRepeat: json['reminder_repeat'] as String?,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isOverdue => status == 'overdue';

  DateTime? get dueDateParsed {
    try {
      return DateTime.parse(dueDate);
    } catch (e) {
      return null;
    }
  }

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

/// Finance item from backend
class UserFinanceItem {
  final int transactionId;
  final int financeId;
  final String title;
  final String status; // "pending", "completed", "overdue"
  final String dueDate; // "YYYY-MM-DD"
  final String? category;
  final int points;
  final int? amount;
  final int? totalAmount;
  final String? splitType; // "even" or "custom"
  final int? splitCount;
  final String? payToName;
  final String? payToAvatar;
  final String? qrCode;
  final String? paymentLink;

  UserFinanceItem({
    required this.transactionId,
    required this.financeId,
    required this.title,
    required this.status,
    required this.dueDate,
    this.category,
    required this.points,
    this.amount,
    this.totalAmount,
    this.splitType,
    this.splitCount,
    this.payToName,
    this.payToAvatar,
    this.qrCode,
    this.paymentLink,
  });

  factory UserFinanceItem.fromJson(Map<String, dynamic> json) {
    return UserFinanceItem(
      transactionId: json['transaction_id'] as int,
      financeId: json['finance_id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled',
      status: json['status'] as String? ?? 'pending',
      dueDate: json['due_date'] as String? ?? '',
      category: json['category'] as String?,
      points: json['points'] as int? ?? 0,
      amount: json['amount'] as int?,
      totalAmount: json['total_amount'] as int?,
      splitType: json['split_type'] as String?,
      splitCount: json['split_count'] as int?,
      payToName: json['pay_to_name'] as String?,
      payToAvatar: json['pay_to_avatar'] as String?,
      qrCode: json['qr_code'] as String?,
      paymentLink: json['payment_link'] as String?,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isOverdue => status == 'overdue';

  DateTime? get dueDateParsed {
    try {
      return DateTime.parse(dueDate);
    } catch (e) {
      return null;
    }
  }

  String get displayDateTime {
    final date = dueDateParsed;
    if (date == null) return dueDate;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return 'Today';
    } else if (itemDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
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
      return '$dayName, $monthName ${date.day}';
    }
  }
}
