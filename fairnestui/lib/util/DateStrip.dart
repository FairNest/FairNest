import 'package:flutter/material.dart';

class DateStrip extends StatefulWidget {
  const DateStrip({
    super.key,
    required this.startDate,
    required this.days,
    required this.selectedDate,
    required this.onDateSelected,
    this.itemWidth = 70,
    this.itemHeight = 80,
    this.spacing = 25,
  });

  final DateTime startDate;
  final int days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  final double itemWidth;
  final double itemHeight;
  final double spacing;

  @override
  State<DateStrip> createState() => _DateStripState();
}

class _DateStripState extends State<DateStrip> {
  final _controller = ScrollController();

  static const _lavender = Color(0xFFD9CFF1);
  static const _lavenderDark = Color.fromARGB(255, 84, 67, 129);
  static const _purple = Color(0xFF645A80);

  // ---- Helpers (no intl needed) ----
  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  static bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  static int _daysBetween(DateTime start, DateTime end) =>
      _dateOnly(end).difference(_dateOnly(start)).inDays;

  DateTime get _today => _dateOnly(DateTime.now());

  /// Earliest date shown (today or startDate, whichever is later)
  DateTime get _effectiveStart {
    final start = _dateOnly(widget.startDate);
    return start.isBefore(_today) ? _today : start;
  }

  /// Remaining number of days to show from effectiveStart
  int get _remainingDays {
    final skipped = _daysBetween(_dateOnly(widget.startDate), _effectiveStart)
        .clamp(0, widget.days);
    return (widget.days - skipped).clamp(0, widget.days);
  }

  /// If selected is in the past, clamp it to effectiveStart (today)
  DateTime get _selectedClamped => widget.selectedDate.isBefore(_effectiveStart)
      ? _effectiveStart
      : _dateOnly(widget.selectedDate);

  @override
  void didUpdateWidget(covariant DateStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.startDate != widget.startDate ||
        oldWidget.days != widget.days) {
      _scrollToSelected();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  void _scrollToSelected() {
    if (!_controller.hasClients) return;
    final idx = _daysBetween(_effectiveStart, _selectedClamped);
    final itemCount = _remainingDays;
    if (idx < 0 || idx >= itemCount) return;

    final target = idx * (widget.itemWidth + widget.spacing) - 16;
    _controller.animateTo(
      target.clamp(0, _controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedForUi = _selectedClamped;
    final monthName = _monthName(selectedForUi.month);
    final itemCount = _remainingDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month label (based on clamped selection)
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            monthName,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: _purple,
            ),
          ),
        ),

        // Horizontal scroller (today/effectiveStart onward only)
        SizedBox(
          height: widget.itemHeight,
          child: ListView.separated(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: itemCount,
            separatorBuilder: (_, __) => SizedBox(width: widget.spacing),
            itemBuilder: (context, i) {
              final date = _dateOnly(_effectiveStart.add(Duration(days: i)));
              final isSelected = _isSameDate(date, selectedForUi);

              // text turns light when selected, otherwise purple
              final fg = isSelected
                  ? const Color.fromARGB(255, 230, 229, 229)
                  : _purple;

              return _DateChip(
                date: date,
                isSelected: isSelected,
                width: widget.itemWidth,
                height: widget.itemHeight,
                onTap: () => widget.onDateSelected(date),
                bgColor: isSelected ? _lavenderDark : _lavender,
                textColor: fg,
                borderColor: _purple, // keep border purple in both states
              );
            },
          ),
        ),
      ],
    );
  }

  static String _monthName(int m) => const [
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ][m];

  static String _weekdayShort(int w) =>
      const ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w];
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.date,
    required this.isSelected,
    required this.width,
    required this.height,
    required this.onTap,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
  });

  final DateTime date;
  final bool isSelected;
  final double width;
  final double height;
  final VoidCallback onTap;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final dayNum = date.day.toString();
    final weekday = _weekdayShort(date.weekday);

    // use stronger contrast when selected, softer when not
    final dayClr = isSelected ? textColor : textColor.withValues(alpha: .7);
    final weekClr = isSelected ? textColor : textColor.withValues(alpha: .65);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: borderColor.withValues(alpha: .5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .06),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayNum,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: dayClr,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                weekday,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: weekClr,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _weekdayShort(int w) =>
      const ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w];
}
