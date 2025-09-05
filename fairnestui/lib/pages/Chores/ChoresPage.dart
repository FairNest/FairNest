import 'package:fairnestui/components/ChoresTaskCard.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/widgets/room_header_appbar.dart';
import 'package:fairnestui/util/DateStrip.dart';

class Chorespage extends StatefulWidget {
  const Chorespage({super.key});

  @override
  State<Chorespage> createState() => _ChorespageState();
}

/* ------------------- simple local chore model ------------------- */
class _Chore {
  _Chore({
    required this.id,
    required this.title,
    required this.points,
    required this.assignedTo,
    required this.autoRotate,
    required this.recurrence,
    required this.reminderTime,
    required this.reminderRepeat,
    required this.avatar,
    this.completed = false,
  });

  final String id;
  final String title;
  final int points;
  final String assignedTo; // "George", "Max", ...
  final bool autoRotate;
  final String recurrence; // "Weekly", "Daily", ...
  final String reminderTime; // "4PM"
  final String reminderRepeat; // "Every Tue"
  final ImageProvider avatar;

  bool completed;
}

class _ChorespageState extends State<Chorespage> {
  // who is the current user for "My Tasks"
  static const String _currentUser = 'George';

  // calendar state for DateStrip (not filtering by date yet)
  late DateTime _start;
  late DateTime _selected;
  final int _days = 30;

  // segmented pill state
  int _tab = 0; // 0 = All Tasks, 1 = My Tasks

  // demo data (6 chores total, 2 assigned to George)
  final List<_Chore> _chores = [
    _Chore(
      id: 'trash',
      title: 'Take Out the Trash',
      points: 10,
      assignedTo: 'Max',
      autoRotate: true,
      recurrence: 'Weekly',
      reminderTime: '4PM',
      reminderRepeat: 'Every Tue',
      avatar: const AssetImage('assets/images/char.png'),
    ),
    _Chore(
      id: 'dishes',
      title: 'Wash Dishes',
      points: 8,
      assignedTo: 'George',
      autoRotate: false,
      recurrence: 'Daily',
      reminderTime: '8PM',
      reminderRepeat: 'Every Day',
      avatar: const AssetImage('assets/images/poke.png'),
    ),
    _Chore(
      id: 'sweep',
      title: 'Sweep Living Room',
      points: 6,
      assignedTo: 'George',
      autoRotate: true,
      recurrence: 'Weekly',
      reminderTime: '7PM',
      reminderRepeat: 'Every Fri',
      avatar: const AssetImage('assets/images/poke.png'),
    ),
    _Chore(
      id: 'bathroom',
      title: 'Clean Bathroom',
      points: 12,
      assignedTo: 'Lando',
      autoRotate: true,
      recurrence: 'Biweekly',
      reminderTime: '6PM',
      reminderRepeat: 'Every Other Sat',
      avatar: const AssetImage('assets/images/pikachu.png'),
    ),
    _Chore(
      id: 'groceries',
      title: 'Buy Groceries',
      points: 5,
      assignedTo: 'Max',
      autoRotate: false,
      recurrence: 'Weekly',
      reminderTime: '5PM',
      reminderRepeat: 'Every Thu',
      avatar: const AssetImage('assets/images/char.png'),
    ),
    _Chore(
      id: 'plants',
      title: 'Water Plants',
      points: 4,
      assignedTo: 'Lando',
      autoRotate: false,
      recurrence: 'Every 3 days',
      reminderTime: '9AM',
      reminderRepeat: 'Mon / Thu',
      avatar: const AssetImage('assets/images/pikachu.png'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _start = DateTime(now.year, now.month, 1);
    _selected = DateTime(now.year, now.month, now.day);
  }

  /* ------------------- derived lists & counts ------------------- */
  List<_Chore> get _openAll =>
      _chores.where((c) => !c.completed).toList(growable: false);

  List<_Chore> get _openMine => _openAll
      .where((c) => c.assignedTo.toLowerCase() == _currentUser.toLowerCase())
      .toList(growable: false);

  int get _allCount => _openAll.length;
  int get _myCount => _openMine.length;

  /* ------------------- handlers ------------------- */
  void _onCheckedChanged(_Chore chore, bool checked) {
    // When a chore is checked we mark it completed and it disappears from view
    if (!checked) return; // ignore unchecks here (they won't be shown anyway)
    setState(() => chore.completed = true);
  }

  /* ------------------- builders ------------------- */
  Widget _buildList(List<_Chore> items) {
    if (items.isEmpty) {
      return const _EmptyArea(label: 'No chores here 🎉');
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          for (final c in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ChoresTaskCard(
                // configurable values — make sure your ChoresTaskCard exposes these
                title: c.title,
                points: c.points,
                assignedName: c.assignedTo,
                autoRotate: c.autoRotate,
                recurrence: c.recurrence,
                reminderTime: c.reminderTime,
                reminderRepeat: c.reminderRepeat,
                paidByImage: c.avatar,

                initiallyChecked: false,
                onCheckedChanged: (checked) => _onCheckedChanged(c, checked),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: RoomHeaderAppBar(
        scoreText: '50 Points',
        progress: 0.5,
        onTapNotifications: () {},
        onTapSettings: () {},
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Chores & Tasks",
              style: AppFonts.heading1.copyWith(color: AppColors.textPurple),
            ),
            const SizedBox(height: 12),

            // Horizontal date strip (visual only for now)
            DateStrip(
              startDate: _start,
              days: _days,
              selectedDate: _selected,
              onDateSelected: (d) => setState(() => _selected = d),
            ),
            const SizedBox(height: 12),

            // Segmented pill with LIVE counts
            _CountSegmentedPill(
              tabs: const ['All Tasks', 'My Tasks'],
              counts: [_allCount, _myCount], // ← live numbers
              initialIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),

              // size controls
              height: 46,
              labelFontSize: 14,
              badgeHeight: 22,
              badgeFontSize: 12,
              badgeRadius: 8,
              badgeHorizontalPadding: 7,
            ),

            const SizedBox(height: 16),

            // content per tab
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  _buildList(_openAll), // All Tasks (incomplete only)
                  _buildList(_openMine), // My Tasks (incomplete + mine)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ------------------- empty state box ------------------- */

class _EmptyArea extends StatelessWidget {
  const _EmptyArea({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.textPurple.withOpacity(0.25)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/* ------------------- segmented pill (unchanged) ------------------- */

class _CountSegmentedPill extends StatefulWidget {
  const _CountSegmentedPill({
    required this.tabs,
    required this.counts,
    required this.onChanged,
    this.initialIndex = 0,
    this.height = 44,
    this.labelFontSize = 14,
    this.badgeHeight = 22,
    this.badgeWidth,
    this.badgeFontSize = 12,
    this.badgeRadius = 8,
    this.badgeHorizontalPadding = 7,
    super.key,
  }) : assert(tabs.length == counts.length);

  final List<String> tabs;
  final List<int> counts;
  final int initialIndex;
  final ValueChanged<int> onChanged;
  final double height;

  final double labelFontSize;
  final double badgeHeight;
  final double? badgeWidth;
  final double badgeFontSize;
  final double badgeRadius;
  final double badgeHorizontalPadding;

  @override
  State<_CountSegmentedPill> createState() => _CountSegmentedPillState();
}

class _CountSegmentedPillState extends State<_CountSegmentedPill> {
  late int _index = widget.initialIndex;

  static const Color _trackPink = Color(0xFFFF8FB5);
  static const Color _thumbCream = AppColors.background;
  static const Color _labelPurple = AppColors.textPurple;
  static const Color _badgeFill = AppColors.textPink;
  static const EdgeInsets _padding = EdgeInsets.all(6);

  Alignment _alignmentFor(int i, int len) {
    if (len <= 1) return Alignment.center;
    final step = 2.0 / (len - 1);
    return Alignment(-1.0 + i * step, 0);
  }

  @override
  Widget build(BuildContext context) {
    final tabCount = widget.tabs.length.clamp(1, 6);

    return SizedBox(
      width: double.infinity,
      child: Container(
        height: widget.height,
        padding: _padding,
        decoration: BoxDecoration(
          color: _trackPink,
          borderRadius: BorderRadius.circular(widget.height),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: _alignmentFor(_index, tabCount),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: FractionallySizedBox(
                widthFactor: 1 / tabCount,
                heightFactor: 1,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: _thumbCream,
                    borderRadius: BorderRadius.circular(widget.height),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: List.generate(tabCount, (i) {
                final selected = i == _index;
                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(widget.height),
                    onTap: () {
                      if (_index != i) {
                        setState(() => _index = i);
                        widget.onChanged(i);
                      }
                    },
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.tabs[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.heading1.copyWith(
                              fontSize: widget.labelFontSize,
                              fontWeight: FontWeight.w700,
                              color: _labelPurple,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _MiniCountBadge(
                            value: widget.counts[i],
                            height: widget.badgeHeight,
                            width: widget.badgeWidth,
                            radius: widget.badgeRadius,
                            fontSize: widget.badgeFontSize,
                            paddingH: widget.badgeHorizontalPadding,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniCountBadge extends StatelessWidget {
  const _MiniCountBadge({
    required this.value,
    this.height = 20,
    this.width,
    this.radius = 2,
    this.fontSize = 12,
    this.paddingH = 10,
  });

  final int value;
  final double height;
  final double? width;
  final double? radius;
  final double fontSize;
  final double paddingH;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? height / 2;
    final decoration = BoxDecoration(
      color: _CountSegmentedPillState._badgeFill,
      borderRadius: BorderRadius.circular(r),
    );

    if (width != null) {
      return Container(
        height: height,
        width: width,
        decoration: decoration,
        alignment: Alignment.center,
        child: Text(
          '$value',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: fontSize,
          ),
        ),
      );
    }

    return Container(
      height: height,
      constraints: BoxConstraints(minWidth: height),
      padding: EdgeInsets.symmetric(horizontal: paddingH),
      decoration: decoration,
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
