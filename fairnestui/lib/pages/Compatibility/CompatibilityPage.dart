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
import 'package:fairnestui/services/api_client.dart';

/// ---- Models for the 2 new compatibility endpoints ----

class CompatibilityPairDto {
  final int userAId;
  final String userAName;
  final int userBId;
  final String userBName;
  final double scorePct; // 0..100

  CompatibilityPairDto({
    required this.userAId,
    required this.userAName,
    required this.userBId,
    required this.userBName,
    required this.scorePct,
  });

  factory CompatibilityPairDto.fromJson(Map<String, dynamic> j) {
    double _num(v) => (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
    return CompatibilityPairDto(
      userAId: (j['user_a_id'] as num).toInt(),
      userAName: (j['user_a_name'] ?? '') as String,
      userBId: (j['user_b_id'] as num).toInt(),
      userBName: (j['user_b_name'] ?? '') as String,
      scorePct: _num(j['score']),
    );
  }
}

class RoomCompatibilitySummaryDto {
  final double scorePct; // 0..100
  final CompatibilityPairDto bestMatched;
  final CompatibilityPairDto mostDivergent;

  RoomCompatibilitySummaryDto({
    required this.scorePct,
    required this.bestMatched,
    required this.mostDivergent,
  });

  factory RoomCompatibilitySummaryDto.fromJson(Map<String, dynamic> j) {
    return RoomCompatibilitySummaryDto(
      scorePct: (j['score'] as num).toDouble(),
      bestMatched: CompatibilityPairDto.fromJson(
          j['best_matched'] as Map<String, dynamic>),
      mostDivergent: CompatibilityPairDto.fromJson(
          j['most_divergent'] as Map<String, dynamic>),
    );
  }
}

class CompatibilityMatchItemDto {
  final int userId;
  final String username;
  final String? profilePicture;
  final double scorePct; // 0..100
  final String matchLabel;

  CompatibilityMatchItemDto({
    required this.userId,
    required this.username,
    required this.profilePicture,
    required this.scorePct,
    required this.matchLabel,
  });

  factory CompatibilityMatchItemDto.fromJson(Map<String, dynamic> j) {
    double _num(v) => (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
    return CompatibilityMatchItemDto(
      userId: (j['user_id'] as num).toInt(),
      username: (j['username'] ?? '') as String,
      profilePicture: j['profile_picture'] as String?,
      scorePct: _num(j['score']),
      matchLabel: (j['match'] ?? '') as String,
    );
  }
}

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
  bool _isSingleUser = false; // NEW: track if user is alone in room

  // Data to render
  List<LifestyleMetric> _roomMetrics = const [];
  List<LifestyleMetric> _userMetrics = const [];

  // NEW: compatibility summary + per-roommate matches
  RoomCompatibilitySummaryDto? _roomSummary;
  List<CompatibilityMatchItemDto> _matches = const [];

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
      _isSingleUser = false;
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
      // Fetch lifestyle data (required)
      final lifestyleResults = await Future.wait([
        ApiClient.get('/GetRoomOverallLifestyleByRoomId/$roomId'),
        ApiClient.get('/GetUserOverallLifestyleByUserId/$userId'),
      ]);

      final roomResp = lifestyleResults[0];
      final userResp = lifestyleResults[1];

      if (!mounted) return;

      final roomOk = roomResp.statusCode == 200;
      final userOk = userResp.statusCode == 200;

      // Try to fetch compatibility data (may fail if single user)
      dynamic compSummaryResp;
      dynamic compMatchesResp;
      bool sumOk = false;
      bool matOk = false;

      try {
        compSummaryResp =
            await ApiClient.get('/GetRoomAverageCompatibilityByRoomId/$roomId');
        sumOk = compSummaryResp.statusCode == 200;
      } catch (e) {
        // Compatibility endpoint failed - likely single user
        sumOk = false;
      }

      try {
        compMatchesResp = await ApiClient.get(
            '/GetCompatibilityMatchesByRoomAndUser/$roomId/$userId');
        matOk = compMatchesResp.statusCode == 200;
      } catch (e) {
        // Compatibility endpoint failed - likely single user
        matOk = false;
      }

      if (!mounted) return;

      // Check if compatibility endpoints failed (likely single user scenario)
      final isSingleUser = !sumOk && !matOk;

      // If at least lifestyle data exists, show it
      if (!roomOk && !userOk) {
        throw Exception(
          'Failed to load lifestyle data '
          '(${roomResp.statusCode}/${userResp.statusCode}).',
        );
      }

      final roomMetrics = roomOk
          ? _parseRoomLifestyle(roomResp.data as Map<String, dynamic>)
          : const <LifestyleMetric>[];
      final userMetrics = userOk
          ? _parseUserLifestyle(userResp.data as Map<String, dynamic>)
          : const <LifestyleMetric>[];

      RoomCompatibilitySummaryDto? summary;
      if (sumOk && compSummaryResp.data is Map<String, dynamic>) {
        summary = RoomCompatibilitySummaryDto.fromJson(
            compSummaryResp.data as Map<String, dynamic>);
      }

      List<CompatibilityMatchItemDto> matches = const [];
      if (matOk && compMatchesResp.data is Map<String, dynamic>) {
        final map = compMatchesResp.data as Map<String, dynamic>;
        final list = (map['matches'] as List<dynamic>? ?? const []);
        matches = list
            .whereType<Map<String, dynamic>>()
            .map(CompatibilityMatchItemDto.fromJson)
            .toList();
      }

      setState(() {
        _roomMetrics = roomMetrics;
        _userMetrics = userMetrics;
        _roomSummary = summary;
        _matches = matches;
        _isSingleUser = isSingleUser;
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

  /* =================== Dynamic Advice Generation =================== */

  List<String> _generateAdvice(double compatibilityPct) {
    if (compatibilityPct >= 90) {
      // Perfect match (90-100%)
      return [
        'Excellent synergy! Keep up the open communication.',
        'Your lifestyles align beautifully—maintain this positive dynamic.',
      ];
    } else if (compatibilityPct >= 75) {
      // Very Good (75-89%)
      return [
        'Strong compatibility! Align on long-term goals to keep things smooth.',
        'You are in great sync—occasional check-ins will strengthen your bond.',
      ];
    } else if (compatibilityPct >= 60) {
      // Good (60-74%)
      return [
        'Good match overall. Clarify expectations on shared spaces regularly.',
        'Mostly aligned—discuss any small differences before they grow.',
      ];
    } else if (compatibilityPct >= 45) {
      // Average (45-59%)
      return [
        'Some lifestyle gaps exist. Set clear house rules for chores and quiet hours.',
        'Communication is key. Schedule regular check-ins to address concerns.',
        'Consider creating a shared calendar for cleaning and guest schedules.',
      ];
    } else if (compatibilityPct >= 30) {
      // Below Average (30-44%)
      return [
        'Significant differences present. Have an honest conversation about boundaries.',
        'Establish written agreements for shared responsibilities and personal space.',
        'Schedule weekly house meetings to prevent conflicts from building up.',
        'Consider using a task management app to track chores fairly.',
      ];
    } else {
      // Low compatibility (0-29%)
      return [
        'Major lifestyle differences detected. Immediate discussion needed about house rules.',
        'Set very clear boundaries for noise, guests, and shared spaces.',
        'Create a detailed roommate agreement covering all aspects of living together.',
        'Consider mediation or counseling if conflicts arise frequently.',
        'Be proactive—address issues immediately before they escalate.',
      ];
    }
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
                : _isSingleUser
                    ? _SingleUserView(
                        userMetrics: _userMetrics,
                        onRetry: _loadDataCacheThenRefresh,
                      )
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
                                padding:
                                    const EdgeInsets.fromLTRB(10, 12, 10, 12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    RoomCompatibilityCard(
                                      // widget expects 0..1; backend returns % → divide by 100
                                      value: ((_roomSummary?.scorePct ?? 0.0) /
                                          100.0),
                                    ),
                                    const SizedBox(height: 12),

                                    // Light panel inside lavender card
                                    Container(
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: .35),
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
                                            'Best Matched Pair:',
                                            _roomSummary == null
                                                ? '-'
                                                : '${_roomSummary!.bestMatched.userAName} & ${_roomSummary!.bestMatched.userBName}',
                                          ),
                                          const SizedBox(height: 6),
                                          _insightRow(
                                            'Most Divergent Lifestyle:',
                                            _roomSummary == null
                                                ? '-'
                                                : '${_roomSummary!.mostDivergent.userAName} & ${_roomSummary!.mostDivergent.userBName}',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // ===== Roommate Compatibility Cards =====
                            Text('Roommate Compatibility',
                                style: AppFonts.heading3
                                    .copyWith(color: AppColors.textDark)),
                            const SizedBox(height: 8),

                            if (_matches.isEmpty)
                              Text('No roommate matches to show.',
                                  style: AppFonts.body1
                                      .copyWith(color: AppColors.textPurple))
                            else
                              Column(
                                children: _matches.map((m) {
                                  final img = (m.profilePicture?.isNotEmpty ??
                                          false)
                                      ? NetworkImage(m.profilePicture!)
                                      : const AssetImage(
                                              'assets/images/default_avatar.png')
                                          as ImageProvider;

                                  // Generate dynamic advice based on compatibility percentage
                                  final adviceList =
                                      _generateAdvice(m.scorePct);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Roommatecompatibilitycard(
                                      avatarImage: img,
                                      name: m.username,
                                      compatibilityPercent: m.scorePct.round(),
                                      traits: [m.matchLabel],
                                      insights: adviceList,
                                    ),
                                  );
                                }).toList(),
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

/// NEW: Single user view when they're alone in the room
class _SingleUserView extends StatelessWidget {
  const _SingleUserView({
    required this.userMetrics,
    required this.onRetry,
  });

  final List<LifestyleMetric> userMetrics;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Compatibility Overview',
              style: AppFonts.heading1.copyWith(color: AppColors.textPurple)),
          const SizedBox(height: 12),

          // Show only user's lifestyle
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7EFE8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF918A84)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Lifestyle',
                    style: AppFonts.heading3
                        .copyWith(color: AppColors.textDark, fontSize: 14)),
                const SizedBox(height: 8),
                LifestyleOverview(
                  metrics: userMetrics,
                  barHeight: 10,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Empty state message
          LavenderBorderedCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 64,
                    color: AppColors.textPurple.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "You're the only one in the room so far",
                    style:
                        AppFonts.heading3.copyWith(color: AppColors.textPurple),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Invite roommates to see compatibility insights and start building your shared space together!',
                    style: AppFonts.body1.copyWith(
                      color: AppColors.textPurple.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
