// ADD near your other imports
import 'package:fairnestui/theme/app_colors.dart';
import 'package:flutter/material.dart';

// ----------------- enum for status -----------------
enum BalanceStatus { owedToYou, youOwe, settled }

// ----------------- Outstanding Balance Card -----------------
class OutstandingBalanceCard extends StatelessWidget {
  const OutstandingBalanceCard({
    super.key,
    required this.name,
    required this.amount,
    this.currency = 'THB',
    this.avatar,
    required this.status,

    // sizing
    this.width = 140,
    this.avatarSize = 56,
    this.badgeHeight = 34,
  });

  final String name;
  final int amount;
  final String currency;
  final ImageProvider? avatar;
  final BalanceStatus status;

  final double width;
  final double avatarSize;
  final double badgeHeight;

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

  // Keep text readable on the light badges
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // avatar
            CircleAvatar(
              radius: avatarSize / 2,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: avatar,
              child: avatar == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 8),

            // name
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

            // amount badge (color varies by status)
            Container(
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
          ],
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
