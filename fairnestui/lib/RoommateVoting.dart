import 'package:fairnestui/widgets/LifestyleOverview.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';

import 'package:fairnestui/widgets/app_header.dart';
import 'package:fairnestui/components/LavenderBorderedCard.dart';
import 'package:fairnestui/components/SecondaryButton.dart';

class RoommateVotingPage extends StatelessWidget {
  const RoommateVotingPage({
    super.key,
    this.name = 'George',
    this.avatarAsset = 'assets/images/fairnest.png',
    this.about =
        "I’m a night owl who loves sketching and ambient music. I’m mostly quiet but love the occasional deep convos in the kitchen. I keep my space tidy, cook often, and value mutual respect in shared living.",
    this.compatibilityPct = 90,
    this.votedCount = 1,
    this.memberMax = 3,
    this.metrics = const [
      LifestyleMetric(kind: LifestyleMetricKind.tidiness, value: 0.78),
      LifestyleMetric(kind: LifestyleMetricKind.noiseActivity, value: 0.48),
      LifestyleMetric(kind: LifestyleMetricKind.schedule, value: 0.92),
      LifestyleMetric(kind: LifestyleMetricKind.guestFrequency, value: 0.42),
      LifestyleMetric(kind: LifestyleMetricKind.taskStructure, value: 0.95),
      LifestyleMetric(kind: LifestyleMetricKind.moneyAttitude, value: 0.90),
    ],
    this.onAccept,
    this.onReject,
    this.onBellTap,
  });

  final String name;
  final String avatarAsset;
  final String about;
  final int compatibilityPct; // shown as "%", e.g., 90
  final int votedCount; // how many already voted
  final int memberMax; // total members who can vote
  final List<LifestyleMetric> metrics;

  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onBellTap;

  static const _lavender = Color(0xFF645A80);
  static const _compatText = Color(0xFFC34C04); // matches your spec
  static const _aboutLavenderFill = Color(0xFFD6CCE6);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header + back
          Stack(
            children: [
              AppHeader(title: 'Roommate Voting', onNotificationTap: onBellTap),
              Positioned(
                left: 4,
                top: top + 6,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: _lavender),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ],
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Voting in progress pill
                  Center(
                    child: _VotingPill(voted: votedCount, total: memberMax),
                  ),
                  const SizedBox(height: 16),

                  // Avatar + name
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.asset(
                            avatarAsset,
                            width: 108,
                            height: 108,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: AppFonts.heading3.copyWith(color: _lavender),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // About Me with compatibility badge
                  LavenderBorderedCard(
                    backgroundColor: _aboutLavenderFill,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'About Me',
                              style:
                                  AppFonts.heading3.copyWith(color: _lavender),
                            ),
                            const Spacer(),
                            _CompatBadge(
                              percent: compatibilityPct,
                              iconAsset: 'assets/images/Heart Puzzle.png',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          about,
                          style: const TextStyle(
                            fontFamily: 'Krub',
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Lifestyle Overview section (outer card + inner progress card)
                  LavenderBorderedCard(
                    backgroundColor: _aboutLavenderFill,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lifestyle Overview',
                          style: AppFonts.heading3.copyWith(color: _lavender),
                        ),
                        const SizedBox(height: 10),
                        LifestyleOverview(
                          barHeight: 10,
                          metrics: metrics,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: 'Reject',
                          onPressed: onReject ??
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Rejected')),
                                );
                              },
                          // use default red/brown color
                          height: 48,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SecondaryButton(
                          text: 'Accept',
                          onPressed: onAccept ??
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Accepted')),
                                );
                              },
                          backgroundColor:
                              const Color(0xFF79C79A), // green accept
                          textColor: Colors.white,
                          height: 48,
                        ),
                      ),
                    ],
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

/* ========================== Sub-widgets ========================== */

class _VotingPill extends StatelessWidget {
  const _VotingPill({required this.voted, required this.total});

  final int voted;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE9E4DF), // light neutral
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

class _CompatBadge extends StatelessWidget {
  const _CompatBadge({
    required this.percent,
    required this.iconAsset,
  });

  final int percent;
  final String iconAsset;

  static const _badgeBg = AppColors.accent; // orange badge background
  static const _textColor = Color(0xFFC34C04);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: _badgeBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$percent%',
            style: const TextStyle(
              fontFamily: 'Krub',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: _textColor,
            ),
          ),
          const SizedBox(width: 4),
          Image.asset(
            iconAsset,
            width: 18,
            height: 18,
            color: _textColor,
            colorBlendMode: BlendMode.srcIn,
            filterQuality: FilterQuality.high,
          ),
        ],
      ),
    );
  }
}
