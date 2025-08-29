import 'package:fairnestui/components/ChoresTaskCard.dart';
import 'package:fairnestui/components/FInanceTaskCard.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TaskNavFolder extends StatefulWidget {
  const TaskNavFolder({
    super.key,
    this.panelHeight = 520,

    // counts for the header badge
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

  static const _cream = Color(0xFFFFF1E8);
  final tabs = const [
    {"label": "Today", "color": Color(0xFFFADDE1)}, // pink
    {"label": "Completed", "color": Color(0xFFD6F2DB)}, // green
    {"label": "Upcoming", "color": Color(0xFFD6DFF2)}, // lavender
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
        return widget.todayUnfinishedCount;
      case 1:
        return widget.completedCount;
      case 2:
        return widget.upcomingUnfinishedCount;
      default:
        return 0;
    }
  }

  Widget _buildTabContent(BuildContext context) {
    switch (activeIndex) {
      case 0: // TODAY
        return SingleChildScrollView(
          key: const PageStorageKey('todayScroll'),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Financetaskcard(
                paidByImage: AssetImage('assets/images/char.png'),
              ),
              SizedBox(height: 10),
            ],
          ),
        );

      case 1: // COMPLETED
        return SingleChildScrollView(
          key: const PageStorageKey('completedScroll'),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              ChoresTaskCard(
                paidByImage: AssetImage('assets/images/char.png'),
              ),
              SizedBox(height: 400),
            ],
          ),
        );

      case 2: // UPCOMING
        return SingleChildScrollView(
          key: const PageStorageKey('upcomingScroll'),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              // ===== REPLACE BELOW WITH YOUR "UPCOMING" CARDS =====
              SizedBox(height: 8),
              Text("TODO: Add UPCOMING tab content here",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45)),
              SizedBox(height: 400),
              // ====================================================
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
  // -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.panelHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (instant update)
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

                // MAIN AREA (blank bg + SingleChildScrollView from switch)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background, // your bg
                        borderRadius: BorderRadius.circular(12), // soft corners
                        border: Border.all(
                          color: Colors.black45, // subtle 1px border
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.04), // tiny elevation
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
      scale: _scale, // spring pop on tap
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
            duration: const Duration(milliseconds: 160), // animate tab visuals
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
