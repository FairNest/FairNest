import 'package:fairnestui/components/ChoresTaskCard.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/util/DateStrip.dart';

// NEW imports
import 'package:fairnestui/services/api_client.dart';
import 'package:fairnestui/services/user_profile_service.dart';
import 'package:fairnestui/pages/Chores/EditChorePage.dart';

class Chorespage extends StatefulWidget {
  const Chorespage({super.key});

  @override
  State<Chorespage> createState() => _ChorespageState();
}

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

  /// Always the chore_id (needed for GET/PUT/DELETE detail endpoints)
  final int choreId;

  /// Optional chore_assignment_id (useful if you later complete a specific assignment)
  final int? assignmentId;

  final String title;
  final int points;
  final bool autoRotate;
  final String recurrence;
  final String reminderTime; // derived from due_time or reminder_time
  final String reminderRepeat; // derived from recurrence or weekday
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

    // Parse IDs
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

class _ChorespageState extends State<Chorespage> {
  // calendar state for DateStrip
  late DateTime _start;
  late DateTime _selected;
  final int _days = 30;

  // segmented pill state
  int _tab = 0; // 0 = All Tasks, 1 = My Tasks

  // runtime/user/room
  int? _roomId;

  // remote data
  List<_ChoreItem> _allTasks = [];
  List<_ChoreItem> _myTasks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _start = DateTime(now.year, now.month, 1);
    _selected = DateTime(now.year, now.month, now.day);
    _bootstrapAndFetch();
  }

  Future<void> _bootstrapAndFetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1) Try cache first
      var profile = await UserProfileService.instance.getCachedProfile();

      // 2) If cache is empty, fetch (this will populate the cache)
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

      // 3) Fetch chores for the currently selected date
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

      // All tasks
      final respAll = await ApiClient.get(
        '/rooms/${_roomId}/chores/day',
        queryParameters: {'date': ymd},
      );
      final listAll = (respAll.data as List<dynamic>)
          .map((e) => _ChoreItem.fromJson(e as Map<String, dynamic>))
          .toList();

      // My tasks
      final respMine = await ApiClient.get(
        '/rooms/${_roomId}/chores/day/mine',
        queryParameters: {'date': ymd},
      );
      final listMine = (respMine.data as List<dynamic>)
          .map((e) => _ChoreItem.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _allTasks = listAll.where((c) => !c.completed).toList();
        _myTasks = listMine.where((c) => !c.completed).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to fetch chores: $e';
      });
    }
  }

  // Pull-to-refresh & manual reload
  Future<void> _refresh() async {
    await _fetchForDate(_selected);
  }

  // -------- open edit flow --------
  Future<void> _openEditFor(_ChoreItem c) async {
    if (_roomId == null || c.choreId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing room or chore id')),
      );
      return;
    }

    // We can pass the data we already have; EditChorePage will fetch detail and prefill itself.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditChorePage(
          roomId: _roomId!, // ✅ required by EditChorePage
          choreId: c.choreId, // ✅ required by EditChorePage
          title: c.title, // placeholders (overridden by GET)
          dateTime: DateTime.now(),
          assignees: const [],
          category: null,
          recurrence: c.recurrence.isNotEmpty ? c.recurrence : null,
          autoRotate: c.autoRotate,
        ),
      ),
    );

    if (!mounted) return;

    if (result is Map &&
        (result['action'] == 'saved' || result['action'] == 'deleted')) {
      await _refresh();
    }
  }

  /* ------------------- builders ------------------- */
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
      // keep scrollable for pull-to-refresh even when empty
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
                child: ChoresTaskCard(
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
                  onCheckedChanged: (checked) {
                    if (!checked) return;
                    setState(() => c.completed = true);
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
            // Title + manual refresh button
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

            // Horizontal date strip (drives data fetch)
            DateStrip(
              startDate: _start,
              days: _days,
              selectedDate: _selected,
              onDateSelected: (d) {
                setState(() => _selected = d);
                _fetchForDate(d); // fetch when user taps a date
              },
            ),
            const SizedBox(height: 12),

            // Segmented pill with LIVE counts
            _CountSegmentedPill(
              tabs: const ['All Tasks', 'My Tasks'],
              counts: [allCount, myCount],
              initialIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),

              // size controls
              height: 46,
              labelFontSize: 14,
              badgeHeight: 22,
              badgeFontSize: 12,
              badgeRadius: 8,
              badgeHorizontalPadding: 7,
            ),

            const SizedBox(height: 16),

            // Pull-to-refresh wrapper around the tab content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: IndexedStack(
                  index: _tab,
                  children: [
                    _buildList(_allTasks), // All Tasks (incomplete only)
                    _buildList(_myTasks), // My Tasks (incomplete + mine)
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
