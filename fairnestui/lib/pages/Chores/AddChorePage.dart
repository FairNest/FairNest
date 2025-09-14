import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/services/api_client.dart';
import 'package:fairnestui/services/user_profile_service.dart';

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

class AddChorePage extends StatefulWidget {
  const AddChorePage({super.key});

  @override
  State<AddChorePage> createState() => _AddChorePageState();
}

class _AddChorePageState extends State<AddChorePage> {
  final _formKey = GlobalKey<FormState>();

  // form fields
  final _titleCtrl = TextEditingController();
  DateTime? _dateTime;
  final List<int> _assigneeIds = []; // selected user IDs (for backend)
  final List<String> _assigneeNames = []; // selected usernames (chips)
  String? _category;
  String? _recurrence;
  String? _autoRotate;

  // dynamic roommates from API
  List<RoomUserInfo> _roommates = [];
  bool _loadingMembers = false;
  String? _loadError;

  // room id (from cached profile only)
  int? _roomId;
  bool _resolvingRoom = true;
  String? _roomResolveError;

  // submit state
  bool _submitting = false;

  // Mutable options so we can insert custom values safely
  final List<String> _categoryOptions = [
    'Cleaning',
    'Cooking',
    'Shopping',
    'Other (custom)',
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
      );

  // ==========================
  // RoomId from cached profile
  // ==========================
  Future<void> _resolveRoomIdFromCacheAndLoadMembers() async {
    setState(() {
      _resolvingRoom = true;
      _roomResolveError = null;
    });
    try {
      final cached = await UserProfileService.instance.getCachedProfile();
      if (cached == null) {
        throw Exception(
          'No cached profile found. Open profile (or login) once to cache it.',
        );
      }
      if (cached.roomId <= 0) {
        throw Exception('Cached profile has no valid room_id.');
      }

      setState(() {
        _roomId = cached.roomId;
      });

      await _fetchRoomMembers(); // now use _roomId
    } catch (e) {
      setState(() {
        _roomResolveError = e.toString();
      });
    } finally {
      setState(() {
        _resolvingRoom = false;
      });
    }
  }

  // ==========================
  // API: fetch room members
  // ==========================
  Future<void> _fetchRoomMembers() async {
    if (_roomId == null) return;
    setState(() {
      _loadingMembers = true;
      _loadError = null;
    });
    try {
      final resp = await ApiClient.get('/rooms/${_roomId}/users/basic');
      final data = resp.data as List;
      final list = data
          .map((e) => RoomUserInfo.fromJson(e as Map<String, dynamic>))
          .where((u) => u.userId != null)
          .toList();
      setState(() {
        _roommates = list;
      });
    } catch (e) {
      setState(() {
        _loadError = 'Failed to load room members';
      });
    } finally {
      setState(() {
        _loadingMembers = false;
      });
    }
  }

  // ==========================
  // Date & time picker
  // ==========================
  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initial = _dateTime ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      builder: (ctx, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
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
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
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

  // ==========================
  // Assign picker (uses _roommates)
  // ==========================
  Future<void> _pickAssignees() async {
    final selectedIds = Set<int>.from(_assigneeIds);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            } else if (_loadError != null) {
              body = Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_loadError!,
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _fetchRoomMembers();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else {
              body = ListView.builder(
                itemCount: _roommates.length,
                itemBuilder: (context, i) {
                  final u = _roommates[i];
                  final checked = selectedIds.contains(u.userId);
                  return CheckboxListTile(
                    value: checked,
                    onChanged: (val) {
                      setModalState(() {
                        if (val == true) {
                          if (u.userId != null) selectedIds.add(u.userId!);
                        } else {
                          if (u.userId != null) selectedIds.remove(u.userId!);
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
                                      (u.username ?? '?').isNotEmpty
                                          ? u.username!
                                              .substring(0, 1)
                                              .toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(u.username ?? 'Unknown')),
                      ],
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              );
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
                ),
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
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _assigneeIds
                                  ..clear()
                                  ..addAll(selectedIds);
                                _assigneeNames
                                  ..clear()
                                  ..addAll(_roommates
                                      .where((u) =>
                                          u.userId != null &&
                                          selectedIds.contains(u.userId!))
                                      .map((u) => u.username ?? 'User'));
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
  }

  // ==========================
  // Date label
  // ==========================
  String _dateTimeLabel() {
    if (_dateTime == null) return 'Pick date & time';
    final dt = _dateTime!;
    const wkShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
    return '${wkShort[dt.weekday - 1]} ${dt.day} ${mo[dt.month - 1]}  ${two(dt.hour)}:${two(dt.minute)}';
  }

  // === Helpers for payload formatting ===
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
  String _prevWeekdayName(DateTime dt) {
    final prev = dt.subtract(const Duration(days: 1));
    return _weekdayName(prev);
  }

  // ==========================
  // Create pressed (INTEGRATED)
  // ==========================
  Future<void> _onCreate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_roomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room ID not available.')),
      );
      return;
    }
    if (_dateTime == null) return;

    // Require at least one assignee (guarded by _canCreate as well)
    if (_assigneeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one assignee.')),
      );
      return;
    }

    final due = _dateTime!;
    final body = {
      "chore_title": _titleCtrl.text.trim(),
      "chore_description": "", // requested: empty string
      "category": _category,
      "due_day_of_week": _weekdayName(due), // e.g., "Sunday"
      "due_time": _timeHHmm(due), // "HH:MM" 24h
      "reminder_day_of_week": _prevWeekdayName(due), // due - 1 day
      "reminder_time": _timeHHmm(due), // same time
      "recurrence": _recurrence,
      "auto_rotate": _autoRotate == 'Yes',
      "chore_score": 10, // always 10
      "assigned_user_ids": _assigneeIds, // selected IDs
    };

    if (kDebugMode) {
      debugPrint('AddChore payload => ${jsonEncode(body)}');
    }

    setState(() => _submitting = true);
    try {
      await ApiClient.post('/rooms/${_roomId}/chores', data: body);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chore created successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create chore: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  bool get _canCreate =>
      !_submitting &&
      _titleCtrl.text.trim().isNotEmpty &&
      _dateTime != null &&
      _category != null &&
      _recurrence != null &&
      _autoRotate != null &&
      _assigneeIds.isNotEmpty; // now mandatory

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(() => setState(() {}));
    _resolveRoomIdFromCacheAndLoadMembers(); // roomId from cache only
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wait until roomId resolved from cache
    if (_resolvingRoom) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          centerTitle: true,
          title: const Text(
            'New Task',
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

    if (_roomResolveError != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          centerTitle: true,
          title: const Text(
            'New Task',
            style: TextStyle(
              fontFamily: 'Krub',
              fontWeight: FontWeight.w700,
              color: Color(0xFF000000),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_roomResolveError!,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _resolveRoomIdFromCacheAndLoadMembers,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        leadingWidth: 80, // keep "Cancel" on one line
        title: const Text(
          'New Task',
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
            opacity: _canCreate ? 1 : 0.5,
            child: TextButton(
              onPressed: _canCreate ? _onCreate : null,
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Create',
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

              // Assign To (dynamic)
              Text('Assign To', style: _labelStyle),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickAssignees,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: _fieldDecoration('Select Roommate(s)'),
                  child: _loadingMembers
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('Loading members...'),
                            ],
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _assigneeNames.isEmpty
                              ? [const Text('Select Roommate(s)')]
                              : _assigneeNames
                                  .map(
                                    (name) => InputChip(
                                      label: Text(name),
                                      onDeleted: () {
                                        final idx =
                                            _assigneeNames.indexOf(name);
                                        if (idx >= 0 &&
                                            idx < _assigneeIds.length) {
                                          setState(() {
                                            _assigneeNames.removeAt(idx);
                                            _assigneeIds.removeAt(idx);
                                          });
                                        }
                                      },
                                    ),
                                  )
                                  .toList(),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Purple "Chores" card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
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
                    DropdownButtonFormField<String>(
                      value: _category,
                      items: _categoryOptions
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
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, ctrl.text.trim()),
                                    child: const Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (custom != null && custom.isNotEmpty) {
                            if (!_categoryOptions.contains(custom)) {
                              setState(
                                  () => _categoryOptions.insert(0, custom));
                            }
                            setState(() => _category = custom);
                          }
                        } else {
                          setState(() => _category = v);
                        }
                      },
                      decoration: _fieldDecoration('Select Category'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Select a category' : null,
                    ),
                    const SizedBox(height: 16),

                    // Recurrence
                    Text('Recurrence', style: _labelStyle),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _recurrence,
                      items: _recurrences
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _recurrence = v),
                      decoration: _fieldDecoration('Select Recurrence'),
                      validator: (v) => v == null ? 'Select recurrence' : null,
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
            ],
          ),
        ),
      ),
    );
  }
}
