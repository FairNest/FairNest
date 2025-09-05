// lib/room/compatibility_page.dart
import 'package:flutter/material.dart';

import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';

import 'package:fairnestui/components/LavenderBorderedCard.dart';
import 'package:fairnestui/components/RoomCompatibilityCard.dart';
import 'package:fairnestui/components/RoommateCompatibilityCard.dart';
import 'package:fairnestui/widgets/LifestyleOverview.dart';

// Services & models
import 'package:fairnestui/services/user_profile_service.dart';
import 'package:fairnestui/model/user_profile_model.dart';
import 'package:fairnestui/services/api_client.dart';

class CompatibilityPage extends StatefulWidget {
  const CompatibilityPage({super.key});

  @override
  State<CompatibilityPage> createState() => _CompatibilityPageState();
}

class _CompatibilityPageState extends State<CompatibilityPage> {
  final PageController _pageCtrl = PageController();
  int _page = 0;

  bool _loading = true;
  Object? _error;

  // Data to render
  List<LifestyleMetric> _roomMetrics = const [];
  List<LifestyleMetric> _userMetrics = const [];

  @override
  void initState() {
    super.initState();
    _loadDataCacheThenRefresh();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  /* =================== Data loading =================== */

  Future<void> _loadDataCacheThenRefresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1) Cached profile (fast IDs)
      final cached = await UserProfileService.instance.getCurrentUserProfile();
      if (!mounted) return;

      if (cached == null) {
        setState(() {
          _loading = false;
          _error = 'No cached profile found.';
        });
        return;
      }

      await _fetchLifestyleFor(cached.userId, cached.roomId);

      // 2) Fresh profile (optional; in case IDs or anything changed)
      try {
        final fresh =
            await UserProfileService.instance.refreshCurrentUserProfile();
        if (!mounted || fresh == null) return;
        if (fresh.userId != cached.userId || fresh.roomId != cached.roomId) {
          await _fetchLifestyleFor(fresh.userId, fresh.roomId);
        }
      } catch (_) {
        // ignore refresh errors; we already have cached view
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _fetchLifestyleFor(int userId, int roomId) async {
    try {
      // Fetch both in parallel
      final results = await Future.wait([
        ApiClient.get('/GetRoomOverallLifestyleByRoomId/$roomId'),
        ApiClient.get('/GetUserOverallLifestyleByUserId/$userId'),
      ]);

      final roomResp = results[0];
      final userResp = results[1];

      if (!mounted) return;

      final roomOk = roomResp.statusCode == 200;
      final userOk = userResp.statusCode == 200;

      if (!roomOk && !userOk) {
        throw Exception(
            'Failed to load lifestyle data (${roomResp.statusCode}/${userResp.statusCode}).');
      }

      final roomJson = roomOk ? (roomResp.data as Map<String, dynamic>) : null;
      final userJson = userOk ? (userResp.data as Map<String, dynamic>) : null;

      final roomMetrics = roomJson != null
          ? _parseRoomLifestyle(roomJson)
          : const <LifestyleMetric>[];
      final userMetrics = userJson != null
          ? _parseUserLifestyle(userJson)
          : const <LifestyleMetric>[];

      setState(() {
        _roomMetrics = roomMetrics;
        _userMetrics = userMetrics;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  /* =================== JSON → Metrics mapping (exact keys) =================== */

  double _num(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  double _clamp01(double v) => v.clamp(0.0, 1.0);

  // Room: exact keys from your sample: avg_*
  List<LifestyleMetric> _parseRoomLifestyle(Map<String, dynamic> json) {
    final tidiness = _clamp01(_num(json['avg_tidiness']));
    final noiseActivity = _clamp01(_num(json['avg_noise_activity']));
    final schedule = _clamp01(_num(json['avg_schedule']));
    final guestFrequency = _clamp01(_num(json['avg_guest_frequency']));
    final taskStructure = _clamp01(_num(json['avg_task_structure']));
    final moneyAttitude = _clamp01(_num(json['avg_money_attitude']));

    return [
      LifestyleMetric(kind: LifestyleMetricKind.tidiness, value: tidiness),
      LifestyleMetric(
          kind: LifestyleMetricKind.noiseActivity, value: noiseActivity),
      LifestyleMetric(kind: LifestyleMetricKind.schedule, value: schedule),
      LifestyleMetric(
          kind: LifestyleMetricKind.guestFrequency, value: guestFrequency),
      LifestyleMetric(
          kind: LifestyleMetricKind.taskStructure, value: taskStructure),
      LifestyleMetric(
          kind: LifestyleMetricKind.moneyAttitude, value: moneyAttitude),
    ];
  }

  // User: exact keys from your sample: user_*
  List<LifestyleMetric> _parseUserLifestyle(Map<String, dynamic> json) {
    final tidiness = _clamp01(_num(json['user_tidiness']));
    final noiseActivity = _clamp01(_num(json['user_noise_activity']));
    final schedule = _clamp01(_num(json['user_schedule']));
    final guestFrequency = _clamp01(_num(json['user_guest_frequency']));
    final taskStructure = _clamp01(_num(json['user_task_structure']));
    final moneyAttitude = _clamp01(_num(json['user_money_attitude']));

    return [
      LifestyleMetric(kind: LifestyleMetricKind.tidiness, value: tidiness),
      LifestyleMetric(
          kind: LifestyleMetricKind.noiseActivity, value: noiseActivity),
      LifestyleMetric(kind: LifestyleMetricKind.schedule, value: schedule),
      LifestyleMetric(
          kind: LifestyleMetricKind.guestFrequency, value: guestFrequency),
      LifestyleMetric(
          kind: LifestyleMetricKind.taskStructure, value: taskStructure),
      LifestyleMetric(
          kind: LifestyleMetricKind.moneyAttitude, value: moneyAttitude),
    ];
  }

  /* =================== UI =================== */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorPane(
                    error: '$_error', onRetry: _loadDataCacheThenRefresh)
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Compatibility Overview',
                            style: AppFonts.heading1
                                .copyWith(color: AppColors.textPurple)),
                        const SizedBox(height: 12),

                        // ===== Swappable overview section =====
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
                              metrics: _roomMetrics,
                            ),
                            _OverviewPane(
                              title: 'Your Lifestyle',
                              metrics: _userMetrics,
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ===== Room Compatibility Insights =====
                        Text('Room Compatibility Insights',
                            style: AppFonts.heading3
                                .copyWith(color: AppColors.textDark)),
                        const SizedBox(height: 8),

                        LavenderBorderedCard(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // If you later get an overall compatibility % from backend,
                                // pass it here instead of the placeholder 0.66.
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Roommate Insights',
                                          style: AppFonts.heading3.copyWith(
                                              color: AppColors.textPurple)),
                                      const SizedBox(height: 8),
                                      _insightRow(
                                          'Best Matched Pair:', 'Max & Lando'),
                                      const SizedBox(height: 6),
                                      _insightRow('Most Divergent Lifestyle:',
                                          'Max & George'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ===== Roommate Compatibility Cards (still sample) =====
                        Text('Roommate Compatibility',
                            style: AppFonts.heading3
                                .copyWith(color: AppColors.textDark)),
                        const SizedBox(height: 8),
                        Roommatecompatibilitycard(
                          avatarImage:
                              const AssetImage('assets/images/char.png'),
                          name: 'Max',
                          compatibilityPercent: 72,
                          traits: const ['Very Good Match'],
                          insights: const [
                            'You and Max share a strong co-living rhythm. Keep up the great streak by maintaining consistent chore completion and clear communication.',
                          ],
                        ),
                        Roommatecompatibilitycard(
                          avatarImage:
                              const AssetImage('assets/images/pikachu.png'),
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
        LifestyleOverview(
          metrics: metrics,
          barHeight: 10,
        ),
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

/* ===== Simple error pane with Retry button ===== */
class _ErrorPane extends StatelessWidget {
  const _ErrorPane({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 12),
            Text(
              'Failed to load data',
              style: AppFonts.heading3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
