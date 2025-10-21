import 'package:fairnestui/pages/FindRoommate/GroupHomePage.dart';
import 'package:fairnestui/pages/FindRoommate/RequestJoinRoomPage.dart';
import 'package:fairnestui/pages/room_creation/create_room_flow.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';

// Import the request join room page
import 'package:fairnestui/services/api_client.dart';

class GroupCheckPage extends StatelessWidget {
  const GroupCheckPage({
    super.key,
    this.onCreateGroup,
    this.onFindRoommate,
    this.onJoinByCodeSubmit,
  });

  final VoidCallback? onCreateGroup;
  final VoidCallback? onFindRoommate;
  final void Function(String code)? onJoinByCodeSubmit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _OptionCard(
                  title: 'Create a Room',
                  assetPath: 'assets/images/Add Male User Group.png',
                  bgColor: AppColors.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateRoomFlow()),
                    );
                  },
                ),
                const SizedBox(height: 36),
                _OptionCard(
                  title: 'Find Roommate',
                  assetPath: 'assets/images/User Groups.png',
                  bgColor: AppColors.secondary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GroupHomePage()),
                    );
                  },
                ),
                const SizedBox(height: 36),
                _OptionCard(
                  title: 'Join by Code',
                  assetPath: 'assets/images/Invite.png',
                  bgColor: AppColors.accent,
                  onTap: () => _showJoinByCodeDialog(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ----------------- Widgets ----------------- */

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.title,
    required this.assetPath,
    required this.bgColor,
    this.onTap,
  });

  final String title;
  final String assetPath;
  final Color bgColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const double boxSize = 150;
    const double iconSize = 80;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: boxSize,
            width: boxSize,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Image.asset(
                assetPath,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A3F5C),
          ),
        ),
      ],
    );
  }
}

/* ----------------- Dialog ----------------- */

Future<void> _showJoinByCodeDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return const _JoinByCodeDialog();
    },
  );
}

class _JoinByCodeDialog extends StatefulWidget {
  const _JoinByCodeDialog();

  @override
  State<_JoinByCodeDialog> createState() => _JoinByCodeDialogState();
}

class _JoinByCodeDialogState extends State<_JoinByCodeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a code')),
      );
      return;
    }

    // Save references before async operations
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Close the dialog
    navigator.pop();

    // Show loading dialog
    showDialog(
      context: navigator.context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Call the API to get room details by code
      final response = await ApiClient.get(
        '/GetRoomDetailsByRoomCode/$code',
      );

      // Close loading indicator
      navigator.pop();

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final roomId = data['room_id'] as int;

        // Navigate to the request join room page
        navigator.push(
          MaterialPageRoute(
            builder: (_) => Requestjoinroompage(
              roomId: roomId,
              showBack: true,
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading indicator
      navigator.pop();

      // Show error message
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Invalid room code or room not found'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            const Text(
              'Enter the Code',
              style: TextStyle(
                color: Color(0xFF4A3F5C),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            // Input
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Your code',
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.6),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.textDark,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _handleSubmit,
                child: const Text(
                  'Submit',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
