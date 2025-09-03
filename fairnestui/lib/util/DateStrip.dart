import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';

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

  @override
  void didUpdateWidget(covariant DateStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _scrollToSelected();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  void _scrollToSelected() {
    final idx = _daysBetween(widget.startDate, _dateOnly(widget.selectedDate));
    if (idx < 0 || idx >= widget.days || !_controller.hasClients) return;
    final target = idx * (widget.itemWidth + widget.spacing) - 16;
    _controller.animateTo(
      target.clamp(0, _controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthName = _monthName(widget.selectedDate.month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month label
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

        // Horizontal scroller
        SizedBox(
          height: widget.itemHeight,
          child: ListView.separated(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: widget.days,
            separatorBuilder: (_, __) => SizedBox(width: widget.spacing),
            itemBuilder: (context, i) {
              final date = _dateOnly(widget.startDate.add(Duration(days: i)));
              final isSelected = _isSameDate(date, widget.selectedDate);

              // text turns white when selected, otherwise purple
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

  // Helpers (no intl needed)
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

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  static bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  static int _daysBetween(DateTime start, DateTime end) =>
      _dateOnly(end).difference(_dateOnly(start)).inDays;
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
    final dayClr = isSelected ? textColor : textColor.withOpacity(0.70);
    final weekClr = isSelected ? textColor : textColor.withOpacity(0.65);

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
            border: Border.all(color: borderColor.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
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
