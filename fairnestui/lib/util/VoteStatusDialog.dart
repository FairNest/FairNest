import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';

enum VoteState { accepted, rejected, pending }

Future<void> showVoteStatusDialog(
  BuildContext context, {
  required List<VoteState> statuses, // one per member
  required String candidateName, // 👈 new param
  VoidCallback? onClose,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _VoteStatusDialog(
      statuses: statuses,
      candidateName: candidateName,
      onClose: onClose,
    ),
  );
}

class _VoteStatusDialog extends StatelessWidget {
  const _VoteStatusDialog({
    required this.statuses,
    required this.candidateName,
    this.onClose,
  });

  final List<VoteState> statuses;
  final String candidateName; // 👈 dynamic name
  final VoidCallback? onClose;

  static const _titleColor = Color(0xFF645A80);
  static const _green = Color(0xFF34C083);
  static const _red = Color(0xFFD45B4B);
  static const _grey = Color(0xFFB0B0B0);

  Color _colorFor(VoteState s) {
    switch (s) {
      case VoteState.accepted:
        return _green;
      case VoteState.rejected:
        return _red;
      case VoteState.pending:
        return _grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 382,
        height: 392,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title
              Column(
                children: [
                  Text(
                    'Thanks for your vote.',
                    textAlign: TextAlign.center,
                    style: AppFonts.heading3.copyWith(color: _titleColor),
                  ),
                  const SizedBox(height: 10),
                ],
              ),

              // People row + description
              Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24,
                    runSpacing: 16,
                    children: [
                      for (final s in statuses)
                        _PersonIcon(color: _colorFor(s)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "We'll let you know once everyone has voted. "
                    "If the group agrees, $candidateName will be invited to join the room.", // 👈 dynamic
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Krub',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      color: Color(0xFF6C6577),
                    ),
                  ),
                ],
              ),

              // Button
              SizedBox(
                width: 236,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onClose?.call();
                  },
                  child: Text(
                    'Got it',
                    style: AppFonts.heading3.copyWith(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonIcon extends StatelessWidget {
  const _PersonIcon({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/PersonVector.png',
      width: 56,
      height: 56,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.high,
    );
  }
}
