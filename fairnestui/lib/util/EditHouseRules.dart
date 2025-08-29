import 'package:fairnestui/pages/House%20Rules/EditHouseRulePage.dart';
import 'package:fairnestui/util/JoinRequestSubmitted.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/components/MainButton.dart';

/// Opens the House Rules dialog and returns `true` if user confirms.
Future<bool?> showEditHouseRulesDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const EditHouseRulesDialog(),
  );
}

class EditHouseRulesDialog extends StatelessWidget {
  const EditHouseRulesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Material(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header (title + close)
                  Row(
                    children: [
                      const SizedBox(width: 24), // balance close icon width
                      Expanded(
                        child: Text(
                          'House Rules',
                          textAlign: TextAlign.center,
                          // More bold
                          style: AppFonts.heading2.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.of(context).pop(false),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.close,
                              size: 20, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Darker helper text (Krub / Medium / 12)
                  const Text(
                    "These rules are editable later by the group.\nYou're only reviewing the current setup.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Krub',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.4,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _RuleSection(
                            title: 'Quiet Hours',
                            value: '10 PM - 7 PM',
                          ),
                          _RuleSection(
                            title: 'Guest Policy',
                            value: 'Max 1 night/week',
                          ),
                          _RuleSection(
                            title: 'Cleaning & Chores',
                            value: 'Weekly Rotation',
                            extra: 'Shared responsibilities: Kitchen, Bathroom',
                          ),
                          _RuleSection(
                            title: 'Shared Expenses',
                            value: 'Equal Split',
                            extra: 'Payment deadline: 5th of each month',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  MainButton(
                    text: 'Edit House Rule',
                    onPressed: () {
                      // Close the dialog first
                      Navigator.of(context).pop();

                      // Then navigate to EditHouseRulePage
                      Future.microtask(() {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EditHousePage(),
                          ),
                        );
                      });
                    },
                    backgroundColor: const Color(0xFFE8B86D),
                    textColor: Colors.black,
                    width: double.infinity,
                    height: 56,
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

class _RuleSection extends StatelessWidget {
  const _RuleSection({
    required this.title,
    required this.value,
    this.extra,
  });

  final String title;
  final String value;
  final String? extra;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFonts.heading3.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _RulePill(text: value),
          if (extra != null) ...[
            const SizedBox(height: 8),
            _RulePill(text: extra!),
          ],
        ],
      ),
    );
  }
}

class _RulePill extends StatelessWidget {
  const _RulePill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.primary.withOpacity(0.7),
            width: 1.2,
          ),
        ),
        shadows: [
          BoxShadow(
            blurRadius: 6,
            offset: const Offset(0, 2),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Text(
          text,
          style: AppFonts.heading3.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textDark.withOpacity(0.85),
          ),
        ),
      ),
    );
  }
}
