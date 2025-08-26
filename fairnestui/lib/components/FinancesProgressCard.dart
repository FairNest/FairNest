import 'package:flutter/material.dart';

class FinancesProgressCard extends StatelessWidget {
  const FinancesProgressCard({
    super.key,
    this.value,
    required this.completedFinances, // settled count
    required this.totalFinances, // total items
    this.title = 'Finances Settled',
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
  final int completedFinances;
  final int totalFinances;

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

  static const int _segments = 5; // fixed: 5 segments (20% each)

  @override
  Widget build(BuildContext context) {
    final double vReal = _computeValue();
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

          // segmented progress (animated)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: vReal),
            duration: duration,
            curve: curve,
            builder: (context, t, _) {
              final bars = <Widget>[];
              for (int i = 0; i < _segments; i++) {
                final segProgress =
                    (t * _segments) - i; // this segment's fill amount
                final fill =
                    segProgress.clamp(0.0, 1.0); // 0..1 of this segment

                bars.add(
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(segmentRadius),
                      child: Stack(
                        children: [
                          // track background
                          Container(height: segmentHeight, color: trackColor),
                          // fill (partial)
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

                if (i != _segments - 1) bars.add(SizedBox(width: segmentGap));
              }
              return Row(children: bars);
            },
          ),

          const SizedBox(height: 10),

          // footer
          Row(
            children: [
              Text(
                '$completedFinances/$totalFinances Finances Settled',
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
    // Prefer counts; fall back to value if total == 0
    if (totalFinances > 0) {
      final safeCompleted = completedFinances.clamp(0, totalFinances);
      return safeCompleted / totalFinances;
    }
    return (value ?? 0).clamp(0.0, 1.0);
  }
}
