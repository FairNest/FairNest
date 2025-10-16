import 'package:fairnestui/components/ChoresTaskCard.dart';
import 'package:fairnestui/widgets/celebration_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/util/DateStrip.dart';

// NEW imports
import 'package:fairnestui/services/api_client.dart';
import 'package:fairnestui/services/user_profile_service.dart';
import 'package:fairnestui/pages/Chores/ViewChorePage.dart';
import 'package:dio/dio.dart' as dio; // ← friendly error mapping

/* ------------------- API model mapped from backend ------------------- */
class _ChoreItem {
  _ChoreItem({
    required this.choreId,
    this.assignmentId,
    required this.title,
    required this.points,
    required this.autoRotate,
    required this.recurrence,
    required this.reminderTime,
    required this.reminderRepeat,
    this.assignedName,
    this.assignedAvatarUrl,
    this.completed = false,
  });

  final int choreId;
  final int? assignmentId;
  final String title;
  final int points;
  final bool autoRotate;
  final String recurrence;
  final String reminderTime;
  final String reminderRepeat;
  final String? assignedName;
  final String? assignedAvatarUrl;

  bool completed;

  factory _ChoreItem.fromJson(Map<String, dynamic> j) {
    final assigned = j['assigned_user'] as Map<String, dynamic>?;
    final dueTime = (j['due_time'] ?? '') as String;
    final reminderTime = (j['reminder_time'] ?? '') as String;

    String timeLabel = dueTime.isNotEmpty
        ? _ChoreItem._hhmmToFriendly(dueTime)
        : (reminderTime.isNotEmpty
            ? _ChoreItem._hhmmToFriendly(reminderTime)
            : '');

    final recurrence = (j['recurrence'] ?? '') as String;
    final weekday = (j['due_day_of_week'] ?? '') as String;
    final repeatLabel = recurrence.isNotEmpty
        ? _prettyRecurrence(recurrence, weekday)
        : weekday;

    final int choreId = (j['chore_id'] is int)
        ? j['chore_id'] as int
        : int.tryParse('${j['chore_id'] ?? 0}') ?? 0;

    final int? assignmentId = (j['chore_assignment_id'] is int)
        ? j['chore_assignment_id'] as int
        : int.tryParse('${j['chore_assignment_id'] ?? ''}');

    final scoreAny = j['chore_score'];
    final points = scoreAny is int ? scoreAny : int.tryParse('$scoreAny') ?? 0;

    return _ChoreItem(
      choreId: choreId,
      assignmentId: assignmentId,
      title: (j['chore_title'] ?? '') as String,
      points: points,
      autoRotate: (j['auto_rotate'] ?? false) as bool,
      recurrence: recurrence,
      reminderTime: timeLabel,
      reminderRepeat: repeatLabel,
      assignedName: assigned?['username'] as String?,
      assignedAvatarUrl: assigned?['userPicture'] as String?,
      completed: ((j['status'] ?? 'pending') == 'completed'),
    );
  }

  static String _hhmmToFriendly(String hhmm) {
    if (hhmm.isEmpty || !hhmm.contains(':')) return hhmm;
    final p = hhmm.split(':');
    int h = int.tryParse(p[0]) ?? 0;
    final m = p.length > 1 ? int.tryParse(p[1]) ?? 0 : 0;
    final am = h < 12;
    final h12 = ((h % 12) == 0) ? 12 : (h % 12);
    final mm = m.toString().padLeft(2, '0');
    return "$h12:$mm ${am ? 'AM' : 'PM'}";
  }

  static String _prettyRecurrence(String recur, String weekday) {
    final r = recur.toLowerCase();
    if (r == 'daily') return 'Every Day';
    if (r == 'weekly') return weekday.isNotEmpty ? 'Every $weekday' : 'Weekly';
    if (r.contains('bi')) return 'Every 2 Weeks';
    return recur;
  }
}

class Chorespage extends StatefulWidget {
  const Chorespage({super.key});

  @override
  State<Chorespage> createState() => _ChorespageState();
}

class _ChorespageState extends State<Chorespage> {
  late DateTime _start;
  late DateTime _selected;
  final int _days = 30;
  int _tab = 0;

  int? _roomId;

  List<_ChoreItem> _allTasks = [];
  List<_ChoreItem> _myTasks = [];
  Set<int> _myAssignmentIds = {}; // ← who am I assigned to?

  bool _loading = true;
  String? _error;

  final Set<int> _completing = {}; // track which assignments are posting

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _start = DateTime(now.year, now.month, 1);
    _selected = DateTime(now.year, now.month, now.day);
    _bootstrapAndFetch();
  }

  bool get _isTodaySelected {
    final now = DateTime.now();
    return _selected.year == now.year &&
        _selected.month == now.month &&
        _selected.day == now.day;
  }

  Future<void> _bootstrapAndFetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      var profile = await UserProfileService.instance.getCachedProfile();
      profile ??= await UserProfileService.instance.getUserProfile();

      if (profile == null) {
        setState(() {
          _loading = false;
          _error =
              'No cached profile found and fetch failed.\nPlease open profile once or re-login.';
        });
        return;
      }

      _roomId = profile.roomId;
      await _fetchForDate(_selected);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to load chores: $e';
      });
    }
  }

  String _toYmd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _fetchForDate(DateTime d) async {
    if (_roomId == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ymd = _toYmd(d);

      final respAll = await ApiClient.get(
        '/rooms/${_roomId}/chores/day',
        queryParameters: {'date': ymd},
      );
      final listAll = (respAll.data as List<dynamic>)
          .map((e) => _ChoreItem.fromJson(e as Map<String, dynamic>))
          .toList();

      final respMine = await ApiClient.get(
        '/rooms/${_roomId}/chores/day/mine',
        queryParameters: {'date': ymd},
      );
      final listMine = (respMine.data as List<dynamic>)
          .map((e) => _ChoreItem.fromJson(e as Map<String, dynamic>))
          .toList();

      // Build “my assignments” lookup for quick ownership checks
      final myAssignmentIds = listMine
          .map((c) => c.assignmentId)
          .where((id) => id != null)
          .cast<int>()
          .toSet();

      setState(() {
        _allTasks = listAll.where((c) => !c.completed).toList();
        _myTasks = listMine.where((c) => !c.completed).toList();
        _myAssignmentIds = myAssignmentIds;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to fetch chores: $e';
      });
    }
  }

  Future<void> _refresh() async {
    await _fetchForDate(_selected);
  }

  Future<void> _openEditFor(_ChoreItem c) async {
    if (_roomId == null || c.choreId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing room or chore id')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewChorePage(
          roomId: _roomId!,
          choreId: c.choreId,
        ),
      ),
    );

    if (!mounted) return;
    if (result is Map && result['action'] == 'deleted') {
      await _refresh();
    }
  }

  String _friendlyError(Object e) {
    if (e is dio.DioException) {
      final code = e.response?.statusCode ?? 0;
      switch (code) {
        case 400:
          return "Bad request. Please try again.";
        case 401:
          return "You’re not signed in.";
        case 403:
          return "It's not your task.";
        case 404:
          return "Task not found.";
        case 409:
          return "Already completed.";
        case 422:
          return "Invalid data.";
        case 500:
          return "Server error. Please try again.";
        default:
          return "Network error (${code == 0 ? 'no response' : code}).";
      }
    }
    return "Something went wrong.";
  }

  Future<void> _markComplete(_ChoreItem c) async {
    if (c.assignmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing chore_assignment_id')),
      );
      return;
    }
    if (_completing.contains(c.assignmentId)) return;

    setState(() => _completing.add(c.assignmentId!));
    try {
      await ApiClient.post('/chores/complete', data: {
        'chore_assignment_id': c.assignmentId,
      });

      setState(() {
        c.completed = true;
        _allTasks.removeWhere((x) => x.assignmentId == c.assignmentId);
        _myTasks.removeWhere((x) => x.assignmentId == c.assignmentId);
      });

      CelebrationPopup.show(
        context,
        message: 'Task Completed!\nGreat job! 🎉',
        backgroundColor: const Color(0xFFF8F9FA),
        textColor: const Color(0xFF2D3748),
        autoCloseDuration: const Duration(seconds: 2),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyError(e))),
      );
    } finally {
      if (mounted) {
        setState(() => _completing.remove(c.assignmentId));
      }
    }
  }

  Widget _buildList(List<_ChoreItem> items) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (items.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: const _EmptyArea(label: 'No chores here 🎉'),
      );
    }
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          for (final c in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openEditFor(c),
                child: Builder(
                  builder: (context) {
                    final bool isMine = c.assignmentId != null &&
                        _myAssignmentIds.contains(c.assignmentId);
                    final bool canComplete = _isTodaySelected && isMine;
                    final String lockMsg = isMine
                        ? "Only today's chores\ncan be completed"
                        : "You can't complete\nother people’s task";

                    return ChoresTaskCard(
                      title: c.title,
                      points: c.points,
                      assignedName: c.assignedName ?? '—',
                      autoRotate: c.autoRotate,
                      recurrence: c.recurrence,
                      reminderTime: c.reminderTime,
                      reminderRepeat: c.reminderRepeat,
                      paidByImage: (c.assignedAvatarUrl != null &&
                              c.assignedAvatarUrl!.isNotEmpty)
                          ? NetworkImage(c.assignedAvatarUrl!)
                          : const AssetImage('assets/images/pikachu.png')
                              as ImageProvider,
                      initiallyChecked: false,

                      // 🔒 Lock when not today OR not mine (and explain why)
                      completionEnabled: canComplete,
                      lockMessage: lockMsg,

                      onCheckedChanged: (checked) {
                        // Hard gates to avoid hitting the API unnecessarily
                        if (!isMine) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("It's not your task.")),
                          );
                          return;
                        }
                        if (!_isTodaySelected) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "You can only complete today's chores.")),
                          );
                          return;
                        }
                        if (!checked) return;
                        if (c.assignmentId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No assignment id')),
                          );
                          return;
                        }
                        if (_completing.contains(c.assignmentId)) return;
                        _markComplete(c);
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allCount = _allTasks.length;
    final myCount = _myTasks.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Chores & Tasks",
                  style:
                      AppFonts.heading1.copyWith(color: AppColors.textPurple),
                ),
                IconButton(
                  tooltip: 'Reload',
                  icon: const Icon(Icons.refresh),
                  onPressed: _loading ? null : _refresh,
                ),
              ],
            ),
            const SizedBox(height: 12),
            DateStrip(
              startDate: _start,
              days: _days,
              selectedDate: _selected,
              onDateSelected: (d) {
                setState(() => _selected = d);
                _fetchForDate(d);
              },
            ),
            const SizedBox(height: 12),
            _CountSegmentedPill(
              tabs: const ['All Tasks', 'My Tasks'],
              counts: [allCount, myCount],
              initialIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),
              height: 46,
              labelFontSize: 14,
              badgeHeight: 22,
              badgeFontSize: 12,
              badgeRadius: 8,
              badgeHorizontalPadding: 7,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: IndexedStack(
                  index: _tab,
                  children: [
                    _buildList(_allTasks),
                    _buildList(_myTasks),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ------------------- empty state box ------------------- */

class _EmptyArea extends StatelessWidget {
  const _EmptyArea({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.textPurple.withValues(alpha: .25)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/* ------------------- segmented pill (unchanged) ------------------- */

class _CountSegmentedPill extends StatefulWidget {
  const _CountSegmentedPill({
    required this.tabs,
    required this.counts,
    required this.onChanged,
    this.initialIndex = 0,
    this.height = 44,
    this.labelFontSize = 14,
    this.badgeHeight = 22,
    this.badgeWidth,
    this.badgeFontSize = 12,
    this.badgeRadius = 8,
    this.badgeHorizontalPadding = 7,
    super.key,
  }) : assert(tabs.length == counts.length);

  final List<String> tabs;
  final List<int> counts;
  final int initialIndex;
  final ValueChanged<int> onChanged;
  final double height;

  final double labelFontSize;
  final double badgeHeight;
  final double? badgeWidth;
  final double badgeFontSize;
  final double badgeRadius;
  final double badgeHorizontalPadding;

  @override
  State<_CountSegmentedPill> createState() => _CountSegmentedPillState();
}

class _CountSegmentedPillState extends State<_CountSegmentedPill> {
  late int _index = widget.initialIndex;

  static const Color _trackPink = Color(0xFFFF8FB5);
  static const Color _thumbCream = AppColors.background;
  static const Color _labelPurple = AppColors.textPurple;
  static const Color _badgeFill = AppColors.textPink;
  static const EdgeInsets _padding = EdgeInsets.all(6);

  Alignment _alignmentFor(int i, int len) {
    if (len <= 1) return Alignment.center;
    final step = 2.0 / (len - 1);
    return Alignment(-1.0 + i * step, 0);
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
          color: _trackPink,
          borderRadius: BorderRadius.circular(widget.height),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: _alignmentFor(_index, tabCount),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: FractionallySizedBox(
                widthFactor: 1 / tabCount,
                heightFactor: 1,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: _thumbCream,
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.tabs[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.heading1.copyWith(
                              fontSize: widget.labelFontSize,
                              fontWeight: FontWeight.w700,
                              color: _labelPurple,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _MiniCountBadge(
                            value: widget.counts[i],
                            height: widget.badgeHeight,
                            width: widget.badgeWidth,
                            radius: widget.badgeRadius,
                            fontSize: widget.badgeFontSize,
                            paddingH: widget.badgeHorizontalPadding,
                          ),
                        ],
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

class _MiniCountBadge extends StatelessWidget {
  const _MiniCountBadge({
    required this.value,
    this.height = 20,
    this.width,
    this.radius = 2,
    this.fontSize = 12,
    this.paddingH = 10,
  });

  final int value;
  final double height;
  final double? width;
  final double? radius;
  final double fontSize;
  final double paddingH;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? height / 2;
    final decoration = BoxDecoration(
      color: _CountSegmentedPillState._badgeFill,
      borderRadius: BorderRadius.circular(r),
    );

    if (width != null) {
      return Container(
        height: height,
        width: width,
        decoration: decoration,
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

    return Container(
      height: height,
      constraints: BoxConstraints(minWidth: height),
      padding: EdgeInsets.symmetric(horizontal: paddingH),
      decoration: decoration,
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
