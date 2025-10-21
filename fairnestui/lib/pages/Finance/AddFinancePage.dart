import 'dart:convert';
import 'package:fairnestui/widgets/error_pop_up.dart';
import 'package:fairnestui/widgets/success_pop_up.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class AddFinancePage extends StatefulWidget {
  const AddFinancePage({super.key});

  @override
  State<AddFinancePage> createState() => _AddFinancePageState();
}

class _AddFinancePageState extends State<AddFinancePage> {
  final _formKey = GlobalKey<FormState>();

  // form fields
  final _titleCtrl = TextEditingController();
  DateTime? _dateTime;
  final List<int> _participantIds = []; // selected user IDs
  final List<String> _participantNames = []; // selected usernames (chips)
  String? _category;
  final _amountCtrl = TextEditingController();
  String? _splitType; // Evenly | Custom

  // for custom splits: userId -> amount
  Map<int, double> _customSplits = {};

  // dynamic roommates from API (excluding current user)
  List<RoomUserInfo> _roommates = [];
  bool _loadingMembers = false;
  String? _loadError;

  // room id and current user id (from cached profile)
  int? _roomId;
  int? _currentUserId;
  bool _resolvingRoom = true;
  String? _roomResolveError;

  // submit state
  bool _submitting = false;

  // Mutable category options
  final List<String> _categoryOptions = [
    'Bill',
    'Groceries',
    'Outing/Activity',
    'Shared Subscription',
    'Other (custom)',
  ];
  final _splitTypes = const ['Evenly', 'Custom'];

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
  // RoomId and UserId from cached profile
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
      if (cached.userId <= 0) {
        throw Exception('Cached profile has no valid user_id.');
      }

      setState(() {
        _roomId = cached.roomId;
        _currentUserId = cached.userId;
      });

      await _fetchRoomMembers(); // now use _roomId and exclude _currentUserId
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
  // API: fetch room members (excluding current user)
  // ==========================
  Future<void> _fetchRoomMembers() async {
    if (_roomId == null || _currentUserId == null) return;
    setState(() {
      _loadingMembers = true;
      _loadError = null;
    });
    try {
      final resp = await ApiClient.get('/rooms/$_roomId/users/basic');
      final data = resp.data as List;
      final list = data
          .map((e) => RoomUserInfo.fromJson(e as Map<String, dynamic>))
          .where((u) =>
              u.userId != null &&
              u.userId != _currentUserId) // Exclude current user
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

  // ----------------- pickers -----------------
  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initial = _dateTime ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (_, child) => Theme(
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

  Future<void> _pickParticipants() async {
    final selectedIds = Set<int>.from(_participantIds);

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
                              backgroundColor: AppColors.darkPurple,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _participantIds
                                  ..clear()
                                  ..addAll(selectedIds);
                                _participantNames
                                  ..clear()
                                  ..addAll(_roommates
                                      .where((u) =>
                                          u.userId != null &&
                                          selectedIds.contains(u.userId!))
                                      .map((u) => u.username ?? 'User'));
                                // reset custom splits when participants change
                                _customSplits = {};
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

  // ----------------- helpers -----------------
  String _dateTimeLabel() {
    if (_dateTime == null) return 'Pick date & time';
    final dt = _dateTime!;
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

  double get _totalAmount => double.tryParse(_amountCtrl.text.trim()) ?? 0.0;

  bool get _isCustomValid {
    if (_splitType != 'Custom') return true;
    if (_participantIds.isEmpty) return false;
    if (_customSplits.length != _participantIds.length) return false;
    final sum = _customSplits.values.fold<double>(0.0, (a, b) => a + b);
    return (sum - _totalAmount).abs() < 0.01; // ~cents tolerance
  }

  bool get _canCreate =>
      !_submitting &&
      _titleCtrl.text.trim().isNotEmpty &&
      _dateTime != null &&
      _participantIds.isNotEmpty &&
      _category != null &&
      _totalAmount > 0 &&
      _splitType != null &&
      _isCustomValid;

  Future<void> _editCustomSplit() async {
    if (_participantIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select participants first (Assign To)')),
      );
      return;
    }
    if (_totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter total amount first')),
      );
      return;
    }

    // Initialize missing entries evenly
    final evenShare = _totalAmount / _participantIds.length;
    final local = Map<int, TextEditingController>.fromEntries(
      _participantIds.map((id) => MapEntry(
            id,
            TextEditingController(
              text: (_customSplits[id] ?? evenShare).toStringAsFixed(2),
            ),
          )),
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
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
                    Text('Custom Split (must sum to total)',
                        style: _labelStyle.copyWith(fontSize: 16)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: _participantIds.length,
                        itemBuilder: (context, i) {
                          final id = _participantIds[i];
                          final name = _participantNames[i];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: local[id],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        signed: false, decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}'))
                                ],
                                decoration: _fieldDecoration('Amount'),
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkPurple,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              final map = <int, double>{};
                              for (final id in _participantIds) {
                                final v =
                                    double.tryParse(local[id]!.text.trim()) ??
                                        0.0;
                                map[id] = v;
                              }
                              final sum =
                                  map.values.fold<double>(0.0, (a, b) => a + b);
                              if ((sum - _totalAmount).abs() >= 0.01) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                    'Split total (${sum.toStringAsFixed(2)}) must equal ${_totalAmount.toStringAsFixed(2)}',
                                  )),
                                );
                                return;
                              }
                              setState(() => _customSplits = map);
                              Navigator.pop(ctx);
                            },
                            child: const Text('Save'),
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

  Future<void> _onCreate() async {
    if (!_formKey.currentState!.validate() || !_canCreate) return;
    if (_roomId == null || _currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room ID or User ID not available.')),
      );
      return;
    }

    // Build transactions array
    List<Map<String, dynamic>> transactions;

    if (_splitType == 'Evenly') {
      // Split evenly among all participants
      final amountPerPerson = (_totalAmount / _participantIds.length).round();
      transactions = _participantIds
          .map((id) => {
                'debtor_id': id,
                'total_amount': amountPerPerson,
              })
          .toList();
    } else {
      // Custom split - convert to integers
      transactions = _customSplits.entries
          .map((entry) => {
                'debtor_id': entry.key,
                'total_amount': entry.value.round(),
              })
          .toList();
    }

    final payload = {
      'title_name': _titleCtrl.text.trim(),
      'due_date': _dateTime?.toUtc().toIso8601String(),
      'category': _category,
      'split_type': _splitType == 'Evenly',
      'transactions': transactions,
    };

    if (kDebugMode) {
      debugPrint('AddFinance payload => ${jsonEncode(payload)}');
    }

    setState(() => _submitting = true);
    try {
      await ApiClient.post(
        '/CreateFinanceByPayerID/$_currentUserId',
        data: payload,
      );
      if (!mounted) return;

      setState(() => _submitting = false);

      SuccessPopup.show(
        context,
        message: 'Finance created successfully!',
        onClose: () {
          Navigator.of(context).pop(); // Close popup
          Navigator.pop(context, true); // Close page
        },
        autoCloseDuration: const Duration(seconds: 2),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);

      ErrorPopup.show(
        context,
        message: 'Failed to create finance\nPlease try again',
        showRetryButton: true,
        onRetry: () => _onCreate(), // Retry the same action
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(() => setState(() {}));
    _amountCtrl.addListener(() => setState(() {}));
    _resolveRoomIdFromCacheAndLoadMembers(); // roomId and userId from cache
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
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
        leadingWidth: 80,
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
              const SizedBox(height: 24),

              // Purple "Finance" card
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
                        'Finance',
                        style: _labelStyle.copyWith(color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category (with custom)
                    Text('Category', style: _labelStyle),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
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
                                    hintText: 'e.g., Parking Fee',
                                  ),
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

                    // Total Amount
                    Text('Total Amount', style: _labelStyle),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: false, decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'))
                      ],
                      decoration: _fieldDecoration('Enter Amount'),
                      validator: (v) {
                        final d = double.tryParse((v ?? '').trim());
                        if (d == null || d <= 0) return 'Enter a valid amount';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Assign To (participants) - now inside Finance card
                    Text('Assign To', style: _labelStyle),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickParticipants,
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
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Loading members...'),
                                  ],
                                ),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _participantNames.isEmpty
                                    ? [const Text('Select Roommate(s)')]
                                    : _participantNames
                                        .map(
                                          (name) => InputChip(
                                            label: Text(name),
                                            onDeleted: () {
                                              final idx = _participantNames
                                                  .indexOf(name);
                                              if (idx >= 0 &&
                                                  idx <
                                                      _participantIds.length) {
                                                setState(() {
                                                  _participantNames
                                                      .removeAt(idx);
                                                  _participantIds.removeAt(idx);
                                                  // reset custom splits
                                                  _customSplits = {};
                                                });
                                              }
                                            },
                                          ),
                                        )
                                        .toList(),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Split Type
                    Text('Split Type', style: _labelStyle),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _splitType,
                      items: _splitTypes
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) async {
                        setState(() => _splitType = v);
                        if (v == 'Custom') {
                          await _editCustomSplit();
                        } else {
                          _customSplits = {};
                        }
                      },
                      decoration: _fieldDecoration('Select'),
                      validator: (v) => v == null ? 'Select split type' : null,
                    ),
                    if (_splitType == 'Custom') ...[
                      const SizedBox(height: 8),
                      Text(
                        _isCustomValid
                            ? 'Custom split set'
                            : 'Set custom split (must equal total)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isCustomValid
                              ? Colors.green[800]
                              : Colors.red[800],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
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
