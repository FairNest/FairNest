import 'package:fairnestui/components/MainButton.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';

// NEW
import 'package:fairnestui/services/api_client.dart';

class EditChorePage extends StatefulWidget {
  const EditChorePage({
    super.key,
    // routing params (required for API)
    required this.roomId,
    required this.choreId,
    // optional prefilled values (will be overridden by API on load)
    required this.title,
    required this.dateTime,
    required this.assignees,
    required this.category,
    required this.recurrence,
    required this.autoRotate,
  });

  final int roomId;
  final int choreId;

  final String title;
  final DateTime? dateTime;
  final List<String> assignees;
  final String? category;
  final String? recurrence;
  final bool autoRotate;

  @override
  State<EditChorePage> createState() => _EditChorePageState();
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

class _EditChorePageState extends State<EditChorePage> {
  final _formKey = GlobalKey<FormState>();

  // form state
  late final TextEditingController _titleCtrl =
      TextEditingController(text: widget.title);
  DateTime? _dateTime;
  late final List<String> _assignees = [...widget.assignees];
  String? _category;
  String? _recurrence;
  String? _autoRotate; // "Yes"/"No"

  // dynamic roommates
  List<RoomUserInfo> _roommates = [];
  bool _loadingMembers = false;

  // remote chore detail
  bool _loading = true;
  String? _error;
  int _choreScore = 10; // fallback if API missing
  String _choreDescription = ""; // not used in UI but sent to backend

  final _categories = const [
    'Cleaning',
    'Cooking',
    'Shopping',
    'Other (custom)'
  ];
  final _recurrences = const ['Daily', 'Weekly', 'Bi-Weekly'];
  final _yesNo = const ['Yes', 'No'];

  TextStyle get _labelStyle => const TextStyle(
        fontFamily: 'Krub',
        fontWeight: FontWeight.w700,
        fontSize: 18,
      );

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
        hintText: hint,
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.8),
        ),
      );

  /* ---------------- helpers ---------------- */

  static const _weekdayFull = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  String _weekdayName(DateTime dt) => _weekdayFull[dt.weekday - 1];

  String _timeHHmm(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _prevWeekdayName(DateTime dt) =>
      _weekdayFull[((dt.weekday + 5) % 7)]; // one day before

  // turn API's "14:00" into DateTime placed on today (for UI display)
  DateTime _todayWithHHmm(String hhmm) {
    final now = DateTime.now();
    final parts = (hhmm).split(':');
    final h = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(now.year, now.month, now.day, h, m);
  }

  /* ---------------- load data ---------------- */

  Future<void> _fetchMembers() async {
    setState(() => _loadingMembers = true);
    try {
      final resp = await ApiClient.get('/rooms/${widget.roomId}/users/basic');
      final data = (resp.data as List).cast<Map<String, dynamic>>();
      _roommates = data
          .map((e) => RoomUserInfo.fromJson(e))
          .where((u) => u.userId != null)
          .toList();
    } catch (_) {
      // keep empty list; UI handles it
    } finally {
      setState(() => _loadingMembers = false);
    }
  }

  Future<void> _fetchChoreDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = await ApiClient.get('/chores/${widget.choreId}');
      final j = resp.data as Map<String, dynamic>;

      final title = (j['chore_title'] ?? '') as String;
      final dueTime = (j['due_time'] ?? '') as String;
      final category = j['category'] as String?;
      final recurrence = j['recurrence'] as String?;
      final autoRotate = (j['auto_rotate'] ?? false) as bool;
      final desc = (j['chore_description'] ?? '') as String;
      final scoreAny = j['chore_score'];
      final score =
          scoreAny is int ? scoreAny : int.tryParse('$scoreAny') ?? 10;

      final assignedUsers = ((j['assigned_users'] as List?) ?? [])
          .cast<Map<String, dynamic>>()
          .map((m) => (m['username'] as String?) ?? '')
          .where((s) => s.isNotEmpty)
          .toList();

      setState(() {
        _titleCtrl.text = title;
        _dateTime = dueTime.isNotEmpty
            ? _todayWithHHmm(dueTime)
            : (widget.dateTime ?? DateTime.now());
        _category = category ?? widget.category;
        _recurrence = recurrence ?? widget.recurrence;
        _autoRotate = (autoRotate ? 'Yes' : 'No');
        _assignees
          ..clear()
          ..addAll(assignedUsers.isNotEmpty ? assignedUsers : widget.assignees);
        _choreDescription = desc;
        _choreScore = score;
      });
    } catch (e) {
      setState(() => _error = 'Failed to load chore: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  /* ---------------- pickers ---------------- */

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initial = _dateTime ?? widget.dateTime ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      builder: (ctx, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accent),
        ),
        child: child!,
      ),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (ctx, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accent),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    setState(() {
      _dateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _pickAssignees() async {
    final selected = Set<String>.from(_assignees);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Widget body;
            if (_loadingMembers) {
              body = const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              body = ListView.builder(
                itemCount: _roommates.length,
                itemBuilder: (context, i) {
                  final u = _roommates[i];
                  final name = u.username ?? 'Unknown';
                  final checked = selected.contains(name);
                  return CheckboxListTile(
                    value: checked,
                    onChanged: (val) {
                      setModalState(() {
                        if (val == true) {
                          selected.add(name);
                        } else {
                          selected.remove(name);
                        }
                      });
                    },
                    title: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: (u.userPicture != null &&
                                  u.userPicture!.isNotEmpty)
                              ? NetworkImage(u.userPicture!)
                              : null,
                          child:
                              (u.userPicture == null || u.userPicture!.isEmpty)
                                  ? Text(
                                      name.isNotEmpty
                                          ? name.substring(0, 1).toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(name)),
                      ],
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              );
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Select Roommate(s)',
                        style: _labelStyle.copyWith(fontSize: 16)),
                    const SizedBox(height: 8),
                    Expanded(child: body),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _assignees
                                  ..clear()
                                  ..addAll(selected);
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Done'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    setState(() {});
  }

  /* ---------------- save/delete ---------------- */

  bool get _canSave =>
      _titleCtrl.text.trim().isNotEmpty &&
      (_dateTime ?? widget.dateTime) != null &&
      (_category ?? widget.category) != null &&
      (_recurrence ?? widget.recurrence) != null &&
      (_autoRotate ?? (widget.autoRotate ? 'Yes' : 'No')) != null;

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate() || !_canSave) return;

    try {
      // resolve username -> user_id
      final membersResp =
          await ApiClient.get('/rooms/${widget.roomId}/users/basic');
      final members = (membersResp.data as List).cast<Map<String, dynamic>>();
      final idByName = <String, int>{};
      for (final m in members) {
        final id = m['userId'];
        final name = m['username'];
        if (id == null || name == null) continue;
        final parsed = id is int ? id : int.tryParse('$id');
        if (parsed != null) idByName['$name'.trim().toLowerCase()] = parsed;
      }
      final selectedIds = <int>[];
      for (final n in _assignees) {
        final id = idByName[n.trim().toLowerCase()];
        if (id != null) selectedIds.add(id);
      }

      final dt = (_dateTime ?? widget.dateTime)!;
      final body = {
        "chore_title": _titleCtrl.text.trim(),
        "chore_description": _choreDescription, // keep/empty string
        "category": _category ?? widget.category,
        "due_day_of_week": _weekdayName(dt),
        "due_time": _timeHHmm(dt),
        "reminder_day_of_week": _prevWeekdayName(dt),
        "reminder_time": _timeHHmm(dt),
        "recurrence": _recurrence ?? widget.recurrence,
        "auto_rotate":
            (_autoRotate ?? (widget.autoRotate ? 'Yes' : 'No')) == 'Yes',
        "chore_score": _choreScore, // or set 10 if you want to enforce
        "assigned_user_ids": selectedIds,
      };

      // Debug log for you
      // ignore: avoid_print
      print("EditChore PUT body: $body");

      await ApiClient.put('/chores/${widget.choreId}', data: body);

      if (!mounted) return;
      Navigator.pop(context, {'action': 'saved'});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save chore: $e')),
      );
    }
  }

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
    _dateTime = widget.dateTime;
    _category = widget.category;
    _recurrence = widget.recurrence;
    _autoRotate = widget.autoRotate ? 'Yes' : 'No';
    _titleCtrl.addListener(() => setState(() {}));

    // load dynamic data
    _fetchMembers();
    _fetchChoreDetail();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  /* ---------------- UI ---------------- */

  String _dateTimeLabel() {
    final src = _dateTime ?? widget.dateTime;
    if (src == null) return 'Pick date & time';
    final dt = src;
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.accent,
          centerTitle: true,
          title: const Text('Edit Task',
              style: TextStyle(
                  fontFamily: 'Krub',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000))),
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
          title: const Text('Edit Task',
              style: TextStyle(
                  fontFamily: 'Krub',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000))),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    _fetchChoreDetail();
                    _fetchMembers();
                  },
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
          'Edit Task',
          style: TextStyle(
            fontFamily: 'Krub',
            fontWeight: FontWeight.w700,
            color: Color(0xFF000000),
          ),
        ),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF000000),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          Opacity(
            opacity: _canSave ? 1 : 0.5,
            child: TextButton(
              onPressed: _canSave ? _onSave : null,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              // Title
              Text('Title', style: _labelStyle),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                decoration: _fieldDecoration('Task Title'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 16),

              // Date & Reminder
              Text('Date & Reminder', style: _labelStyle),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: _fieldDecoration('Pick date & time'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_dateTimeLabel()),
                      const Icon(Icons.calendar_today_rounded),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Assign To
              Text('Assign To', style: _labelStyle),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickAssignees,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: _fieldDecoration('Select Roommate(s)'),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _assignees.isEmpty
                        ? [const Text('Select Roommate(s)')]
                        : _assignees
                            .map(
                              (name) => InputChip(
                                label: Text(name),
                                onDeleted: () =>
                                    setState(() => _assignees.remove(name)),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Accent "Chores" card
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
                      child: Text('Chores',
                          style: _labelStyle.copyWith(color: Colors.black87)),
                    ),
                    const SizedBox(height: 16),

                    // Category (with custom)
                    Text('Category', style: _labelStyle),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _categories.contains(_category) ? _category : null,
                      items: _categories
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) async {
                        if (v == 'Other (custom)') {
                          final custom = await showDialog<String>(
                            context: context,
                            builder: (ctx) {
                              final ctrl = TextEditingController();
                              return AlertDialog(
                                title: const Text('Custom Category'),
                                content: TextField(
                                  controller: ctrl,
                                  decoration: const InputDecoration(
                                      hintText: 'e.g., Laundry'),
                                  autofocus: true,
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, ctrl.text.trim()),
                                      child: const Text('Save')),
                                ],
                              );
                            },
                          );
                          if (custom != null && custom.isNotEmpty) {
                            setState(() => _category = custom);
                          } else {
                            setState(() => _category = null);
                          }
                        } else {
                          setState(() => _category = v);
                        }
                      },
                      decoration: _fieldDecoration('Select Category'),
                      validator: (v) => ((_category ?? v)?.isEmpty ?? true)
                          ? 'Select a category'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Recurrence
                    Text('Recurrence', style: _labelStyle),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _recurrences.contains(_recurrence)
                          ? _recurrence
                          : null,
                      items: _recurrences
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _recurrence = v),
                      decoration: _fieldDecoration('Select Recurrence'),
                      validator: (v) => (_recurrence ?? v) == null
                          ? 'Select recurrence'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Auto-Rotate
                    Text('Auto-Rotate', style: _labelStyle),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _autoRotate,
                      items: _yesNo
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _autoRotate = v),
                      decoration: _fieldDecoration('Select'),
                      validator: (v) => v == null ? 'Select yes or no' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Delete button (uses MainButton)
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
      ),
    );
  }
}
