import 'package:fairnestui/components/MainButton.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';

class EditChorePage extends StatefulWidget {
  const EditChorePage({
    super.key,
    // prefilled values
    required this.title,
    required this.dateTime,
    required this.assignees,
    required this.category,
    required this.recurrence,
    required this.autoRotate,
  });

  final String title;
  final DateTime? dateTime;
  final List<String> assignees;
  final String? category;
  final String? recurrence;
  final bool autoRotate;

  @override
  State<EditChorePage> createState() => _EditChorePageState();
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

  final _roommates = const ['Ayu', 'Bima', 'Chai', 'Dewi', 'Eka'];
  final _categories = const [
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
          borderSide: BorderSide(color: AppColors.accent, width: 1.8),
        ),
      );

  // pickers ----------
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
                    Expanded(
                      child: ListView.builder(
                        itemCount: _roommates.length,
                        itemBuilder: (context, i) {
                          final name = _roommates[i];
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
                            title: Text(name),
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
                    ),
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

  // helpers ----------
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

  bool get _canSave =>
      _titleCtrl.text.trim().isNotEmpty &&
      (_dateTime ?? widget.dateTime) != null &&
      (_category ?? widget.category) != null &&
      (_recurrence ?? widget.recurrence) != null &&
      (_autoRotate ?? (widget.autoRotate ? 'Yes' : 'No')) != null;

  void _onSave() {
    if (!_formKey.currentState!.validate() || !_canSave) return;

    final payload = {
      'title': _titleCtrl.text.trim(),
      'dateTime': (_dateTime ?? widget.dateTime)?.toIso8601String(),
      'assignees': _assignees,
      'category': _category ?? widget.category,
      'recurrence': _recurrence ?? widget.recurrence,
      'autoRotate':
          (_autoRotate ?? (widget.autoRotate ? 'Yes' : 'No')) == 'Yes',
    };
    Navigator.pop(context, {'action': 'save', 'data': payload});
  }

  void _onDelete() {
    // Return a simple signal; caller can perform API delete.
    Navigator.pop(context, {'action': 'delete'});
  }

  @override
  void initState() {
    super.initState();
    _dateTime = widget.dateTime;
    _category = widget.category;
    _recurrence = widget.recurrence;
    _autoRotate = widget.autoRotate ? 'Yes' : 'No';
    _titleCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      child: Text(
                        'Chores',
                        style: _labelStyle.copyWith(color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category (with custom)
                    Text('Category', style: _labelStyle),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _category,
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
                            setState(() => _category = custom);
                          } else {
                            setState(() => _category = null);
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
