import 'package:fairnestui/components/MainButton.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/services/api_client.dart';

class ViewChorePage extends StatefulWidget {
  const ViewChorePage({
    super.key,
    required this.roomId,
    required this.choreId,
  });

  final int roomId;
  final int choreId;

  @override
  State<ViewChorePage> createState() => _ViewChorePageState();
}

/* ---------------- models ---------------- */

class RoomUserInfo {
  final int? userId;
  final String? username;
  final String? userPicture;
  RoomUserInfo({this.userId, this.username, this.userPicture});
  factory RoomUserInfo.fromJson(Map<String, dynamic> j) => RoomUserInfo(
        userId:
            j['userId'] is int ? j['userId'] : int.tryParse('${j['userId']}'),
        username: j['username'] as String?,
        userPicture: j['userPicture'] as String?,
      );
}

class _ViewChorePageState extends State<ViewChorePage> {
  // loading state
  bool _loading = true;
  String? _error;

  // display-only data
  String _title = '';
  DateTime? _dueDateTime;
  String? _category;
  String? _recurrence;
  bool _autoRotate = false;
  int _choreScore = 10;
  String _choreDescription = '';
  List<String> _assignees = [];

  /* ---------------- helpers ---------------- */

  List<String> _dedupUsernamesByUserId(List<dynamic> arr) {
    final seenIds = <int>{};
    final names = <String>[];
    for (final e in arr) {
      if (e is! Map<String, dynamic>) continue;
      final idAny = e['userId'] ?? e['user_id'];
      final uid = idAny is int ? idAny : int.tryParse('$idAny');
      final name = (e['username'] as String?)?.trim();
      if (uid != null) {
        if (seenIds.add(uid)) {
          if (name != null && name.isNotEmpty) names.add(name);
        }
      } else {
        // Fallback: no id — dedupe by name
        if (name != null && name.isNotEmpty && !names.contains(name)) {
          names.add(name);
        }
      }
    }
    return names;
  }

  static const _weekdayFull = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  String _timeHHmm(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  // API provides "14:00" -> bind to today (for a consistent display time)
  DateTime _todayWithHHmm(String hhmm) {
    final now = DateTime.now();
    final parts = (hhmm).split(':');
    final h = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(now.year, now.month, now.day, h, m);
  }

  String _dateTimeLabel() {
    final dt = _dueDateTime;
    if (dt == null) return '—';
    const wk = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const mo = [
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
    String two(int v) => v.toString().padLeft(2, '0');
    return '${wk[dt.weekday - 1]} ${dt.day} ${mo[dt.month - 1]}  ${two(dt.hour)}:${two(dt.minute)}';
  }

  TextStyle get _labelStyle => const TextStyle(
        fontFamily: 'Krub',
        fontWeight: FontWeight.w700,
        fontSize: 18,
      );

  InputDecoration _fieldDecoration() => InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      );

  /* ---------------- load (GET) ---------------- */

  Future<void> _fetchChoreDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = await ApiClient.get('/chores/${widget.choreId}');

      print("GET /chores/${widget.choreId} response: ${resp.data}");
      final j = resp.data as Map<String, dynamic>;

      final title = (j['chore_title'] ?? '') as String;
      final dueTimeStr = (j['due_time'] ?? '') as String;
      final category = j['category'] as String?;
      final recurrence = j['recurrence'] as String?;
      final autoRotate = (j['auto_rotate'] ?? false) as bool;
      final desc = (j['chore_description'] ?? '') as String;
      final scoreAny = j['chore_score'];
      final score =
          scoreAny is int ? scoreAny : int.tryParse('$scoreAny') ?? 10;

// Supports both shapes: `assigned_users: [...]` or single `assigned_user: {...}`
      final rawAssignedList = (j['assigned_users'] as List?) ?? [];
      var assignedUsers = _dedupUsernamesByUserId(rawAssignedList);

// Fallback if backend uses single object field
      if (assignedUsers.isEmpty && j['assigned_user'] is Map<String, dynamic>) {
        assignedUsers = _dedupUsernamesByUserId([j['assigned_user']]);
      }

      print("Assigned users (deduped): $assignedUsers");

      setState(() {
        _title = title;
        _dueDateTime =
            dueTimeStr.isNotEmpty ? _todayWithHHmm(dueTimeStr) : null;
        _category = category;
        _recurrence = recurrence;
        _autoRotate = autoRotate;
        _assignees = assignedUsers;
        _choreDescription = desc;
        _choreScore = score;
      });
    } catch (e) {
      setState(() => _error = 'Failed to load chore: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  /* ---------------- delete (DELETE) ---------------- */

  Future<void> _onDelete() async {
    try {
      await ApiClient.delete('/chores/${widget.choreId}');
      if (!mounted) return;
      Navigator.pop(context, {'action': 'deleted'});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete chore: $e')),
      );
    }
  }

  /* ---------------- lifecycle ---------------- */

  @override
  void initState() {
    super.initState();
    _fetchChoreDetail();
  }

  /* ---------------- UI (read-only) ---------------- */

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.accent,
          centerTitle: true,
          title: const Text(
            'View Task',
            style: TextStyle(
              fontFamily: 'Krub',
              fontWeight: FontWeight.w700,
              color: Color(0xFF000000),
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.accent,
          centerTitle: true,
          title: const Text(
            'View Task',
            style: TextStyle(
              fontFamily: 'Krub',
              fontWeight: FontWeight.w700,
              color: Color(0xFF000000),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _fetchChoreDetail,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.accent,
        centerTitle: true,
        leadingWidth: 80,
        title: const Text(
          'View Task',
          style: TextStyle(
            fontFamily: 'Krub',
            fontWeight: FontWeight.w700,
            color: Color(0xFF000000),
          ),
        ),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Back',
            style: TextStyle(
              color: Color(0xFF000000),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: const [
          // No Save/Create buttons anymore
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // Title (read-only)
            Text('Title', style: _labelStyle),
            const SizedBox(height: 8),
            AbsorbPointer(
              absorbing: true,
              child: TextFormField(
                initialValue: _title,
                enabled: false,
                decoration: _fieldDecoration(),
              ),
            ),
            const SizedBox(height: 16),

            // Date & Reminder (read-only)
            Text('Date & Reminder', style: _labelStyle),
            const SizedBox(height: 8),
            InputDecorator(
              decoration: _fieldDecoration(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_dateTimeLabel()),
                  const Icon(Icons.calendar_today_rounded),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Assignees (read-only chips)
            Text('Assign To', style: _labelStyle),
            const SizedBox(height: 8),
            InputDecorator(
              decoration: _fieldDecoration(),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _assignees.isEmpty
                    ? [const Text('—')]
                    : _assignees
                        .map((name) => InputChip(
                              label: Text(name),
                              onDeleted: null, // read-only
                              isEnabled: false,
                            ))
                        .toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Accent "Chores" card (read-only)
            Container(
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Chores',
                      style: _labelStyle.copyWith(color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category
                  Text('Category', style: _labelStyle),
                  const SizedBox(height: 8),
                  InputDecorator(
                    decoration: _fieldDecoration(),
                    child:
                        Text(_category?.isNotEmpty == true ? _category! : '—'),
                  ),
                  const SizedBox(height: 16),

                  // Recurrence
                  Text('Recurrence', style: _labelStyle),
                  const SizedBox(height: 8),
                  InputDecorator(
                    decoration: _fieldDecoration(),
                    child: Text(
                        _recurrence?.isNotEmpty == true ? _recurrence! : '—'),
                  ),
                  const SizedBox(height: 16),

                  // Auto-Rotate
                  Text('Auto-Rotate', style: _labelStyle),
                  const SizedBox(height: 8),
                  InputDecorator(
                    decoration: _fieldDecoration(),
                    child: Text(_autoRotate ? 'Yes' : 'No'),
                  ),
                  const SizedBox(height: 16),

                  // Optional: Score & Description (if you want to show)
                  Text('Score', style: _labelStyle),
                  const SizedBox(height: 8),
                  InputDecorator(
                    decoration: _fieldDecoration(),
                    child: Text('$_choreScore'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Delete button
            Center(
              child: MainButton(
                text: 'Delete',
                onPressed: _onDelete,
                backgroundColor: const Color(0xFFC34C04),
                textColor: Colors.white,
                width: double.infinity,
                height: 56,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
