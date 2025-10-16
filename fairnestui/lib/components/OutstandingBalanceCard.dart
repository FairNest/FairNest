import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';

// existing reminder dialog
import 'package:fairnestui/util/reminderDialog.dart' show showReminderDialog;

import 'package:fairnestui/util/paymentSentDialog.dart'
    show showPaymentSentDialog;

enum BalanceStatus { owedToYou, youOwe, settled }

class OutstandingBalanceCard extends StatelessWidget {
  const OutstandingBalanceCard({
    super.key,
    required this.name,
    required this.amount,
    this.currency = 'THB',
    this.avatar,
    required this.status,
    this.width = 140,
    this.avatarSize = 56,
    this.badgeHeight = 34,
    this.onTap,
    this.qrData,
  });

  final String name;
  final int amount;
  final String currency;
  final ImageProvider? avatar;
  final BalanceStatus status;

  final double width;
  final double avatarSize;
  final double badgeHeight;

  final VoidCallback? onTap;
  final String? qrData;

  Color get _badgeColor {
    switch (status) {
      case BalanceStatus.owedToYou:
        return AppColors.accent; // amber
      case BalanceStatus.youOwe:
        return const Color(0xFF9DCDAA); // green
      case BalanceStatus.settled:
        return const Color(0xFFE2BDD1); // lavender
    }
  }

  Color get _badgeTextColor => AppColors.textPurple;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.textPurple, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: avatarSize / 2,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: avatar,
              child: avatar == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPurple,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),

            // amount badge (tap target)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onTap ?? () => _handleTap(context),
                child: Container(
                  height: badgeHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _badgeColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.textPurple, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${_fmt(amount)} $currency',
                    style: TextStyle(
                      color: _badgeTextColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Actions ----------
  Future<void> _handleTap(BuildContext context) async {
    switch (status) {
      case BalanceStatus.owedToYou:
        await showReminderDialog(context, name: name);
        break;
      case BalanceStatus.youOwe:
        await _showQrSheet(context);
        break;
      case BalanceStatus.settled:
        await _showInfoSheet(context);
        break;
    }
  }

  Future<void> _showQrSheet(BuildContext context) async {
    // keep a handle to the parent context for showing the dialog after closing the sheet
    final rootContext = context;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pay ${_fmt(amount)} $currency',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.textPurple,
                  ),
                ),
                const SizedBox(height: 12),

                // QR placeholder—swap with a real QR later
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.textPurple.withValues(alpha: .0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    qrData ?? 'QR CODE',
                    style: const TextStyle(
                      color: AppColors.textPurple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                const Text(
                  'Scan this code with your banking app to settle.',
                  style: TextStyle(
                    color: AppColors.textPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetCtx),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          // 1) close the sheet
                          Navigator.pop(sheetCtx);
                          // 2) then show your Payment Sent dialog
                          Future.microtask(() {
                            showPaymentSentDialog(
                              rootContext,
                              payer: 'You', // or your current user
                              receiver: name, // the roommate you're paying
                              amount: '${_fmt(amount)} $currency',
                            );
                          });
                        },
                        child: const Text('Verify'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showInfoSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'All settled!',
                style: TextStyle(
                  color: AppColors.textPurple,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'No action needed for this roommate.',
                style: TextStyle(color: AppColors.textPurple),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      count++;
      if (count == 3 && i != 0) {
        buf.write(',');
        count = 0;
      }
    }
    return buf.toString().split('').reversed.join();
  }
}
