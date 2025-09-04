import 'package:fairnestui/components/OutstandingBalanceCard.dart';
import 'package:fairnestui/components/TransactionCard.dart';
import 'package:fairnestui/components/UpcomingPaymentCard.dart';
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
    // ---- Upcoming payments data (sorted by daysLeft) ----
    final payments = <_Payment>[
      _Payment(title: "Water Bill", amount: 100, daysLeft: 2),
      _Payment(title: "Electricity Bill", amount: 1200, daysLeft: 15),
      _Payment(title: "Netflix Subscription", amount: 499, daysLeft: 12),
    ]..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: RoomHeaderAppBar(
        avatarImage: const AssetImage('assets/images/sample_face.jpg'),
        scoreText: '50 Points',
        progress: 0.5,
        onTapNotifications: () {},
        onTapSettings: () {},
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
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
              const MonthlySnapshotCard(
                paid: 1500,
                owed: 400,
                youOwe: 20,
                currency: 'THB',
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Text(
                  "Outstanding Balances",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPurple,
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: const [
                    SizedBox(width: 4), // left inset
                    OutstandingBalanceCard(
                      name: 'Max',
                      amount: 400,
                      currency: 'THB',
                      avatar: AssetImage('assets/images/char.png'),
                      status: BalanceStatus.owedToYou,
                      width: 140,
                    ),
                    SizedBox(width: 14),
                    OutstandingBalanceCard(
                      name: 'Lando',
                      amount: 20,
                      currency: 'THB',
                      avatar: AssetImage('assets/images/pikachu.png'),
                      status: BalanceStatus.youOwe,
                      width: 140,
                    ),
                    SizedBox(width: 14),
                    SizedBox(width: 4), // right inset
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // ------- Upcoming Payments header with count badge -------
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Upcoming Payments",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPurple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _CountChip(value: payments.length),
                  ],
                ),
              ),

              // ------- Cards -------
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 4), // left inset
                    for (int i = 0; i < payments.length; i++)
                      UpcomingPaymentCard(
                        title: payments[i].title,
                        amount: payments[i].amount,
                        daysLeft: payments[i].daysLeft,
                        trailingPad: (i == payments.length - 1) ? 4 : 10,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Text(
                  "Transaction History",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPurple,
                  ),
                ),
              ),
              Column(
                children: const [
                  TransactionCard(
                    category: "Food",
                    date: "29 March 2025",
                    amount: "THB 20",
                    paidTo: "Paid to Max",
                    points: 10,
                  ),
                  TransactionCard(
                    category: "Transport",
                    date: "30 March 2025",
                    amount: "THB 50",
                    paidTo: "Paid to Lando",
                    points: 5,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple data model for upcoming payments
class _Payment {
  final String title;
  final int amount;
  final int daysLeft;
  _Payment({required this.title, required this.amount, required this.daysLeft});
}

/// Bordered container with three tiles
class MonthlySnapshotCard extends StatelessWidget {
  const MonthlySnapshotCard({
    super.key,
    required this.paid,
    required this.owed,
    required this.youOwe,
    this.currency = 'THB',
    this.tileHeight = 100,
    this.tileWidth = 105,
    this.gap = 19,
    this.panelPadding = const EdgeInsets.all(12),
    this.panelRadius = 8,
  });

  final int paid;
  final int owed;
  final int youOwe;
  final String currency;

  final double tileHeight;
  final double? tileWidth;
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
      return tileWidth != null
          ? SizedBox(width: tileWidth, child: tile)
          : Expanded(child: tile);
    }

    return Container(
      padding: panelPadding,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E0D5),
        borderRadius: BorderRadius.circular(panelRadius),
        border: Border.all(color: AppColors.textPurple, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildTile(paid, 'Paid', const Color(0xFFE2BDD1)),
          SizedBox(width: gap),
          buildTile(owed, 'Owes You', AppColors.accent),
          SizedBox(width: gap),
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

/// Small rounded badge for counts
class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.value,
    this.height = 22,
    this.radius = 6,
    this.fontSize = 12,
  });

  final int value;
  final double height;
  final double radius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.textPink,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
