import 'package:flutter/material.dart';

/// A reusable rounded card with an accent-colored border.
/// - Default borderColor: 0xFFE7AC66
/// - Default radius: 12
/// - Default borderWidth: 3
class AccentBorderedCard extends StatelessWidget {
  const AccentBorderedCard({
    super.key,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    required this.child,
    this.backgroundColor = const Color(0xFFFFF7EE), // soft warm background
    this.borderColor = const Color(0xFFE7AC66),
    this.borderWidth = 3,
    this.borderRadius = 12,
    this.onTap,
    this.shadow,
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
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: shadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
