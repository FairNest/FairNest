import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';

class LifestyleOverview extends StatelessWidget {
  const LifestyleOverview({
    super.key,
    required this.metrics,
    this.barHeight = 10,
  });

  /// Metrics list: kind + value (0..1). Labels are auto-generated from thresholds.
  final List<LifestyleMetric> metrics;

  /// Height of each progress bar.
  final double barHeight;

  static const _borderColor = Color(0xFF645A80);
  static const _rightLabel = Color(0xFF9C98A1);
  static const _titleColor = Colors.black;
  static const _trackGrey = Color(0xFF8E8B8F);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFECE9E6), // card background
        borderRadius: BorderRadius.circular(8), // radius 8
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < metrics.length; i++) ...[
            _MetricRow(metric: metrics[i], barHeight: barHeight),
            if (i != metrics.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

/* ======================= Data & thresholds ======================= */

enum LifestyleMetricKind {
  tidiness,
  noiseActivity,
  schedule,
  guestFrequency,
  taskStructure,
  moneyAttitude,
}

class LifestyleMetric {
  const LifestyleMetric({
    required this.kind,
    required this.value, // 0.0 – 1.0
    this.title, // optional custom label on the left
    this.rightLabel, // optional override for right text
  });

  final LifestyleMetricKind kind;
  final double value;
  final String? title;
  final String? rightLabel;

  String get resolvedTitle {
    switch (kind) {
      case LifestyleMetricKind.tidiness:
        return title ?? 'Tidiness Level';
      case LifestyleMetricKind.noiseActivity:
        return title ?? 'Noise & Activity';
      case LifestyleMetricKind.schedule:
        return title ?? 'Schedule Type';
      case LifestyleMetricKind.guestFrequency:
        return title ?? 'Guest Frequency';
      case LifestyleMetricKind.taskStructure:
        return title ?? 'Task Structure';
      case LifestyleMetricKind.moneyAttitude:
        return title ?? 'Money Attitude';
    }
  }

  /// Threshold-based right label (unless rightLabel provided)
  String resolvedRightLabel() {
    if (rightLabel != null && rightLabel!.trim().isNotEmpty) return rightLabel!;
    final v = value.clamp(0.0, 1.0);

    switch (kind) {
      case LifestyleMetricKind.noiseActivity:
        if (v < 0.30) return 'Quiet';
        if (v < 0.50) return 'Balanced';
        if (v < 0.80) return 'Noisy';
        return 'Loud';

      case LifestyleMetricKind.tidiness:
        if (v < 0.25) return 'Messy';
        if (v < 0.55) return 'Lived‑in';
        if (v < 0.85) return 'Tidy';
        return 'Clean';

      case LifestyleMetricKind.schedule:
        if (v < 0.30) return 'Early Riser';
        if (v < 0.60) return 'Mixed';
        if (v < 0.85) return 'Night Owl';
        return 'Very Late';

      case LifestyleMetricKind.guestFrequency:
        if (v < 0.20) return 'Rarely';
        if (v < 0.50) return 'Weekly Visitors';
        if (v < 0.80) return 'Often';
        return 'Frequent';

      case LifestyleMetricKind.taskStructure:
        if (v < 0.30) return 'Flexible';
        if (v < 0.60) return 'Light Structure';
        if (v < 0.85) return 'Rotational';
        return 'Strictly Rotated';

      case LifestyleMetricKind.moneyAttitude:
        if (v < 0.30) return 'Easygoing';
        if (v < 0.60) return 'Split Fairly';
        if (v < 0.85) return 'Track Usage';
        return 'Fair Split Required';
    }
  }
}

/* ======================= Row ======================= */

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.metric,
    required this.barHeight,
  });

  final LifestyleMetric metric;
  final double barHeight;

  static const _titleStyle = TextStyle(
    fontFamily: 'Krub',
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: LifestyleOverview._titleColor,
  );

  static const _rightStyle = TextStyle(
    fontFamily: 'Krub',
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: LifestyleOverview._rightLabel,
  );

  @override
  Widget build(BuildContext context) {
    final v = metric.value.clamp(0.0, 1.0);
    final right = metric.resolvedRightLabel();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + right label
        Row(
          children: [
            Expanded(
              child: Text(
                metric.resolvedTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _titleStyle,
              ),
            ),
            const SizedBox(width: 8),
            Text(right, style: _rightStyle, textAlign: TextAlign.right),
          ],
        ),
        const SizedBox(height: 8),

        // Progress bar
        LayoutBuilder(
          builder: (context, constraints) {
            final fullW = constraints.maxWidth;
            final filledW = fullW * v;

            return SizedBox(
              height: barHeight,
              child: Stack(
                children: [
                  // Track (grey)
                  Container(
                    width: fullW,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: LifestyleOverview._trackGrey,
                      borderRadius: BorderRadius.circular(barHeight),
                    ),
                  ),
                  // Filled (pink)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    width: filledW,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(barHeight),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
