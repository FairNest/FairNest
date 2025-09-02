import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/theme/app_colors.dart';

class RoomComponentsCard extends StatelessWidget {
  const RoomComponentsCard({
    super.key,
    required this.title,
    required this.description, // trimmed to max 20 words
    required this.memberCount,
    required this.memberMax,
    required this.compatibilityPct, // 0–100
    this.imageUrl, // 🔑 added for room_picture
    this.userIconAsset = 'assets/images/User Account.png',
    this.compatIconAsset = 'assets/images/Heart Puzzle.png',
    this.width = 381,
    this.height = 210,
    this.onTap,
  });

  final String title;
  final String description;
  final int memberCount;
  final int memberMax;
  final num compatibilityPct;
  final String? imageUrl; // new optional image URL

  final String userIconAsset;
  final String compatIconAsset;

  final double width;
  final double height;
  final VoidCallback? onTap;

  static const _lavenderBorder = Color(0xFF645A80);
  static const _pinkTextIcon = Color(0xFFB84B6A);
  static const _orangeText = Color(0xFFC34C04);

  @override
  Widget build(BuildContext context) {
    final trimmedDesc = _limitWords(description, 20);
    final radius = BorderRadius.circular(8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFECE9E6),
            borderRadius: radius,
            border: Border.all(color: _lavenderBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: image area + badges (responsive)
              LayoutBuilder(
                builder: (context, constraints) {
                  const double badgesW = 63; // fixed
                  final double imageW = (constraints.maxWidth - badgesW - 10)
                      .clamp(0, constraints.maxWidth);

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Picture area (network image or fallback box)
                      SizedBox(
                        width: imageW,
                        height: 110,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: imageUrl != null && imageUrl!.isNotEmpty
                              ? Image.network(
                                  imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[400],
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.image_not_supported,
                                        color: Colors.white70),
                                  ),
                                )
                              : Container(
                                  color: Colors.grey[400],
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image,
                                      color: Colors.white70),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Right-side stacked badges
                      SizedBox(
                        width: badgesW,
                        child: Column(
                          children: [
                            _Badge(
                              background: AppColors.secondary,
                              textColor: _pinkTextIcon,
                              label: '$memberCount/$memberMax',
                              trailing: _assetIcon(
                                userIconAsset,
                                color: _pinkTextIcon,
                                size: 18,
                                allowTint: true,
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'Krub',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                              height: 28,
                            ),
                            const SizedBox(height: 8),
                            _Badge(
                              background: AppColors.accent,
                              textColor: _orangeText,
                              label: '${compatibilityPct.toString()}%',
                              trailing: _assetIcon(
                                compatIconAsset,
                                color: _orangeText,
                                size: 18,
                                allowTint: true,
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'Krub',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                              height: 28,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 12),

              // Title: Heading 3 + lavender color
              Text(
                title,
                style: AppFonts.heading3.copyWith(color: _lavenderBorder),
              ),

              const SizedBox(height: 6),

              // Description: Krub / semibold / 11px (max 20 words)
              Text(
                trimmedDesc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Krub',
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Color(0xFF6C6577),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _assetIcon(
    String path, {
    Color? color,
    double size = 18,
    bool allowTint = true,
  }) {
    return Image.asset(
      path,
      width: size,
      height: size,
      color: allowTint ? color : null,
      colorBlendMode: allowTint ? BlendMode.srcIn : null,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  static String _limitWords(String text, int maxWords) {
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length <= maxWords) return text;
    return '${words.take(maxWords).join(' ')}…';
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.background,
    required this.textColor,
    required this.label,
    required this.textStyle,
    this.trailing,
    this.width = 63,
    this.height = 28,
  });

  final Color background;
  final Color textColor;
  final String label;
  final TextStyle textStyle;
  final double width;
  final double height;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // hug text + icon
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: textStyle.copyWith(color: textColor),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 4),
            trailing!,
          ],
        ],
      ),
    );
  }
}
