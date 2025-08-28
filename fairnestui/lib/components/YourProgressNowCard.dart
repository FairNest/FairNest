import 'package:fairnestui/theme/app_colors.dart';
import 'package:flutter/material.dart';

class YourProgressNowCard extends StatelessWidget {
  const YourProgressNowCard({
    super.key,
    this.value,
    required this.completedTasks,
    required this.totalTasks,

    // Texts
    this.title = 'Your progress now',
    this.leftFooterLabel = 'Tasks Complete',

    // Layout
    this.height = 145,
    this.padding = const EdgeInsets.all(14),

    // Visuals
    this.bgColor = AppColors.primary,
    this.headerColor = const Color(0xFF645A80),
    this.fillColor = const Color(0xFF645A80),
    this.trackColor = const Color(0xFFFFF1E8),

    // Segments
    this.segmentCount,
    this.segmentHeight = 12,
    this.segmentRadius = 20,
    this.segmentGap = 10,

    // Animation
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOut,
  });

  final double? value;
  final int completedTasks;
  final int totalTasks;

  final String title;
  final String leftFooterLabel;

  final double height;
  final EdgeInsets padding;
  final Color bgColor;
  final Color headerColor;
  final Color fillColor;
  final Color trackColor;

  final int? segmentCount;
  final double segmentHeight;
  final double segmentRadius;
  final double segmentGap;

  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final double vReal = _computeValue();
    final int pct = (vReal * 100).round();
    final int segs = _computeSegments();
    final int completedShown = completedTasks.clamp(0, totalTasks);

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with fixed star icon + title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.background, // cream circle
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  "⭐",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: headerColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Segmented progress
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: vReal),
            duration: duration,
            curve: curve,
            builder: (context, t, _) {
              final bars = <Widget>[];
              for (int i = 0; i < segs; i++) {
                final segProgress = (t * segs) - i;
                final fill = segProgress.clamp(0.0, 1.0);

                bars.add(
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(segmentRadius),
                      child: Stack(
                        children: [
                          Container(height: segmentHeight, color: trackColor),
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

                if (i != segs - 1) bars.add(SizedBox(width: segmentGap));
              }
              return Row(children: bars);
            },
          ),

          const SizedBox(height: 8),

          // Footer
          Row(
            children: [
              Text(
                '$completedShown/$totalTasks $leftFooterLabel',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: headerColor,
                ),
              ),
              const Spacer(),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: headerColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _computeValue() {
    if (value != null) return value!.clamp(0.0, 1.0);
    if (totalTasks <= 0) return 0.0;
    return completedTasks.clamp(0, totalTasks) / totalTasks;
  }

  int _computeSegments() {
    final int segs = segmentCount ?? (totalTasks > 0 ? totalTasks : 6);
    return segs.clamp(3, 10);
  }
}
