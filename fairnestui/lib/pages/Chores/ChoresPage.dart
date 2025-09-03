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

class _ChorespageState extends State<Chorespage> {
  // calendar state for DateStrip
  late DateTime _start;
  late DateTime _selected;
  final int _days = 30;

  // segmented pill state + demo counts
  int _tab = 0; // 0 = All Tasks, 1 = My Tasks
  int _allCount = 6; // example
  int _myCount = 2; // example

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _start = DateTime(now.year, now.month, 1);
    _selected = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: RoomHeaderAppBar(
        avatarImage: const AssetImage('assets/images/sample_face.jpg'),
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

            // Horizontal date strip
            DateStrip(
              startDate: _start,
              days: _days,
              selectedDate: _selected,
              onDateSelected: (d) => setState(() => _selected = d),
            ),
            const SizedBox(height: 12),

            // Segmented pill with counts — tweak sizes here
            _CountSegmentedPill(
              tabs: const ['All Tasks', 'My Tasks'],
              counts: [_allCount, _myCount],
              initialIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),

              // size controls
              height: 46, // overall pill height
              labelFontSize: 14, // "All Tasks" / "My Tasks"
              badgeHeight: 22, // badge height
              // badgeWidth: 28,        // (optional) fixed width; comment out to use padding
              badgeFontSize: 12, // number font
              badgeRadius: 8, // badge corner radius
              badgeHorizontalPadding:
                  7, // inner padding left/right (when width is null)
            ),

            const SizedBox(height: 16),

            // Each tab gets its own scrollable area — add your cards here
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: const [
                  _AllTasksContent(),
                  _MyTasksContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------- Page content placeholders ---------- */

class _AllTasksContent extends StatelessWidget {
  const _AllTasksContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: const [
          _EmptyArea(label: 'All Tasks page — add your content here'),
        ],
      ),
    );
  }
}

class _MyTasksContent extends StatelessWidget {
  const _MyTasksContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: const [
          _EmptyArea(label: 'My Tasks page — add your content here'),
        ],
      ),
    );
  }
}

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

/* ---------- Segmented pill with counts (tunable sizes) ---------- */

class _CountSegmentedPill extends StatefulWidget {
  const _CountSegmentedPill({
    required this.tabs,
    required this.counts,
    required this.onChanged,
    this.initialIndex = 0,
    this.height = 44,

    // sizing knobs
    this.labelFontSize = 14,
    this.badgeHeight = 22,
    this.badgeWidth, // optional fixed width; if null we use padding
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

  // size controls
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

  // palette
  static const Color _trackPink = Color(0xFFFF8FB5); // background track
  static const Color _thumbCream = AppColors.background; // cream thumb
  static const Color _labelPurple = AppColors.textPurple; // label color
  static const Color _badgeFill = AppColors.textPink; // badge fill
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
            // Sliding thumb
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

            // Labels + badges
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
                              // Unselected now purple too (no pink)
                              color: _labelPurple,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _MiniCountBadge(
                            value: widget.counts[i],
                            height: widget.badgeHeight,
                            width: widget.badgeWidth, // set to fix width
                            radius: widget.badgeRadius,
                            fontSize: widget.badgeFontSize,
                            paddingH: widget
                                .badgeHorizontalPadding, // used only if width == null
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
    this.height = 20, // badge height
    this.width =
        15, // optional fixed width; if null, width = content + paddingH
    this.radius = 2, // defaults to height/2
    this.fontSize = 12,
    this.paddingH = 10, // used only when width is null
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
      // Fixed width badge
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

    // Content-driven width (number + padding)
    return Container(
      height: height,
      constraints: BoxConstraints(minWidth: height), // keep square-ish min
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
