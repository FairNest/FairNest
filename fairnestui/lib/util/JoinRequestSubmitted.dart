import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/components/MainButton.dart';

/// Opens the "request submitted / voting" popup.
Future<void> showJoinRequestSubmittedDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const JoinRequestSubmittedDialog(),
  );
}

class JoinRequestSubmittedDialog extends StatelessWidget {
  const JoinRequestSubmittedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Material(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    "Almost there! Your future roommates\nare voting on your request.",
                    textAlign: TextAlign.center,
                    style: AppFonts.heading2.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Body text
                  Text(
                    "We’ll notify you as soon as the final decision is made.\n"
                    "You can check back here to see the voting progress in real time.",
                    textAlign: TextAlign.center,
                    style: AppFonts.body1.copyWith(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.textDark.withValues(alpha: .85),
                    ),
                  ),

                  const SizedBox(height: 16),

                  MainButton(
                    text: 'Okay', // <- just "Okay"
                    onPressed: () => Navigator.of(context).maybePop(),
                    backgroundColor: const Color(0xFFE8B86D),
                    textColor: Colors.black,
                    width: double.infinity,
                    height: 48,
                    borderRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
