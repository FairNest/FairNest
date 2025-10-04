import 'package:fairnestui/widgets/LifestyleOverview.dart';
import 'package:fairnestui/services/api_client.dart';
import 'package:fairnestui/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/widgets/app_header.dart';
import 'package:fairnestui/components/LavenderBorderedCard.dart';
import 'package:fairnestui/components/SecondaryButton.dart';

class RoommateVotingPage extends StatefulWidget {
  const RoommateVotingPage({
    super.key,
    required this.roomJoinRequestId,
  });

  final int roomJoinRequestId;

  @override
  State<RoommateVotingPage> createState() => _RoommateVotingPageState();
}

class _RoommateVotingPageState extends State<RoommateVotingPage> {
  late Future<Map<String, dynamic>> _votingDataFuture;
  bool _isSubmitting = false;

  static const _lavender = Color(0xFF645A80);
  static const _compatText = Color(0xFFC34C04);
  static const _aboutLavenderFill = Color(0xFFD6CCE6);

  @override
  void initState() {
    super.initState();
    _votingDataFuture = _fetchVotingData();
  }

  Future<Map<String, dynamic>> _fetchVotingData() async {
    final voterUserId = await UserService.getUserIdFromToken();
    if (voterUserId == null) {
      throw Exception('User not authenticated');
    }

    final response = await ApiClient.get(
      '/GetRoomJoinRequestForVotingByRoomJoinRequestIDVoterUserID/${widget.roomJoinRequestId}/$voterUserId',
    );

    return response.data as Map<String, dynamic>;
  }

  Future<void> _submitVote(bool voteDecision) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final voterUserId = await UserService.getUserIdFromToken();
      if (voterUserId == null) {
        throw Exception('User not authenticated');
      }

      // Call vote API endpoint with boolean vote
      final response = await ApiClient.put(
        '/PutSubmitVoteByRoomJoinRequestIDVoterUserID/${widget.roomJoinRequestId}/$voterUserId',
        data: {'vote': voteDecision},
      );

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              voteDecision
                  ? 'You accepted the roommate!'
                  : 'You rejected the roommate',
            ),
            backgroundColor:
                voteDecision ? const Color(0xFF79C79A) : Colors.red,
          ),
        );

        // Navigate back after successful vote
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit vote: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    final newFuture = _fetchVotingData();
    setState(() {
      _votingDataFuture = newFuture;
    });
    await newFuture;
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _votingDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                Stack(
                  children: [
                    const AppHeader(
                      title: 'Roommate Voting',
                      rightType: AppHeaderRightType.none,
                    ),
                    Positioned(
                      left: 4,
                      top: top + 6,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: _lavender),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }

          if (snapshot.hasError) {
            return Column(
              children: [
                Stack(
                  children: [
                    const AppHeader(
                      title: 'Roommate Voting',
                      rightType: AppHeaderRightType.none,
                    ),
                    Positioned(
                      left: 4,
                      top: top + 6,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: _lavender),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Error loading voting data: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            );
          }

          final data = snapshot.data!;
          final name =
              '${data['firstname'] ?? ''} ${data['lastname'] ?? ''}'.trim();
          final displayName =
              name.isEmpty ? (data['username'] ?? 'User') : name;
          final avatarUrl = data['user_picture'] as String?;
          final about =
              data['user_about_me'] as String? ?? 'No description available';
          final compatibilityPct =
              (data['compatibility_percent'] as num?)?.round() ?? 0;
          final votedCount = data['voted_count'] as int? ?? 0;
          final totalVoters = data['total_voters'] as int? ?? 1;
          final myVote = data['my_vote'] as String?;

          // Check if user already voted
          final hasVoted = myVote != null && myVote != 'pending';

          final metrics = [
            LifestyleMetric(
              kind: LifestyleMetricKind.tidiness,
              value: (data['user_tidiness'] as num?)?.toDouble() ?? 0.0,
            ),
            LifestyleMetric(
              kind: LifestyleMetricKind.noiseActivity,
              value: (data['user_noise_activity'] as num?)?.toDouble() ?? 0.0,
            ),
            LifestyleMetric(
              kind: LifestyleMetricKind.schedule,
              value: (data['user_schedule'] as num?)?.toDouble() ?? 0.0,
            ),
            LifestyleMetric(
              kind: LifestyleMetricKind.guestFrequency,
              value: (data['user_guest_frequency'] as num?)?.toDouble() ?? 0.0,
            ),
            LifestyleMetric(
              kind: LifestyleMetricKind.taskStructure,
              value: (data['user_task_structure'] as num?)?.toDouble() ?? 0.0,
            ),
            LifestyleMetric(
              kind: LifestyleMetricKind.moneyAttitude,
              value: (data['user_money_attitude'] as num?)?.toDouble() ?? 0.0,
            ),
          ];

          return Column(
            children: [
              Stack(
                children: [
                  const AppHeader(
                    title: 'Roommate Voting',
                    rightType: AppHeaderRightType.none,
                  ),
                  Positioned(
                    left: 4,
                    top: top + 6,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: _lavender),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: _VotingPill(
                            voted: votedCount,
                            total: totalVoters,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 54,
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                child: avatarUrl != null &&
                                        avatarUrl.startsWith('http')
                                    ? Image.network(
                                        avatarUrl,
                                        width: 108,
                                        height: 108,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/images/fairnest.png',
                                            width: 108,
                                            height: 108,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        avatarUrl ??
                                            'assets/images/fairnest.png',
                                        width: 108,
                                        height: 108,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              displayName,
                              style:
                                  AppFonts.heading3.copyWith(color: _lavender),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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
                                    style: AppFonts.heading3
                                        .copyWith(color: _lavender),
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
                        LavenderBorderedCard(
                          backgroundColor: _aboutLavenderFill,
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lifestyle Overview',
                                style: AppFonts.heading3
                                    .copyWith(color: _lavender),
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
                        if (hasVoted)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: myVote == 'approve'
                                  ? const Color(0xFF79C79A).withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: myVote == 'approve'
                                    ? const Color(0xFF79C79A)
                                    : Colors.red,
                              ),
                            ),
                            child: Text(
                              myVote == 'approve'
                                  ? 'You already accepted this roommate'
                                  : 'You already rejected this roommate',
                              style: TextStyle(
                                fontFamily: 'Krub',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: myVote == 'approve'
                                    ? const Color(0xFF79C79A)
                                    : Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: SecondaryButton(
                                  text:
                                      _isSubmitting ? 'Rejecting...' : 'Reject',
                                  onPressed: () {
                                    if (!_isSubmitting) {
                                      _submitVote(false);
                                    }
                                  },
                                  height: 48,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SecondaryButton(
                                  text:
                                      _isSubmitting ? 'Accepting...' : 'Accept',
                                  onPressed: () {
                                    if (!_isSubmitting) {
                                      _submitVote(true);
                                    }
                                  },
                                  backgroundColor: const Color(0xFF79C79A),
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
              ),
            ],
          );
        },
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

class _CompatBadge extends StatelessWidget {
  const _CompatBadge({
    required this.percent,
    required this.iconAsset,
  });

  final int percent;
  final String iconAsset;

  static const _badgeBg = AppColors.accent;
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
