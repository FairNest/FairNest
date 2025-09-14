import 'package:fairnestui/components/AccentBorderedCard.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Roommatecompatibilitycard extends StatelessWidget {
  const Roommatecompatibilitycard({
    super.key,
    this.avatarImage,
    this.avatarColor, // optional ring/bg color
    required this.name, // "Max"
    required this.compatibilityPercent, // 0..100 -> "88%"
    required this.traits, // short bullets in the purple tile
    required this.insights, // long bullet paragraphs below
  });

  // --- data fields for this design ---
  final ImageProvider? avatarImage;
  final Color? avatarColor;
  final String name;

  final int compatibilityPercent;
  final List<String> traits;
  final List<String> insights;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: AccentBorderedCard(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 5),

              // Avatar + name
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 21),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: (avatarColor ?? AppColors.textOrange)
                        .withValues(alpha: .6),
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 60,
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.textPurple,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 10),

              // Main panel (same size as your original)
              SizedBox(
                height: 100,
                width: 260,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFF645A80), width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFDED6CB),
                  ),
                  child: Row(
                    children: [
                      // ---- Compatibility tile (kept your 80x70 box proportions) ----
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
                        child: SizedBox(
                          height: 80,
                          width: 70,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFF645A80), width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.primary,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$compatibilityPercent%',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPurple,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Compatibility',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPurple,
                                  ),
                                ),
                                const Text(
                                  'Match',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ---- Traits tile (replaces Finance/Tasks) ----
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFF645A80), width: 2),
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFFC9BDE6), // light lavender
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // 🔁 replaced placeholder loop here:
                                  for (final t in traits)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 3),
                                      child: _TraitBullet(t),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )._withInsights(insights),
      ),
    ); // attach insights below panel
  }
}

// ---- helper extension to append insights bullets under the main row ----
extension on Widget {
  Widget _withInsights(List<String> insights) {
    const double gap = 12.0; // ← increase/decrease to taste

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        this,
        if (insights.isNotEmpty) const SizedBox(height: gap),
        // bullets with larger spacing between items
        ...List.generate(insights.length, (i) {
          final s = insights[i];
          final isLast = i == insights.length - 1;
          return Padding(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: isLast ? 0 : gap, // ← extra space between bullets
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '•',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.35,
                    color: AppColors.textPurple,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.40, // a touch more line-height looks nicer
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPurple,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ---- tiny builder to render trait bullets properly ----
class _TraitBullet extends StatelessWidget {
  const _TraitBullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFF645A80),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppColors.textPurple,
            ),
          ),
        ),
      ],
    );
  }
}
