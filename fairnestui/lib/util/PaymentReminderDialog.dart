import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/components/SecondaryButton.dart';

// Shared colors
const _bg = Color(0xFFECE9E6);
const _accent = Color(0xFF645A80);

// --- Payment Sent Dialog (chained) ---
Future<void> showPaymentSentDialog(
  BuildContext context, {
  required String payer,
  required String receiver,
  required String amount,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: 382,
          height: 240,
          decoration: BoxDecoration(
            color: _bg,
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
              Text(
                'Payment Sent!\nAwaiting Final Confirmation',
                textAlign: TextAlign.center,
                style: AppFonts.heading3.copyWith(color: _accent),
              ),
              const SizedBox(height: 12),
              Text(
                'We’ve notified $receiver that you’ve marked $amount as paid. '
                'Once $payer confirms receipt, this expense will be marked as '
                'settled in your group finance records.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Krub',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              SecondaryButton(
                text: 'Okay',
                backgroundColor: const Color(0xFFE7AC66),
                textColor: Colors.white,
                width: double.infinity,
                height: 44,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// --- Payment Reminder Dialog ---
Future<void> showPaymentReminderDialog(
  BuildContext context, {
  required String fromName,
  required String amount,
}) {
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
          height: 220,
          decoration: BoxDecoration(
            color: _bg,
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
              Text(
                'Payment Reminder from $fromName',
                textAlign: TextAlign.center,
                style: AppFonts.heading3.copyWith(color: _accent),
              ),
              const SizedBox(height: 8),
              Text(
                '$fromName just sent you a nudge about the $amount you owe. '
                'Settle up when you can!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Krub',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'Okay, Later',
                      backgroundColor: const Color(0xFF8D8B8B),
                      textColor: Colors.white,
                      width: double.infinity,
                      height: 44,
                      onPressed: () => Navigator.of(rootContext).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SecondaryButton(
                      text: 'Settle Now',
                      backgroundColor: const Color(0xFF5CC38A),
                      textColor: Colors.white,
                      width: double.infinity,
                      height: 44,
                      onPressed: () {
                        Navigator.of(rootContext).pop(); // close reminder
                        Future.microtask(() {
                          showPaymentSentDialog(
                            rootContext,
                            payer: 'Max',
                            receiver: fromName,
                            amount: amount,
                          );
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
