// lib/room/compatibility_page.dart
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/widgets/room_header_appbar.dart';
import 'package:fairnestui/components/LavenderBorderedCard.dart';
import 'package:fairnestui/components/RoomCompatibilityCard.dart';
import 'package:fairnestui/widgets/LifestyleOverview.dart';
import 'package:fairnestui/widgets/app_bottom_nav.dart';

class CompatibilityPage extends StatefulWidget {
  const CompatibilityPage({super.key});

  @override
  State<CompatibilityPage> createState() => _CompatibilityPageState();
}

class _CompatibilityPageState extends State<CompatibilityPage> {
  final PageController _pageCtrl = PageController();
  int _page = 0; // 0 = Overall, 1 = Your
  int _bottomIndex = 0;

  // Example data – swap for live values
  final List<LifestyleMetric> overallMetrics = const [
    LifestyleMetric(kind: LifestyleMetricKind.tidiness, value: 0.78),
    LifestyleMetric(kind: LifestyleMetricKind.noiseActivity, value: 0.42),
    LifestyleMetric(kind: LifestyleMetricKind.schedule, value: 0.86),
    LifestyleMetric(kind: LifestyleMetricKind.guestFrequency, value: 0.35),
    LifestyleMetric(kind: LifestyleMetricKind.taskStructure, value: 0.92),
    LifestyleMetric(kind: LifestyleMetricKind.moneyAttitude, value: 0.88),
  ];

  final List<LifestyleMetric> yourMetrics = const [
    LifestyleMetric(kind: LifestyleMetricKind.tidiness, value: 0.72),
    LifestyleMetric(kind: LifestyleMetricKind.noiseActivity, value: 0.20),
    LifestyleMetric(kind: LifestyleMetricKind.schedule, value: 0.80),
    LifestyleMetric(kind: LifestyleMetricKind.guestFrequency, value: 0.18),
    LifestyleMetric(kind: LifestyleMetricKind.taskStructure, value: 0.40),
    LifestyleMetric(kind: LifestyleMetricKind.moneyAttitude, value: 0.72),
  ];

  void _onBottomTab(int i) {
    setState(() => _bottomIndex = i);
    // TODO: route to other tabs
  }

  void _onCenterAction() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const SizedBox(
        height: 220,
        child: Center(child: Text('Center Action')),
      ),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: RoomHeaderAppBar(
        scoreText: '78 Points',
        progress: 0.78,
        onTapNotifications: () {},
        onTapSettings: () {},
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Compatibility',
                  style:
                      AppFonts.heading1.copyWith(color: AppColors.textPurple)),
              const SizedBox(height: 12),

              // ===== Swappable overview section (no overflow) =====
              _OverviewSwitchCard(
                controller: _pageCtrl,
                page: _page,
                onPageChanged: (i) => setState(() => _page = i),
                onDotTap: (i) => _pageCtrl.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                ),
                pages: [
                  _OverviewPane(
                    title: 'Overall Lifestyle Compatibility Overview',
                    metrics: overallMetrics,
                  ),
                  _OverviewPane(
                    title: 'Your Lifestyle Overview',
                    metrics: yourMetrics,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ===== Room Compatibility Insights =====
              Text('Room Compatibility Insights',
                  style: AppFonts.heading3.copyWith(color: AppColors.textDark)),
              const SizedBox(height: 8),

              LavenderBorderedCard(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Already includes the "Average Compatibility Score" caption
                      RoomCompatibilityCard(value: 0.66),
                      const SizedBox(height: 12),

                      // Light panel inside lavender card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Roommate Insights',
                                style: AppFonts.heading3
                                    .copyWith(color: AppColors.textPurple)),
                            const SizedBox(height: 8),
                            _insightRow('Best Matched Pair:', 'Max & Lando'),
                            const SizedBox(height: 6),
                            _insightRow(
                                'Most Divergent Lifestyle:', 'Max & George'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ===== Roommate Compatibility Cards (match screenshot 2) =====
              Text('Roommate Compatibility',
                  style: AppFonts.heading3.copyWith(color: AppColors.textDark)),
              const SizedBox(height: 8),

              RoommateCompatibilityCard(
                avatarAsset: 'assets/images/sample_face.jpg',
                name: 'Max',
                matchPercent: 88,
                traits: const ['Likes Quiet Time', 'Initiates Settlement'],
                paragraphs: const [
                  'You and Max share a strong co-living rhythm. Keep up the great streak by maintaining consistent chore completion and clear communication.',
                  'George has completed 4 tasks on time this month, while Max completed 1. Consider adjusting the chore rotation or offering help for heavier loads.',
                ],
              ),
              const SizedBox(height: 14),

              RoommateCompatibilityCard(
                avatarAsset: 'assets/images/fairnest.png',
                name: 'Lando',
                matchPercent: 67,
                traits: const ["Dislikes George's guest preferences"],
                paragraphs: const [
                  'You’re mostly in sync, but small differences in guest preferences may cause tension. Consider aligning on quiet hours or visitor expectations.',
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),

      // Bottom navigation
    );
  }
}

/* =================== Pieces =================== */

class _OverviewSwitchCard extends StatelessWidget {
  const _OverviewSwitchCard({
    required this.controller,
    required this.page,
    required this.pages,
    required this.onPageChanged,
    required this.onDotTap,
  });

  final PageController controller;
  final int page;
  final List<Widget> pages;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7EFE8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF918A84)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              height: 360,
              child: PageView(
                controller: controller,
                onPageChanged: onPageChanged,
                children: pages,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Dots(count: pages.length, current: page, onTap: onDotTap),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _OverviewPane extends StatelessWidget {
  const _OverviewPane({required this.title, required this.metrics});

  final String title;
  final List<LifestyleMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppFonts.heading3
                .copyWith(color: AppColors.textDark, fontSize: 14)),
        const SizedBox(height: 8),
        LifestyleOverview(metrics: metrics, barHeight: 10),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots(
      {required this.count, required this.current, required this.onTap});

  final int count;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final selected = i == current;
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: selected ? 10 : 8,
            height: selected ? 10 : 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.secondary : const Color(0xFFB7AEBB),
              border: Border.all(color: const Color(0xFF645A80), width: 1),
            ),
          ),
        );
      }),
    );
  }
}

/* =================== Roommate Compatibility Card =================== */

class RoommateCompatibilityCard extends StatelessWidget {
  const RoommateCompatibilityCard({
    super.key,
    required this.avatarAsset,
    required this.name,
    required this.matchPercent,
    required this.traits,
    required this.paragraphs,
  });

  final String avatarAsset;
  final String name;
  final int matchPercent;
  final List<String> traits;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3B989), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: avatar + name on left, two info panels on right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + name (column)
              Column(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage(avatarAsset),
                  ),
                  const SizedBox(height: 6),
                  Text(name,
                      style: AppFonts.heading3
                          .copyWith(color: AppColors.textDark)),
                ],
              ),
              const SizedBox(width: 12),

              // Info panels
              Expanded(
                child: Row(
                  children: [
                    // Percent pill panel
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECE4F8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFF8A7FB0), width: 1),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$matchPercent%',
                                style: AppFonts.heading3
                                    .copyWith(color: AppColors.textPurple)),
                            const SizedBox(height: 4),
                            Text(
                              'Compatibility\nMatch',
                              textAlign: TextAlign.center,
                              style: AppFonts.body1.copyWith(
                                fontSize: 11,
                                color: AppColors.textPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Traits panel
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2D7F1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFF8A7FB0), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: traits
                              .map(
                                (t) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.5),
                                  child: Text(
                                    '• $t',
                                    style: AppFonts.heading3.copyWith(
                                      fontSize: 13,
                                      color: AppColors.textPurple,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Bullet paragraphs underneath
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: paragraphs
                .map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ',
                            style: TextStyle(
                              height: 1.4,
                              color: Colors.black87,
                            )),
                        Expanded(
                          child: Text(
                            p,
                            style: AppFonts.body1.copyWith(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

/* ===== helper for bold-left / regular-right rows ===== */
Widget _insightRow(String title, String value) {
  return RichText(
    text: TextSpan(
      style: AppFonts.body1.copyWith(fontSize: 12, color: AppColors.textPurple),
      children: [
        TextSpan(
          text: '$title ',
          style: AppFonts.body1.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPurple,
          ),
        ),
        TextSpan(text: value),
      ],
    ),
  );
}
