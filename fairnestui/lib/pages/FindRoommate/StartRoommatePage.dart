// lib/roommate/find_roommate_detail_page.dart
import 'package:fairnestui/widgets/LifestyleOverview.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';

import 'package:fairnestui/widgets/app_header.dart';
import 'package:fairnestui/components/RoomComponentsCard.dart';

class StartRoommatePage extends StatelessWidget {
  const StartRoommatePage({
    super.key,
    this.showBack = true,
    this.votedCount = 2,
    this.memberMax = 3,
  });

  final bool showBack;
  final int votedCount; // how many people agreed
  final int memberMax; // total members in room

  static const _lavender = Color(0xFF645A80);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFE9E0EC),
      body: Column(
        children: [
          // Header bar; bell removed by passing null
          Stack(
            children: [
              const AppHeader(
                title: 'Find Roommate',
                onNotificationTap: null, // ← hides notification icon
              ),
              // Small profile avatar on the right
              Positioned(
                right: 16,
                top: top + 8,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/fairnest.png',
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Room card — set height to 210 to avoid overflow
                  RoomComponentsCard(
                    title: 'Wonderful Trio Casa',
                    description:
                        "We're early risers, prefer a quiet space, and rotate chores weekly.",
                    memberCount: 2,
                    memberMax: 3,
                    compatibilityPct: 87,
                    width: double.infinity,
                    height: 210, // ← prevent bottom overflow
                    onTap: () {},
                  ),

                  const SizedBox(height: 12),

                  // Room Overview
                  const _SectionTitle('Room Overview'),
                  const SizedBox(height: 8),
                  const _OverviewCard(
                    apartmentName: 'KikiRah Apartment',
                    leftRightRows: [
                      ('Rent • 4,500 Baht/Month', 'Free WiFi'),
                      ('Electricity 8 Baht/Unit', 'Washing Machines Available'),
                      ('Water 7 Baht/Unit', 'No Pets Allowed'),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Lifestyle
                  const _SectionTitle('Lifestyle Overview'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECE9E6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _lavender, width: 1),
                    ),
                    child: const LifestyleOverview(
                      barHeight: 10,
                      metrics: [
                        LifestyleMetric(
                            kind: LifestyleMetricKind.tidiness, value: 0.82),
                        LifestyleMetric(
                            kind: LifestyleMetricKind.noiseActivity,
                            value: 0.48),
                        LifestyleMetric(
                            kind: LifestyleMetricKind.schedule, value: 0.92),
                        LifestyleMetric(
                            kind: LifestyleMetricKind.guestFrequency,
                            value: 0.40),
                        LifestyleMetric(
                            kind: LifestyleMetricKind.taskStructure,
                            value: 0.98),
                        LifestyleMetric(
                            kind: LifestyleMetricKind.moneyAttitude,
                            value: 0.94),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Roommates
                  const _SectionTitle('Roommates'),
                  const SizedBox(height: 8),
                  const _RoommatesRow(
                    members: [
                      ('assets/images/fairnest.png', 'Max'),
                      ('assets/images/fairnest.png', 'George'),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Voting Progress Indicator
                  Center(
                    child: _VotingProgressIndicator(
                      voted: votedCount,
                      total: memberMax,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ----------------- Small pieces ----------------- */

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppFonts.heading3.copyWith(
        color: const Color(0xFF645A80),
      ),
    );
  }
}

/// Voting progress indicator showing how many people agreed
class _VotingProgressIndicator extends StatelessWidget {
  const _VotingProgressIndicator({
    required this.voted,
    required this.total,
  });

  final int voted;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE9E4DF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1CBC4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Voting in Progress',
            style: TextStyle(
              fontFamily: 'Krub',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Color(0xFF7B7486),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$voted/$total',
            style: const TextStyle(
              fontFamily: 'Krub',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          Image.asset(
            'assets/images/PersonVector.png',
            width: 16,
            height: 16,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

/// Room overview card with bold/bigger apartment name and smaller details
class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.apartmentName,
    required this.leftRightRows,
  });

  final String apartmentName;
  final List<(String left, String right)> leftRightRows;

  static const _border = Color(0xFF645A80);

  @override
  Widget build(BuildContext context) {
    const double titleSize = 14;
    const double detailSize = titleSize - 2; // 2px smaller

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFECE9E6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
        children: [
          // Apartment name
          Row(
            children: [
              Expanded(
                child: Text(
                  apartmentName,
                  style: const TextStyle(
                    fontFamily: 'Krub',
                    fontWeight: FontWeight.w700, // bold
                    fontSize: titleSize,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
          const SizedBox(height: 8),

          // Details rows
          for (int i = 0; i < leftRightRows.length; i++) ...[
            _RowLine(
              left: leftRightRows[i].$1,
              right: leftRightRows[i].$2,
              fontSize: detailSize,
            ),
            if (i != leftRightRows.length - 1) const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _RowLine extends StatelessWidget {
  const _RowLine({
    required this.left,
    required this.right,
    this.fontSize = 12,
  });
  final String left;
  final String right;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final leftStyle = TextStyle(
      fontFamily: 'Krub',
      fontWeight: FontWeight.w400,
      fontSize: fontSize,
      color: Colors.black,
    );
    final rightStyle = TextStyle(
      fontFamily: 'Krub',
      fontWeight: FontWeight.w400,
      fontSize: fontSize,
      color: Colors.black87,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(left, style: leftStyle)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            right,
            style: rightStyle,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _RoommatesRow extends StatelessWidget {
  const _RoommatesRow({required this.members});

  final List<(String, String)> members;

  static const _lavender = Color(0xFF645A80);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFECE9E6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lavender, width: 1),
      ),
      child: Row(
        children: [
          for (final m in members) ...[
            _MemberChip(asset: m.$1, label: m.$2),
            const SizedBox(width: 8),
          ],
          const Spacer(),
        ],
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  const _MemberChip({required this.asset, required this.label});
  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: Colors.white,
          child: ClipOval(
            child: Image.asset(
              asset,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Krub',
            fontSize: 10,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
