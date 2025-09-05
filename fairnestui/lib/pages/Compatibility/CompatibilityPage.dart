// lib/room/compatibility_page.dart
import 'package:fairnestui/components/RoommateCompatibilityCard.dart';
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
        scoreText: '50 Points',
        progress: 0.50,
        onTapNotifications: () {},
        onTapSettings: () {},
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Compatibility Overview',
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
                    title: 'Room Lifestyle',
                    metrics: overallMetrics,
                  ),
                  _OverviewPane(
                    title: 'Your Lifestyle',
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
              Roommatecompatibilitycard(
                avatarImage: const AssetImage('assets/images/char.png'),
                name: 'Max',
                compatibilityPercent: 72,
                traits: const ['Very Good Match'],
                insights: const [
                  'You and Max share a strong co-living rhythm. Keep up the great streak by maintaining consistent chore completion and clear communication.',
                ],
              ),
              Roommatecompatibilitycard(
                avatarImage: const AssetImage('assets/images/pikachu.png'),
                name: 'Lando',
                compatibilityPercent: 68,
                traits: const ['A good match'],
                insights: const [
                  "You're mostly in sync, but small differences in guest preferences may cause tension. Consider aligning on quiet hours or visitor expectations.",
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
