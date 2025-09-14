import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_fonts.dart';

const _voteBg = Color(0xFFECE9E6);
const _voteAccent = Color(0xFF645A80);

Future<void> showVoteSubmittedDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => Center(
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: 382,
          height: 170,
          decoration: BoxDecoration(
            color: _voteBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                offset: const Offset(0, 6),
                color: Colors.black.withValues(alpha: .12),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header
              Text(
                'Vote Submitted',
                textAlign: TextAlign.center,
                style: AppFonts.heading3.copyWith(color: _voteAccent),
              ),
              const SizedBox(height: 12),
              // Body (Krub, medium, 12px)
              const Text(
                "Thanks for your vote! We’ll notify you once all\n"
                "roommates have voted and the decision is finalized.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Krub',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
