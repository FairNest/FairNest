import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/components/SecondaryButton.dart';

const _confirmCardSize = Size(382, 240);
const _confirmBg = Color(0xFFECE9E6);
const _confirmAccent = Color(0xFF645A80);

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
        elevation: 10,
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: _confirmCardSize.width,
          height: _confirmCardSize.height,
          child: Container(
            decoration: BoxDecoration(
              color: _confirmBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  color: Colors.black.withOpacity(0.12),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header
                Text(
                  'Payment Sent!\nAwaiting Final Confirmation',
                  textAlign: TextAlign.center,
                  style: AppFonts.heading3.copyWith(color: _confirmAccent),
                ),
                const SizedBox(height: 12),

                // Body text
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

                // Okay button
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
    ),
  );
}
