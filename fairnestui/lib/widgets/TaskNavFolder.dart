import 'package:fairnestui/components/ChoresTaskCard.dart';
import 'package:fairnestui/components/FInanceTaskCard.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// simple local model for demo items
class _ChoreTask {
  _ChoreTask({required this.id, this.isCompleted = false});
  final String id;
  bool isCompleted;
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

  // ✅ Initialize lists here (no 'late', no initState needed)
  final List<_ChoreTask> _todayTasks = [
    _ChoreTask(id: 'trash'),
    _ChoreTask(id: 'dishes'),
  ];
  final List<_ChoreTask> _completedTasks = [];
  final List<_ChoreTask> _upcomingTasks = [
    _ChoreTask(id: 'laundry'),
  ];

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
        return _todayTasks.length;
      case 1:
        return _completedTasks.length;
      case 2:
        return _upcomingTasks.length;
      default:
        return 0;
    }
  }

  // move a task based on checkbox state
  void _onCheckedChanged(_ChoreTask task, bool checked,
      {required int fromTab}) {
    setState(() {
      task.isCompleted = checked;

      // remove from current list
      if (fromTab == 0) {
        _todayTasks.removeWhere((t) => t.id == task.id);
      } else if (fromTab == 1) {
        _completedTasks.removeWhere((t) => t.id == task.id);
      } else if (fromTab == 2) {
        _upcomingTasks.removeWhere((t) => t.id == task.id);
      }

      // add to destination + jump tab
      if (checked) {
        _completedTasks.add(task);
        activeIndex = 1;
      } else {
        _todayTasks.add(task);
        activeIndex = 0;
      }
    });
  }

  // render a chores card wired to the mover
  Widget _buildChoreCard(_ChoreTask task, int sourceTab) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ChoresTaskCard(
        paidByImage: const AssetImage('assets/images/char.png'),
        initiallyChecked: task.isCompleted,
        onCheckedChanged: (checked) =>
            _onCheckedChanged(task, checked, fromTab: sourceTab),
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
              const Financetaskcard(
                paidByImage: AssetImage('assets/images/char.png'),
              ),
              const SizedBox(height: 10),
              for (final t in _todayTasks) _buildChoreCard(t, 0),
              if (_todayTasks.isEmpty)
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
              for (final t in _completedTasks) _buildChoreCard(t, 1),
              if (_completedTasks.isEmpty)
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
              for (final t in _upcomingTasks) _buildChoreCard(t, 2),
              if (_upcomingTasks.isEmpty)
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
                    color: Color(0xFF9C2D3C),
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
                            color: Colors.black.withOpacity(0.04),
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
                  color: Colors.black.withOpacity(isActive ? 0.18 : 0.12),
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
