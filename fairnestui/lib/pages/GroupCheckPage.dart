import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';

class GroupCheckPage extends StatelessWidget {
  const GroupCheckPage({
    super.key,
    this.onCreateGroup,
    this.onFindRoommate,
    this.onJoinByCodeSubmit, // returns the code entered in the dialog
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
                  title: 'Create Group',
                  assetPath: 'assets/images/Add Male User Group.png',
                  bgColor: AppColors.primary,
                  onTap: onCreateGroup,
                ),
                const SizedBox(height: 36),
                _OptionCard(
                  title: 'Find Roommate',
                  assetPath: 'assets/images/User Groups.png',
                  bgColor: AppColors.secondary,
                  onTap: onFindRoommate,
                ),
                const SizedBox(height: 36),
                _OptionCard(
                  title: 'Join by Code',
                  assetPath: 'assets/images/Invite.png',
                  bgColor: AppColors.accent,
                  onTap: () =>
                      _showJoinByCodeDialog(context, onJoinByCodeSubmit),
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
    // Big, Pixel-6-friendly sizes
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
            color: Color(0xFF4A3F5C), // deep purple for headings
          ),
        ),
      ],
    );
  }
}

/* ----------------- Dialog ----------------- */

Future<void> _showJoinByCodeDialog(
  BuildContext context,
  void Function(String code)? onSubmit,
) async {
  final controller = TextEditingController();
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Dialog(
        backgroundColor: AppColors.background, // peach card like your mock
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
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Your code',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 1.6),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 1.6),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
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
                    backgroundColor: AppColors.secondary, // pink button
                    foregroundColor: AppColors.textDark,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final code = controller.text.trim();
                    if (code.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a code')),
                      );
                      return;
                    }
                    Navigator.of(ctx).pop();
                    onSubmit?.call(code);
                  },
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
    },
  );
  controller.dispose();
}
