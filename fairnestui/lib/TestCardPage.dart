import 'package:flutter/material.dart';
import 'package:fairnestui/components/SecondaryButton.dart';
import 'package:fairnestui/theme/app_fonts.dart';

// Import your dialogs (adjust the paths if your folder structure is different)
import 'package:fairnestui/util/ConfirmDialog.dart';
import 'package:fairnestui/util/VoteSubmittedDialog.dart';

const _bg = Color(0xFFECE9E6);
const _accent = Color(0xFF645A80);

class TestConfirmVotePage extends StatelessWidget {
  const TestConfirmVotePage({super.key});

  void _openAcceptance(BuildContext context) {
    showConfirmDialog(
      context,
      action: "accept",
      name: "George",
    );
  }

  void _openRejection(BuildContext context) {
    showConfirmDialog(
      context,
      action: "reject",
      name: "George",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        title: Text("Confirm & Vote Test", style: AppFonts.heading3),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SecondaryButton(
              text: "Test Acceptance Flow",
              width: 240,
              onPressed: () => _openAcceptance(context),
            ),
            const SizedBox(height: 20),
            SecondaryButton(
              text: "Test Rejection Flow",
              width: 240,
              backgroundColor: Colors.red.shade400,
              onPressed: () => _openRejection(context),
            ),
          ],
        ),
      ),
    );
  }
}
