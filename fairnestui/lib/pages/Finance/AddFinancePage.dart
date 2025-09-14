import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fairnestui/theme/app_colors.dart';

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
  final List<String> _participants = []; // Assign To
  String? _category;
  final _amountCtrl = TextEditingController();
  String? _splitType; // Evenly | Custom
  final List<String> _paidBy = []; // multi-select (as requested)

  // for custom splits: name -> amount
  Map<String, double> _customSplits = {};

  // sample data
  final _roommates = const ['Ayu', 'Bima', 'Chai', 'Dewi', 'Eka'];
  final _categories = const [
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
    if (date == null) return;

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

  Future<void> _pickPeople({
    required List<String> current,
    required ValueChanged<List<String>> onDone,
    String title = 'Select Roommate(s)',
  }) async {
    final selected = Set<String>.from(current);

    await showModalBottomSheet(
      context: context,
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
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 12),
                    Text(title, style: _labelStyle.copyWith(fontSize: 16)),
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
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              onDone(selected.toList());
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
    setState(() {}); // refresh chips
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
    if (_participants.isEmpty) return false;
    if (_customSplits.length != _participants.length) return false;
    final sum = _customSplits.values.fold<double>(0.0, (a, b) => a + b);
    return (sum - _totalAmount).abs() < 0.01; // ~cents tolerance
  }

  bool get _canCreate =>
      _titleCtrl.text.trim().isNotEmpty &&
      _dateTime != null &&
      _participants.isNotEmpty &&
      _category != null &&
      _totalAmount > 0 &&
      _splitType != null &&
      _paidBy.isNotEmpty &&
      _isCustomValid;

  Future<void> _editCustomSplit() async {
    if (_participants.isEmpty) {
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
    final evenShare = _totalAmount / _participants.length;
    final local = Map<String, TextEditingController>.fromEntries(
      _participants.map((p) => MapEntry(
            p,
            TextEditingController(
              text: (_customSplits[p] ?? evenShare).toStringAsFixed(2),
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
                      child: ListView(
                        controller: scrollController,
                        children: [
                          for (final p in _participants) ...[
                            Text(p,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: local[p],
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
                        ],
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
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              final map = <String, double>{};
                              for (final p in _participants) {
                                final v =
                                    double.tryParse(local[p]!.text.trim()) ??
                                        0.0;
                                map[p] = v;
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

  void _onCreate() {
    if (!_formKey.currentState!.validate() || !_canCreate) return;

    final payload = {
      'title': _titleCtrl.text.trim(),
      'dateTime': _dateTime?.toIso8601String(),
      'participants': _participants,
      'category': _category,
      'totalAmount': _totalAmount,
      'splitType': _splitType,
      'customSplits': _splitType == 'Custom' ? _customSplits : null,
      'paidBy': _paidBy,
    };

    Navigator.pop(context, payload);
  }

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(() => setState(() {}));
    _amountCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: const Text(
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

              // Assign To (participants)
              Text('Assign To', style: _labelStyle),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _pickPeople(
                  current: _participants,
                  onDone: (list) => setState(() {
                    _participants
                      ..clear()
                      ..addAll(list);
                    // reset custom splits if participants change
                    _customSplits = {};
                  }),
                ),
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: _fieldDecoration('Select Roommate(s)'),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _participants.isEmpty
                        ? [const Text('Select Roommate(s)')]
                        : _participants
                            .map(
                              (name) => InputChip(
                                label: Text(name),
                                onDeleted: () =>
                                    setState(() => _participants.remove(name)),
                              ),
                            )
                            .toList(),
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

                    // Split Type
                    Text('Split Type', style: _labelStyle),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _splitType,
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

                    // Paid By (multi-select as requested)
                    Text('Paid By', style: _labelStyle),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _pickPeople(
                        current: _paidBy,
                        onDone: (list) => setState(() {
                          _paidBy
                            ..clear()
                            ..addAll(list);
                        }),
                        title: 'Select Payer(s)',
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: _fieldDecoration('Select Roommate(s)'),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _paidBy.isEmpty
                              ? [const Text('Select Roommate(s)')]
                              : _paidBy
                                  .map(
                                    (name) => InputChip(
                                      label: Text(name),
                                      onDeleted: () =>
                                          setState(() => _paidBy.remove(name)),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
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
