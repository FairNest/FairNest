import 'package:fairnestui/auth/SignUpPage.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/auth/login_page.dart';
import 'package:fairnestui/components/MainButton.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    super.key,
    this.onTapSignUp,
  });

  final VoidCallback? onTapSignUp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            const _Blob(
              color: AppColors.accent,
              size: 140,
              top: 8,
              right: -20,
              angle: -0.2,
            ),
            const _Blob(
              color: AppColors.coral,
              size: 110,
              left: -16,
              top: 140,
              angle: 0.35,
            ),
            const _Blob(
              color: AppColors.pinkSoft,
              size: 120,
              right: -22,
              top: 260,
              angle: 0.15,
            ),
            const _Blob(
              color: AppColors.neutralSage,
              size: 160,
              bottom: -30,
              left: 70,
              angle: -0.15,
            ),
            const _Blob(
              color: AppColors.primary,
              size: 120,
              left: -28,
              bottom: 120,
              angle: -0.6,
              hollow: true,
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/fairnest.png',
                      height: 360,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 32),

                    // Sign Up button using MainButton
                    MainButton(
                      text: 'Sign Up',
                      backgroundColor: AppColors.primary,
                      textColor: AppColors.textDark,
                      width: double.infinity,
                      height: 56,
                      borderRadius: 12,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Log In button (still outlined for now)
                    _OutlinedButtonCustom(
                      label: 'Log In',
                      border: AppColors.primary,
                      textColor: AppColors.textDark,
                      background: AppColors.background,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.color,
    required this.size,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.angle = 0,
    this.hollow = false,
  });

  final Color color;
  final double size;
  final double? top, left, right, bottom;
  final double angle;
  final bool hollow;

  @override
  Widget build(BuildContext context) {
    final child = Transform.rotate(
      angle: angle,
      child: Container(
        width: size,
        height: size * 0.7,
        decoration: BoxDecoration(
          color: hollow ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(size),
          border: hollow ? Border.all(color: color, width: 6) : null,
        ),
      ),
    );

    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: child,
    );
  }
}

class _OutlinedButtonCustom extends StatelessWidget {
  const _OutlinedButtonCustom({
    required this.label,
    required this.border,
    required this.textColor,
    required this.background,
    this.onPressed,
  });

  final String label;
  final Color border;
  final Color textColor;
  final Color background;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: border, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: background,
          foregroundColor: textColor,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
