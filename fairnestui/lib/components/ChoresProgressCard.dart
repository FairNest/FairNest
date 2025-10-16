import 'package:flutter/material.dart';

class ChoresProgressCard extends StatelessWidget {
  const ChoresProgressCard({
    super.key,
    // Drive progress by either completedTasks/totalTasks (recommended) or by value
    this.value,
    required this.completedTasks,
    required this.totalTasks,
    this.title = 'Chores',
    this.height = 110,

    // visuals
    this.bgColor = const Color(0xFFE8E0F2), // lavender card bg
    this.fillColor = const Color(0xFF645A80), // dark purple fill
    this.trackColor = const Color(0xFFFFF1E8), // light cream track
    this.segmentHeight = 14,
    this.segmentRadius = 20,
    this.segmentGap = 10,

    // animation
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOut,
  });

  // inputs
  final double? value;
  final int completedTasks;
  final int totalTasks;

  // ui
  final String title;
  final double height;
  final Color bgColor;
  final Color fillColor;
  final Color trackColor;

  // segment style (always 5 segments; 20% each)
  final double segmentHeight;
  final double segmentRadius;
  final double segmentGap;

  // animation
  final Duration duration;
  final Curve curve;

  static const int _segments = 5;

  @override
  Widget build(BuildContext context) {
    // Check for empty state (0/0)
    final bool isEmpty = totalTasks == 0;

    if (isEmpty) {
      return Container(
        height: height,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // title
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF645A80),
              ),
            ),
            const SizedBox(height: 16),
            // Empty state message with icon
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: fillColor.withOpacity(0.6),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'No Tasks Today',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: fillColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Normal state with progress
    final double vReal = _computeValue();
    final int completedShown = completedTasks ?? (vReal * totalTasks).round();
    final int pct = (vReal * 100).round();

    return Container(
      height: height,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF645A80),
            ),
          ),
          const SizedBox(height: 12),

          // segmented progress
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: vReal),
            duration: duration,
            curve: curve,
            builder: (context, t, _) {
              final bars = <Widget>[];
              for (int i = 0; i < _segments; i++) {
                final segProgress =
                    (t * _segments) - i; // how much this segment is filled
                final fill =
                    segProgress.clamp(0.0, 1.0); // 0..1 of this segment

                bars.add(
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(segmentRadius),
                      child: Stack(
                        children: [
                          // track (background stays visible)
                          Container(height: segmentHeight, color: trackColor),
                          // fill (partial width per segment)
                          if (fill > 0)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: fill,
                                child: Container(
                                  height: segmentHeight,
                                  color: fillColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );

                if (i != _segments - 1) {
                  bars.add(SizedBox(width: segmentGap));
                }
              }
              return Row(children: bars);
            },
          ),

          const SizedBox(height: 10),

          // footer
          Row(
            children: [
              Text(
                '$completedShown/$totalTasks Tasks Completed',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF645A80),
                ),
              ),
              const Spacer(),
              Text(
                '$pct%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF645A80),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _computeValue() {
    if (completedTasks != null) {
      if (totalTasks <= 0) return 0;
      final clamped = completedTasks!.clamp(0, totalTasks);
      return clamped / totalTasks;
    }
    return (value ?? 0).clamp(0.0, 1.0);
  }
}
