import 'package:fairnestui/components/ChoresTaskCard.dart';
import 'package:fairnestui/components/FInanceTaskCard.dart';
import 'package:fairnestui/model/user_dashboard_model.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/services/api_client.dart';
import 'package:fairnestui/widgets/celebration_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class TaskNavFolder extends StatefulWidget {
  const TaskNavFolder({
    super.key,
    this.panelHeight = 520,
    required this.todayUnfinishedCount,
    required this.completedCount,
    required this.upcomingUnfinishedCount,
    required this.todayUnfinishedTasks,
    required this.completedTasks,
    required this.upcomingUnfinishedTasks,
    this.onTaskCompleted,
  });

  final double panelHeight;
  final int todayUnfinishedCount;
  final int completedCount;
  final int upcomingUnfinishedCount;

  final UserTasksSeparatedResponse todayUnfinishedTasks;
  final UserTasksSeparatedResponse completedTasks;
  final UserTasksSeparatedResponse upcomingUnfinishedTasks;

  final VoidCallback? onTaskCompleted;

  @override
  State<TaskNavFolder> createState() => _TaskNavFolderState();
}

class _TaskNavFolderState extends State<TaskNavFolder> {
  int activeIndex = 0;

  final Set<int> _completingChores = {};
  final Set<int> _completingFinances = {};

  static const _cream = Color(0xFFFFF1E8);
  final tabs = const [
    {"label": "Today", "color": Color(0xFFFADDE1)},
    {"label": "Completed", "color": Color(0xFFD6F2DB)},
    {"label": "Upcoming", "color": Color(0xFFD6DFF2)},
  ];

  String _headerTitle() {
    switch (activeIndex) {
      case 0:
        return "Current Tasks";
      case 1:
        return "Completed Tasks";
      case 2:
        return "Upcoming Tasks";
      default:
        return "Tasks";
    }
  }

  int _headerCount() {
    switch (activeIndex) {
      case 0:
        return widget.todayUnfinishedCount;
      case 1:
        return widget.completedCount;
      case 2:
        return widget.upcomingUnfinishedCount;
      default:
        return 0;
    }
  }

  Future<void> _markChoreComplete(UserChoreItem chore) async {
    if (_completingChores.contains(chore.choreAssignmentId)) return;

    setState(() => _completingChores.add(chore.choreAssignmentId));

    try {
      await ApiClient.post('/chores/complete', data: {
        'chore_assignment_id': chore.choreAssignmentId,
      });

      if (!mounted) return;

      CelebrationPopup.show(
        context,
        message: 'Task Completed!\nGreat job! 🎉',
        backgroundColor: const Color(0xFFF8F9FA),
        textColor: const Color(0xFF2D3748),
        autoCloseDuration: const Duration(seconds: 2),
      );

      widget.onTaskCompleted?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete chore: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _completingChores.remove(chore.choreAssignmentId));
      }
    }
  }

// Updated _markFinancePaid method in TaskNavFolder with better error handling

  Future<void> _markFinancePaid(UserFinanceItem finance) async {
    if (_completingFinances.contains(finance.transactionId)) return;

    setState(() => _completingFinances.add(finance.transactionId));

    // Track if dialog is showing to prevent multiple pop attempts
    bool dialogShowing = true;

    // Show loading dialog with a specific route name
    showDialog(
      context: context,
      barrierDismissible: false,
      routeSettings: const RouteSettings(name: 'payment_verification'),
      builder: (dialogContext) => const PopScope(
        canPop: false, // Prevent back button from closing
        child: Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Verifying payment...'),
                ],
              ),
            ),
          ),
        ),
      ),
    ).then((_) {
      dialogShowing = false;
    });

    try {
      final isSucceeded = await _pollPaymentStatus(finance.transactionId);

      // Only try to pop if dialog is still showing and context is still mounted
      if (mounted && dialogShowing) {
        // Check if we can pop and if the current route is our dialog
        if (Navigator.of(context).canPop()) {
          // Use careful navigation to only pop the dialog
          Navigator.of(context).popUntil((route) {
            // Stop popping when we reach the dialog or the base route
            return route.settings.name != 'payment_verification';
          });
        }
        dialogShowing = false;
      }

      if (isSucceeded && mounted) {
        // Small delay to ensure dialog is fully closed
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        CelebrationPopup.show(
          context,
          message: 'Payment Settled!\nWell done! 💰',
          backgroundColor: const Color(0xFFF8F9FA),
          textColor: const Color(0xFF2D3748),
          autoCloseDuration: const Duration(seconds: 2),
        );

        widget.onTaskCompleted?.call();
      } else if (mounted) {
        // Show timeout message instead of throwing error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment verification timed out. Please try again.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in payment verification: $e');
      }

      // Safely close dialog if still open
      if (mounted && dialogShowing) {
        if (Navigator.of(context).canPop()) {
          // Only pop if we're sure the dialog is on top
          final currentRoute = ModalRoute.of(context);
          if (currentRoute?.settings.name == 'payment_verification' ||
              currentRoute?.isCurrent == true) {
            Navigator.of(context).pop();
          }
        }
        dialogShowing = false;
      }

      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment verification failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _completingFinances.remove(finance.transactionId));
      }
    }
  }

// Updated _pollPaymentStatus with better error handling
  Future<bool> _pollPaymentStatus(int transactionId) async {
    const maxAttempts = 15; // 30 seconds total

    // Add timeout wrapper to prevent infinite waiting
    try {
      return await Future.any([
        _performPolling(transactionId, maxAttempts),
        Future.delayed(
          const Duration(seconds: 35), // Slightly longer than max polling time
          () => false, // Return false on timeout
        ),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Polling failed with error: $e');
      }
      return false;
    }
  }

  Future<bool> _performPolling(int transactionId, int maxAttempts) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      // Check if widget is still mounted before each attempt
      if (!mounted) {
        if (kDebugMode) {
          print('⚠️ Widget unmounted, stopping payment polling');
        }
        return false;
      }

      try {
        if (kDebugMode) {
          print(
              '🔄 Polling payment status (attempt ${attempts + 1}/$maxAttempts)');
        }

        final response = await ApiClient.get(
          '/GetPaymentStatusByTransactionID/$transactionId',
        ).timeout(
          const Duration(seconds: 5), // Add timeout for each request
          onTimeout: () {
            throw Exception('Request timeout');
          },
        );

        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          final status = data['status'] as String?;

          if (kDebugMode) {
            print('📊 Payment status: $status');
          }

          if (status == 'succeeded') {
            if (kDebugMode) {
              print('✅ Payment succeeded!');
            }
            return true;
          }

          // Check for failure status to stop polling early
          if (status == 'failed' || status == 'cancelled') {
            if (kDebugMode) {
              print('❌ Payment failed or cancelled: $status');
            }
            return false;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print(
              '⚠️ Error polling payment status (attempt ${attempts + 1}): $e');
        }
        // Continue polling even on error
      }

      attempts++;

      // Don't wait on the last attempt
      if (attempts < maxAttempts && mounted) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    if (kDebugMode) {
      print('❌ Payment status polling completed without success');
    }
    return false;
  }

  Widget _buildChoreCard(UserChoreItem chore) {
    final isCompleting = _completingChores.contains(chore.choreAssignmentId);

    // Which tab are we on?
    final bool isTodayTab = activeIndex == 0;
    final bool isCompletedTab = activeIndex == 1;
    final bool isUpcomingTab = activeIndex == 2;

    // Enable completion only on Today tab
    final bool completionEnabled = isTodayTab;

    // Message to show when completion is disabled
    final String lockMessage = isUpcomingTab
        ? "Only today's chores\ncan be completed"
        : (isCompletedTab ? "Already completed" : "");

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          ChoresTaskCard(
            title: chore.title,
            points: chore.points,
            assignedName: chore.assignedName ?? 'You',
            autoRotate: chore.autoRotate ?? false,
            recurrence: chore.recurrence ?? 'Once',
            reminderTime: chore.reminderTime ?? '--:--',
            reminderRepeat: chore.reminderRepeat ?? 'No repeat',
            paidByImage: chore.assignedAvatar != null
                ? NetworkImage(chore.assignedAvatar!)
                : const AssetImage('assets/images/default_avatar.png')
                    as ImageProvider,

            // Whatever your source says about completion (usually false in Today/Upcoming)
            initiallyChecked: chore.isCompleted == true,

            // 🔒 key bits:
            completionEnabled: completionEnabled,
            lockMessage: lockMessage,

            onCheckedChanged: (checked) {
              // Guard: don’t allow completion from Upcoming/Completed tabs
              if (!completionEnabled) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(lockMessage.replaceAll('\n', ' '))),
                );
                return;
              }

              if (!checked) return;
              if (_completingChores.contains(chore.choreAssignmentId)) return;

              _markChoreComplete(chore);
            },
          ),
          if (isCompleting)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.textPink),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Update the _buildFinanceCard method in TaskNavFolder to pass isCompleted:

// Update the _buildFinanceCard method in TaskNavFolder to pass isCompleted:

  Widget _buildFinanceCard(UserFinanceItem finance) {
    final isCompleting = _completingFinances.contains(finance.transactionId);

    // Determine if we're in the completed tab
    final isInCompletedTab = activeIndex == 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          Financetaskcard(
            title: finance.title,
            amount: finance.amount ?? 0,
            totalAmount: finance.totalAmount ?? 0,
            points: finance.points,
            splitType: finance.splitType == 'custom'
                ? SplitType.custom
                : SplitType.even,
            splitCount: finance.splitCount,
            customSplitLabel: finance.splitType == 'custom' ? 'Custom' : null,
            currency: 'THB',
            payToName: finance.payToName ?? 'Roommate',
            paidByImage: finance.payToAvatar != null
                ? NetworkImage(finance.payToAvatar!)
                : const AssetImage('assets/images/default_avatar.png')
                    as ImageProvider,
            qrData: finance.qrCode,
            isCompleted: isInCompletedTab ||
                finance.isCompleted == true, // ADD THIS LINE
            onSettled: () {
              // Don't allow settling if already completed
              if (isInCompletedTab || finance.isCompleted == true) return;
              if (_completingFinances.contains(finance.transactionId)) return;
              _markFinancePaid(finance);
            },
          ),
          if (isCompleting)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.textPink,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    UserTasksSeparatedResponse tasks;
    String emptyMessage;

    switch (activeIndex) {
      case 0:
        tasks = widget.todayUnfinishedTasks;
        emptyMessage = "No tasks for today 🎉";
        break;
      case 1:
        tasks = widget.completedTasks;
        emptyMessage = "Nothing completed yet.";
        break;
      case 2:
        tasks = widget.upcomingUnfinishedTasks;
        emptyMessage = "No upcoming tasks.";
        break;
      default:
        tasks = UserTasksSeparatedResponse(chores: [], finances: []);
        emptyMessage = "No tasks.";
    }

    if (tasks.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Center(
            child: Text(
              emptyMessage,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      key: PageStorageKey('scroll_$activeIndex'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...tasks.finances.map((finance) => _buildFinanceCard(finance)),
          ...tasks.chores.map((chore) => _buildChoreCard(chore)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.panelHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
            child: Row(
              children: [
                Text(
                  _headerTitle(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C2D3C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _headerCount().toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 48,
                  child: Column(
                    children: List.generate(tabs.length, (i) {
                      final tab = tabs[i];
                      return Expanded(
                        child: _SideTab(
                          label: tab["label"] as String,
                          baseColor: tab["color"] as Color,
                          isActive: activeIndex == i,
                          activeColor: _cream,
                          onTap: () => setState(() => activeIndex = i),
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black45, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildTabContent(context),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideTab extends StatefulWidget {
  const _SideTab({
    required this.label,
    required this.baseColor,
    required this.isActive,
    required this.onTap,
    this.activeColor = const Color(0xFFFFF1E8),
  });

  final String label;
  final Color baseColor;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;

  @override
  State<_SideTab> createState() => _SideTabState();
}

class _SideTabState extends State<_SideTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 120),
    );
    _scale = Tween(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pop, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isActive;

    return ScaleTransition(
      scale: _scale,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          splashColor: Colors.black12,
          onTap: () async {
            await _pop.forward(from: 0);
            if (mounted) _pop.reverse();
            widget.onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: isActive ? widget.activeColor : widget.baseColor,
              border: isActive
                  ? Border.all(color: Colors.black45, width: 1.5)
                  : null,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isActive ? 0.18 : 0.12),
                  blurRadius: isActive ? 6 : 4,
                  offset: Offset(0, isActive ? 3 : 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: RotatedBox(
              quarterTurns: -1,
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
