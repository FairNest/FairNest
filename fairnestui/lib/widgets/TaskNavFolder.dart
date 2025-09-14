import 'package:fairnestui/components/ChoresTaskCard.dart';
import 'package:fairnestui/components/FInanceTaskCard.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// --- simple local models ---
class _ChoreTask {
  _ChoreTask({
    required this.id,
    this.isCompleted = false,
    // configurable display fields for ChoresTaskCard
    required this.title,
    required this.points,
    required this.assignedName,
    required this.autoRotate,
    required this.recurrence,
    required this.reminderTime,
    required this.reminderRepeat,
    required this.avatar,
  });

  final String id;
  bool isCompleted;

  // ui data
  final String title;
  final int points;
  final String assignedName;
  final bool autoRotate;
  final String recurrence;
  final String reminderTime;
  final String reminderRepeat;
  final ImageProvider avatar;
}

class _FinanceTask {
  _FinanceTask({
    required this.id,
    required this.title,
    required this.amount, // this person's share (header, right)
    required this.totalAmount, // full bill, shown in "Total" chip
    required this.points, // +X badge
    required this.splitType,
    this.splitCount, // needed for even splits
    this.currency = 'THB',
    required this.payToName,
    this.avatar,
    this.isSettled = false,
  });

  final String id;
  final String title;
  final int amount;
  final int totalAmount;
  final int points;
  final SplitType splitType;
  final int? splitCount;
  final String currency;
  final String payToName;
  final ImageProvider? avatar;
  bool isSettled;
}

class TaskNavFolder extends StatefulWidget {
  const TaskNavFolder({
    super.key,
    this.panelHeight = 520,
    required this.todayUnfinishedCount,
    required this.completedCount,
    required this.upcomingUnfinishedCount,
  });

  final double panelHeight;
  final int todayUnfinishedCount;
  final int completedCount;
  final int upcomingUnfinishedCount;

  @override
  State<TaskNavFolder> createState() => _TaskNavFolderState();
}

class _TaskNavFolderState extends State<TaskNavFolder> {
  int activeIndex = 0;

  // ------- demo data -------
  final List<_ChoreTask> _todayChores = [
    _ChoreTask(
      id: 'trash',
      title: 'Take Out the Trash',
      points: 10,
      assignedName: 'Max',
      autoRotate: true,
      recurrence: 'Weekly',
      reminderTime: '4PM',
      reminderRepeat: 'Every Tue',
      avatar: const AssetImage('assets/images/char.png'),
    ),
    _ChoreTask(
      id: 'dishes',
      title: 'Wash Dishes',
      points: 8,
      assignedName: 'Lando',
      autoRotate: false,
      recurrence: 'Daily',
      reminderTime: '8PM',
      reminderRepeat: 'Every Day',
      avatar: const AssetImage('assets/images/pikachu.png'),
    ),
  ];
  final List<_ChoreTask> _completedChores = [];

  final List<_FinanceTask> _todayFinances = [
    _FinanceTask(
      id: 'water',
      title: 'Water Bill',
      amount: 400,
      totalAmount: 1200,
      points: 10,
      splitType: SplitType.even,
      splitCount: 3,
      currency: 'THB',
      payToName: 'Max',
      avatar: const AssetImage('assets/images/char.png'),
    ),
  ];
  final List<_FinanceTask> _completedFinances = [];

  final List<_ChoreTask> _upcomingChores = [
    _ChoreTask(
      id: 'laundry',
      title: 'Do Laundry',
      points: 6,
      assignedName: 'George',
      autoRotate: true,
      recurrence: 'Weekly',
      reminderTime: '6PM',
      reminderRepeat: 'Every Sun',
      avatar: const AssetImage('assets/images/char.png'),
    ),
  ];
  final List<_FinanceTask> _upcomingFinances = [];

  static const _cream = Color(0xFFFFF1E8);
  final tabs = const [
    {"label": "Today", "color": Color(0xFFFADDE1)},
    {"label": "Completed", "color": Color(0xFFD6F2DB)},
    {"label": "Upcoming", "color": Color(0xFFD6DFF2)},
  ];

  String _headerTitle() {
    switch (activeIndex) {
      case 0:
        return "Current Tasks";
      case 1:
        return "Completed Tasks";
      case 2:
        return "Upcoming Tasks";
      default:
        return "Tasks";
    }
  }

  int _headerCount() {
    switch (activeIndex) {
      case 0:
        return _todayChores.length + _todayFinances.length;
      case 1:
        return _completedChores.length + _completedFinances.length;
      case 2:
        return _upcomingChores.length + _upcomingFinances.length;
      default:
        return 0;
    }
  }

  // ------- chore checkbox handler -------
  void _onChoreChecked(_ChoreTask task, bool checked, {required int fromTab}) {
    setState(() {
      task.isCompleted = checked;

      // remove from current bucket
      if (fromTab == 0) {
        _todayChores.removeWhere((t) => t.id == task.id);
      } else if (fromTab == 1) {
        _completedChores.removeWhere((t) => t.id == task.id);
      } else {
        _upcomingChores.removeWhere((t) => t.id == task.id);
      }

      // add to destination + switch tab
      if (checked) {
        _completedChores.add(task);
        activeIndex = 1;
      } else {
        _todayChores.add(task);
        activeIndex = 0;
      }
    });
  }

  // ------- finance settle handler (stay in place) -------
  void _onFinanceSettled(_FinanceTask fin, {required int fromTab}) {
    setState(() {
      fin.isSettled = true;
      List<_FinanceTask> bucket;
      if (fromTab == 0) {
        bucket = _todayFinances;
      } else if (fromTab == 2) {
        bucket = _upcomingFinances;
      } else {
        bucket = _completedFinances;
      }
      bucket.removeWhere((f) => f.id == fin.id);
      bucket.add(fin); // push to end for little feedback
    });
  }

  // ------- builders -------
  Widget _buildChoreCard(_ChoreTask task, int sourceTab) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ChoresTaskCard(
        // new configurable values
        title: task.title,
        points: task.points,
        assignedName: task.assignedName,
        autoRotate: task.autoRotate,
        recurrence: task.recurrence,
        reminderTime: task.reminderTime,
        reminderRepeat: task.reminderRepeat,
        paidByImage: task.avatar,

        // existing behavior
        initiallyChecked: task.isCompleted,
        onCheckedChanged: (checked) =>
            _onChoreChecked(task, checked, fromTab: sourceTab),
      ),
    );
  }

  Widget _buildFinanceCard(_FinanceTask f, int sourceTab) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Financetaskcard(
        title: f.title,
        amount: f.amount,
        totalAmount: f.totalAmount,
        points: f.points,
        splitType: f.splitType,
        splitCount: f.splitCount,
        currency: f.currency,
        payToName: f.payToName,
        paidByImage: f.avatar,
        onSettled: () => _onFinanceSettled(f, fromTab: sourceTab),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    switch (activeIndex) {
      case 0: // TODAY
        return SingleChildScrollView(
          key: const PageStorageKey('todayScroll'),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final f in _todayFinances) _buildFinanceCard(f, 0),
              for (final t in _todayChores) _buildChoreCard(t, 0),
              if (_todayChores.isEmpty && _todayFinances.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    "No tasks for today 🎉",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        );

      case 1: // COMPLETED
        return SingleChildScrollView(
          key: const PageStorageKey('completedScroll'),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final f in _completedFinances) _buildFinanceCard(f, 1),
              for (final t in _completedChores) _buildChoreCard(t, 1),
              if (_completedChores.isEmpty && _completedFinances.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    "Nothing completed yet.",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        );

      case 2: // UPCOMING
        return SingleChildScrollView(
          key: const PageStorageKey('upcomingScroll'),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final f in _upcomingFinances) _buildFinanceCard(f, 2),
              for (final t in _upcomingChores) _buildChoreCard(t, 2),
              if (_upcomingChores.isEmpty && _upcomingFinances.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    "No upcoming tasks.",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // ------- UI -------
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.panelHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
            child: Row(
              children: [
                Text(
                  _headerTitle(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C2D3C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _headerCount().toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sidebar tabs
                SizedBox(
                  width: 60,
                  child: Column(
                    children: List.generate(tabs.length, (i) {
                      final tab = tabs[i];
                      return Expanded(
                        child: _SideTab(
                          label: tab["label"] as String,
                          baseColor: tab["color"] as Color,
                          isActive: activeIndex == i,
                          activeColor: _cream,
                          onTap: () => setState(() => activeIndex = i),
                        ),
                      );
                    }),
                  ),
                ),

                // Main area
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black45, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildTabContent(context),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideTab extends StatefulWidget {
  const _SideTab({
    required this.label,
    required this.baseColor,
    required this.isActive,
    required this.onTap,
    this.activeColor = const Color(0xFFFFF1E8),
  });

  final String label;
  final Color baseColor;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;

  @override
  State<_SideTab> createState() => _SideTabState();
}

class _SideTabState extends State<_SideTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 120),
    );
    _scale = Tween(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pop, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isActive;

    return ScaleTransition(
      scale: _scale,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          splashColor: Colors.black12,
          onTap: () async {
            await _pop.forward(from: 0);
            if (mounted) _pop.reverse();
            widget.onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: isActive ? widget.activeColor : widget.baseColor,
              border: isActive
                  ? Border.all(color: Colors.black45, width: 1.5)
                  : null,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isActive ? 0.18 : 0.12),
                  blurRadius: isActive ? 6 : 4,
                  offset: Offset(0, isActive ? 3 : 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: RotatedBox(
              quarterTurns: -1,
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
