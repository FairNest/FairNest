import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/widgets/room_header_appbar.dart';
import 'package:flutter/material.dart';

class Financepage extends StatefulWidget {
  const Financepage({super.key});

  @override
  State<Financepage> createState() => _FinancepageState();
}

class _FinancepageState extends State<Financepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: RoomHeaderAppBar(
        avatarImage: const AssetImage('assets/images/sample_face.jpg'),
        scoreText: '50 Points',
        progress: 0.5,
        onTapNotifications: () {},
        onTapSettings: () {},
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Finance",
              style: AppFonts.heading1.copyWith(color: AppColors.textPurple),
            ),
            const SizedBox(height: 12),

            const Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Text(
                "My Monthly Snapshot",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPurple,
                ),
              ),
            ),

            // <<< SNAPSHOT CARD >>>
            const MonthlySnapshotCard(
              paid: 1500,
              owed: 50,
              youOwe: 0,
              currency: 'THB',
            ),
          ],
        ),
      ),
    );
  }
}

/// Bordered container with three tiles
class MonthlySnapshotCard extends StatelessWidget {
  const MonthlySnapshotCard({
    super.key,
    required this.paid,
    required this.owed,
    required this.youOwe,
    this.currency = 'THB',

    // sizing controls
    this.tileHeight = 100,
    this.tileWidth = 105, // if null, tiles expand to share width
    this.gap = 25,
    this.panelPadding = const EdgeInsets.all(12),
    this.panelRadius = 8,
  });

  final int paid;
  final int owed;
  final int youOwe;
  final String currency;

  // sizing
  final double tileHeight;
  final double? tileWidth; // set to make tiles less wide
  final double gap;
  final EdgeInsets panelPadding;
  final double panelRadius;

  @override
  Widget build(BuildContext context) {
    Widget buildTile(int value, String label, Color bg) {
      final tile = _SnapshotTile(
        value: value,
        currency: currency,
        label: label,
        bg: bg,
        height: tileHeight,
      );
      // if a fixed width is given, use SizedBox; otherwise Expanded to fill
      return tileWidth != null
          ? SizedBox(width: tileWidth, child: tile)
          : Expanded(child: tile);
    }

    final useFixedWidth = tileWidth != null;

    return Container(
      padding: panelPadding,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E0D5),
        borderRadius: BorderRadius.circular(panelRadius),
        border: Border.all(color: AppColors.textPurple, width: 1),
      ),
      child: Row(
        // spread evenly when fixed tile width is used
        mainAxisAlignment: useFixedWidth
            ? MainAxisAlignment.spaceEvenly
            : MainAxisAlignment.start,
        children: [
          buildTile(paid, 'Paid', const Color(0xFFE2BDD1)),
          if (!useFixedWidth) SizedBox(width: gap),
          buildTile(owed, 'Owed', AppColors.accent),
          if (!useFixedWidth) SizedBox(width: gap),
          buildTile(youOwe, 'You Owe', const Color(0xFF9DCDAA)),
        ],
      ),
    );
  }
}

class _SnapshotTile extends StatelessWidget {
  const _SnapshotTile({
    required this.value,
    required this.currency,
    required this.label,
    required this.bg,
    required this.height,
  });

  final int value;
  final String currency;
  final String label;
  final Color bg;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textPurple, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatWithCommas(value),
            style: const TextStyle(
              color: AppColors.textPurple,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          // const SizedBox(height: 1),
          const Text(
            'THB',
            style: TextStyle(
              color: AppColors.textPurple,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPurple,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatWithCommas(int n) {
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
