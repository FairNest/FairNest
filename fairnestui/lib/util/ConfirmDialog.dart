import 'package:fairnestui/util/VoteSubmittedDialog.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/components/SecondaryButton.dart';

const _cardBg = Color(0xFFECE9E6);
const _accent = Color(0xFF645A80);

Future<void> showConfirmDialog(
  BuildContext context, {
  required String action, // "accept" or "reject"
  required String name, // e.g. "George"
  VoidCallback?
      onYesAfterPopup, // optional callback after showing VoteSubmitted popup
  VoidCallback? onNo, // optional callback for No
}) {
  final isAcceptance = action.toLowerCase() == "accept";
  final rootContext = context;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: 382,
          height: 200,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                offset: const Offset(0, 6),
                color: Colors.black.withValues(alpha: .12),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Text(
                "Confirm ${isAcceptance ? "Acceptance" : "Rejection"}",
                textAlign: TextAlign.center,
                style: AppFonts.heading3.copyWith(color: _accent),
              ),
              const SizedBox(height: 12),

              // Body
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Krub',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                  children: [
                    const TextSpan(text: "Are you sure you want to "),
                    TextSpan(
                      text: action.toLowerCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: " $name as your roommate?\n"),
                    const TextSpan(
                      text:
                          "Your vote will be recorded and can’t be changed later",
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'No',
                      backgroundColor: const Color(0xFFB14D1F),
                      textColor: Colors.white,
                      width: double.infinity,
                      height: 44,
                      onPressed: () {
                        Navigator.of(rootContext).pop();
                        onNo?.call();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SecondaryButton(
                      text: 'Yes!',
                      backgroundColor: const Color(0xFF6CC08B),
                      textColor: Colors.white,
                      width: double.infinity,
                      height: 44,
                      onPressed: () {
                        Navigator.of(rootContext).pop(); // close confirm
                        Future.microtask(() async {
                          await showVoteSubmittedDialog(rootContext);
                          onYesAfterPopup?.call();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
