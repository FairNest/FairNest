import 'package:flutter/material.dart';

class RoomCompatibilityCard extends StatelessWidget {
  const RoomCompatibilityCard({
    super.key,
    required this.value, // 0.0 .. 1.0
    this.title = 'Room Compatibility',
    this.subtitle = 'Average Compatibility Score',
    this.height = 110,
    this.bgColor = const Color(0xFFE8E0F2), // card bg
    this.barFill = const Color(0xFFDDA45A), // fill color
    this.barTrack = const Color(0xFFF6EDE6), // track color
    this.icon = const Icon(Icons.favorite, size: 18, color: Color(0xFFAB4D1E)),
    this.visualOffset = 0.0, // same idea as ScorePill; set ~0.08 if you want
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOut,
  });

  final double value;
  final String title;
  final String subtitle;
  final double height;
  final Color bgColor;
  final Color barFill;
  final Color barTrack;
  final Widget icon;

  // new (optional) animation cosmetics to mirror ScorePill
  final double visualOffset;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final pReal = value.clamp(0.0, 1.0);
    // fade boost as it nears 1.0 (mirrors your ScorePill behavior)
    final scaledOffset = visualOffset * (1 - pReal);
    final pVisual = (pReal + scaledOffset).clamp(0.0, 1.0);
    final pct = (pReal * 100).round();

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
          // Title row
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1E8),
                  shape: BoxShape.circle,
                ),
                child: Center(child: icon),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFAB4D1E),
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 10),

          // === Progress bar (SAME approach as ScorePill) ===
          // Rounded-rect track + animated fill using fraction
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Track stays visible
                Container(
                  height: 16,
                  color: barTrack,
                ),
                // Animate the FRACTION directly (like ScorePill)
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: pVisual),
                  duration: duration,
                  curve: curve,
                  builder: (context, animatedP, _) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: animatedP,
                        child: Container(
                          height: 16,
                          color: barFill,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Footer row
          Row(
            children: [
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFAB4D1E),
                ),
              ),
              const Spacer(),
              Text(
                '$pct%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFAB4D1E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
