import 'package:fairnestui/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AccentBorderedCard extends StatelessWidget {
  const AccentBorderedCard({
    super.key,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    required this.child,
    this.backgroundColor = AppColors.background,
    this.borderColor = const Color(0xFFE7AC66), // accent
    this.borderWidth = 3,
    this.borderRadius = 12,
    this.onTap,
    // keep these so your calls don’t break; only shadowOpacity is used now
    this.shadowOpacity = 0.35,
    this.shadowBlur = 1, // (ignored with Card)
    this.shadowOffset = const Offset(11, 11), // (ignored with Card)
    this.shadowSpread = -1, // (ignored with Card)
    this.elevation = 6, // simple Material shadow control
  });

  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final VoidCallback? onTap;

  // shadow tuning (only shadowOpacity is applied to the Card’s shadowColor)
  final double shadowOpacity;
  final double shadowBlur; // not used with Card
  final Offset shadowOffset; // not used with Card
  final double shadowSpread; // not used with Card
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(borderRadius);

    return Padding(
      padding: margin,
      child: SizedBox(
        width: width,
        height: height,
        child: Card(
          color: backgroundColor,
          surfaceTintColor: Colors.transparent, // no M3 tint
          elevation: elevation,
          shadowColor:
              borderColor.withOpacity(shadowOpacity), // your accent color
          shape: RoundedRectangleBorder(
            borderRadius: r,
            side: BorderSide(color: borderColor, width: borderWidth),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: r,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
