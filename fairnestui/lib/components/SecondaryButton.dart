import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_fonts.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFFB14D1F), // default brownish-red
    this.textColor = Colors.white,
    this.width = 200,
    this.height = 48,
  });

  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.2),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppFonts.heading3.copyWith(color: textColor),
        ),
      ),
    );
  }
}
