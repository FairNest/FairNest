import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_fonts.dart';

class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFFE8B86D),
    this.textColor = Colors.black,
    this.width = 339,
    this.height = 64,
    this.borderRadius = 12,
    this.fontWeight = FontWeight.w600,
  });

  final String text;
  final VoidCallback? onPressed; // Changed to nullable
  final Color backgroundColor;
  final Color textColor;
  final double width;
  final double height;
  final double borderRadius;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null
              ? backgroundColor.withOpacity(0.6) // Disabled state
              : backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: onPressed == null ? 2 : 6,
          shadowColor: Colors.black.withOpacity(0.25),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppFonts.heading3.copyWith(
            color: onPressed == null
                ? textColor.withOpacity(0.6) // Disabled text color
                : textColor,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}
