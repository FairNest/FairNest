import 'package:fairnestui/components/AccentBorderedCard.dart';
import 'package:fairnestui/components/ChoresProgressCard.dart';
import 'package:fairnestui/components/FinancesProgressCard.dart';
import 'package:fairnestui/components/LavenderBorderedCard.dart';
import 'package:fairnestui/components/RoomCompatibilityCard.dart';
import 'package:fairnestui/components/RoommateOverviewCard.dart';
import 'package:fairnestui/components/YourProgressNowCard.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/util/EditHouseRules.dart';
import 'package:fairnestui/widgets/TaskNavFolder.dart';
import 'package:fairnestui/services/user_profile_service.dart';
import 'package:fairnestui/services/notification_service.dart';
import 'package:fairnestui/services/dashboard_service.dart';
import 'package:fairnestui/services/user_dashboard_service.dart';
import 'package:fairnestui/model/notification_model.dart';
import 'package:fairnestui/model/dashboard_model.dart';
import 'package:fairnestui/model/user_dashboard_model.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';

class RoomDashboardPage extends StatefulWidget {
  const RoomDashboardPage({super.key});

  @override
  State<RoomDashboardPage> createState() => _RoomDashboardPageState();
}

class _RoomDashboardPageState extends State<RoomDashboardPage> {
  int _tab = 0;
  int _bottomIndex = 0;
  String _firstName = "User";
  List<NotificationModel> _recentNotifications = [];
  bool _isLoadingNotifications = true;

  // Room Dashboard data
  RoomDashboardData? _roomDashboardData;
  bool _isLoadingRoomDashboard = true;
  String? _roomDashboardError;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadRecentNotifications();
    _loadRoomDashboardData();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Try cache first for instant load
      final cachedProfile =
          await UserProfileService.instance.getCachedProfile();
      if (cachedProfile != null && mounted) {
        setState(() {
          _firstName = cachedProfile.firstname ?? "User";
        });
      }

      // Then fetch fresh data in background
      final profile = await UserProfileService.instance.getCurrentUserProfile();
      if (profile != null && mounted) {
        setState(() {
          _firstName = profile.firstname ?? "User";
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> _loadRecentNotifications() async {
    setState(() {
      _isLoadingNotifications = true;
    });

    try {
      final notifications =
          await NotificationService.getThreeRecentNotifications();
      if (mounted) {
        setState(() {
          _recentNotifications = notifications;
          _isLoadingNotifications = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      if (mounted) {
        setState(() {
          _isLoadingNotifications = false;
        });
      }
    }
  }

  Future<void> _loadRoomDashboardData() async {
    setState(() {
      _isLoadingRoomDashboard = true;
      _roomDashboardError = null;
    });

    try {
      final dashboardData = await DashboardService.instance.getRoomDashboard();

      if (mounted) {
        setState(() {
          _roomDashboardData = dashboardData;
          _isLoadingRoomDashboard = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading room dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoadingRoomDashboard = false;
          _roomDashboardError = 'Failed to load dashboard data';
        });
      }
    }
  }

  Future<void> _refreshRoomDashboard() async {
    await _loadRoomDashboardData();
  }

  void _onBottomTab(int i) {
    setState(() => _bottomIndex = i);
  }

  void _onCenterAction() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SizedBox(
        height: 260,
        child:
            Center(child: Text('Create something…', style: AppFonts.heading1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome Back, $_firstName!",
              style: AppFonts.heading1.copyWith(color: AppColors.textPurple),
            ),
            const SizedBox(height: 12),
            _PillSegmentedControl(
              tabs: const ['Room Dashboard', 'Your Dashboard'],
              initialIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  _RoomDashContent(
                    notifications: _recentNotifications,
                    isLoadingNotifications: _isLoadingNotifications,
                    onRefreshNotifications: _loadRecentNotifications,
                    dashboardData: _roomDashboardData,
                    isLoadingDashboard: _isLoadingRoomDashboard,
                    dashboardError: _roomDashboardError,
                    onRefreshDashboard: _refreshRoomDashboard,
                  ),
                  const _YourDashContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomDashContent extends StatelessWidget {
  const _RoomDashContent({
    super.key,
    required this.notifications,
    required this.isLoadingNotifications,
    required this.onRefreshNotifications,
    required this.dashboardData,
    required this.isLoadingDashboard,
    required this.dashboardError,
    required this.onRefreshDashboard,
  });

  final List<NotificationModel> notifications;
  final bool isLoadingNotifications;
  final Future<void> Function() onRefreshNotifications;
  final RoomDashboardData? dashboardData;
  final bool isLoadingDashboard;
  final String? dashboardError;
  final Future<void> Function() onRefreshDashboard;

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await onRefreshNotifications();
        await onRefreshDashboard();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notices Section
            const Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                "Notices",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPurple),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE2BDD1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black54),
              ),
              child: isLoadingNotifications
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.textPink,
                      ),
                    )
                  : notifications.isEmpty
                      ? const Center(
                          child: Text(
                            'No recent notifications',
                            style: TextStyle(
                              color: AppColors.textPink,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : Stack(
                          children: List.generate(
                            notifications.length,
                            (index) {
                              final notification = notifications[index];
                              return Padding(
                                padding: EdgeInsets.fromLTRB(
                                    10, 13 + (index * 44.0), 10, 10),
                                child: Container(
                                  height: 34,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAEDE5),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      notification.notificationMessage,
                                      style: const TextStyle(
                                        color: AppColors.textPink,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
            const SizedBox(height: 15),

            // Today Room Status Header
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Text(
                    "Today Room Status",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPurple),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 70, bottom: 15),
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirmed = await showEditHouseRulesDialog(context);

                      if (confirmed == true) {
                        debugPrint("User clicked Edit House Rule");
                      } else {
                        debugPrint("Dialog dismissed");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.background,
                      foregroundColor: AppColors.darkPurple,
                      elevation: 3,
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      shape: const StadiumBorder(
                        side: BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      textStyle: AppFonts.heading1.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text("House Rules"),
                  ),
                )
              ],
            ),

            // Today Room Status Content
            if (isLoadingDashboard)
              const LavenderBorderedCard(
                child: SizedBox(
                  height: 350,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.textPink,
                    ),
                  ),
                ),
              )
            else if (dashboardError != null)
              LavenderBorderedCard(
                child: SizedBox(
                  height: 350,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.textPink,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          dashboardError!,
                          style: const TextStyle(
                            color: AppColors.textPink,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async => await onRefreshDashboard(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (dashboardData != null)
              LavenderBorderedCard(
                child: SizedBox(
                  height: 350,
                  child: Column(
                    children: [
                      RoomCompatibilityCard(
                        value: dashboardData!
                            .todayRoomStatus.roomCompatibility.score,
                      ),
                      const SizedBox(height: 10),
                      ChoresProgressCard(
                        totalTasks: dashboardData!
                            .todayRoomStatus.choresProgress.totalTasks,
                        completedTasks: dashboardData!
                            .todayRoomStatus.choresProgress.completedTasks,
                      ),
                      const SizedBox(height: 10),
                      FinancesProgressCard(
                        completedFinances: dashboardData!
                            .todayRoomStatus.financesProgress.completedFinances,
                        totalFinances: dashboardData!
                            .todayRoomStatus.financesProgress.totalFinances,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 15),

            // Roommate Overview Header
            const Text(
              "Roommate Overview",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPurple),
            ),
            const SizedBox(height: 10),

            // Roommate Overview Content
            if (isLoadingDashboard)
              const AccentBorderedCard(
                child: SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.textPink,
                    ),
                  ),
                ),
              )
            else if (dashboardData != null &&
                dashboardData!.roommateOverview.isNotEmpty)
              AccentBorderedCard(
                child: Column(
                  children: dashboardData!.roommateOverview.map((roommate) {
                    return Roommateoverviewcard(
                      name: roommate.name,
                      compatibilityScore: roommate.compatibilityScoreInt,
                      tasksCompleted: roommate.tasksCompleted,
                      tasksTotal: roommate.tasksTotal,
                      amount: roommate.financeAmount,
                      avatarImage: roommate.userPicture != null
                          ? NetworkImage(roommate.userPicture!)
                          : const AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                      financeStatus: FinanceStatus
                          .owesYou, // Always owes you as per backend
                    );
                  }).toList(),
                ),
              )
            else if (dashboardData != null &&
                dashboardData!.roommateOverview.isEmpty)
              const AccentBorderedCard(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'No roommates yet',
                      style: TextStyle(
                        color: AppColors.textPink,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

// Replace the _YourDashContent widget in your RoomDashboardPage.dart

// Replace the _YourDashContent widget in your RoomDashboardPage.dart

class _YourDashContent extends StatefulWidget {
  const _YourDashContent({super.key});

  @override
  State<_YourDashContent> createState() => _YourDashContentState();
}

class _YourDashContentState extends State<_YourDashContent> {
  UserDashboardData? _userDashboardData;
  bool _isLoadingUserDashboard = true;
  String? _userDashboardError;

  @override
  void initState() {
    super.initState();
    _loadUserDashboard();
  }

  Future<void> _loadUserDashboard() async {
    setState(() {
      _isLoadingUserDashboard = true;
      _userDashboardError = null;
    });

    try {
      final data = await UserDashboardService.instance.getUserDashboard();

      if (mounted) {
        setState(() {
          _userDashboardData = data;
          _isLoadingUserDashboard = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user dashboard: $e');
      if (mounted) {
        setState(() {
          _isLoadingUserDashboard = false;
          _userDashboardError = 'Failed to load your dashboard';
        });
      }
    }
  }

  Future<void> _refreshUserDashboard() async {
    await _loadUserDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshUserDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Your Progress Card
            if (_isLoadingUserDashboard)
              const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.textPink,
                  ),
                ),
              )
            else if (_userDashboardError != null)
              SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.textPink,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _userDashboardError!,
                        style: const TextStyle(
                          color: AppColors.textPink,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshUserDashboard,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_userDashboardData != null)
              YourProgressNowCard(
                completedTasks:
                    _userDashboardData!.yourProgress.overallCompleted,
                totalTasks: _userDashboardData!.yourProgress.overallTotal,
              ),

            const SizedBox(height: 20),

            // Task Navigation Folder with REAL SEPARATED DATA
            if (_isLoadingUserDashboard)
              const SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.textPink,
                  ),
                ),
              )
            else if (_userDashboardData != null)
              TaskNavFolder(
                todayUnfinishedCount:
                    _userDashboardData!.taskSummary.todayUnfinishedCount,
                completedCount: _userDashboardData!.taskSummary.completedCount,
                upcomingUnfinishedCount:
                    _userDashboardData!.taskSummary.upcomingUnfinishedCount,
                // ✅ Passing separated chores and finances from backend
                todayUnfinishedTasks:
                    _userDashboardData!.taskSummary.todayUnfinishedTasks,
                completedTasks: _userDashboardData!.taskSummary.completedTasks,
                upcomingUnfinishedTasks:
                    _userDashboardData!.taskSummary.upcomingUnfinishedTasks,
              ),
          ],
        ),
      ),
    );
  }
}

/* ---------- Baked-in pill control ---------- */
class _PillSegmentedControl extends StatefulWidget {
  const _PillSegmentedControl({
    required this.tabs,
    required this.onChanged,
    this.initialIndex = 0,
    this.height = 44,
    super.key,
  });

  final List<String> tabs;
  final int initialIndex;
  final ValueChanged<int> onChanged;
  final double height;

  @override
  State<_PillSegmentedControl> createState() => _PillSegmentedControlState();
}

class _PillSegmentedControlState extends State<_PillSegmentedControl> {
  late int _index = widget.initialIndex;

  static const Color _pink = Color(0xFFFF8FB5);
  static const Color _cream = Color(0xFFFFF1E8);
  static const EdgeInsets _padding = EdgeInsets.all(6);

  Alignment _alignmentFor(int i, int len) {
    if (len <= 1) return Alignment.center;
    final step = 2.0 / (len - 1);
    final x = -1.0 + (i * step);
    return Alignment(x, 0);
  }

  @override
  Widget build(BuildContext context) {
    final tabCount = widget.tabs.length.clamp(1, 6);

    return SizedBox(
      width: double.infinity,
      child: Container(
        height: widget.height,
        padding: _padding,
        decoration: BoxDecoration(
          color: _pink,
          borderRadius: BorderRadius.circular(widget.height),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: _alignmentFor(_index, tabCount),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: FractionallySizedBox(
                widthFactor: 1 / tabCount,
                heightFactor: 1,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(widget.height),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: List.generate(tabCount, (i) {
                final selected = i == _index;
                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(widget.height),
                    onTap: () {
                      if (_index != i) {
                        setState(() => _index = i);
                        widget.onChanged(i);
                      }
                    },
                    child: Center(
                      child: Text(
                        widget.tabs[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.heading1.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.textPink
                              : AppColors.textPurple,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
