// vote_popup_demo_page.dart
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
// import the dialog you created earlier
import 'package:fairnestui/util/VoteStatusDialog.dart';
// ^ adjust path to where you put showVoteStatusDialog & VoteState

class VotePopupDemoPage extends StatelessWidget {
  const VotePopupDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vote Popup Demo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.black,
            minimumSize: const Size(180, 46),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () async {
            await showVoteStatusDialog(
              context,
              // Example: 5 members (1 accepted, 1 rejected, the rest pending)
              statuses: const [
                VoteState.accepted,
                VoteState.pending,
                VoteState.rejected,
              ],
              candidateName: "Panita",
            );
          },
          child: const Text('Show popup'),
        ),
      ),
    );
  }
}
