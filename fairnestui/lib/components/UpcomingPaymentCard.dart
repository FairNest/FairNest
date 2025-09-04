import 'package:fairnestui/pages/Finance/EditFinancePage.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';

class UpcomingPaymentCard extends StatelessWidget {
  const UpcomingPaymentCard({
    super.key,
    required this.title,
    required this.amount,
    this.currency = 'THB',
    required this.daysLeft,
    this.periodLabel = '/month',
    this.width = 180,
    this.height = 150,
    this.onTap,
    this.onKebabTap,
    this.trailingPad = 10.0, // natural right padding
  });

  final String title;
  final int amount;
  final String currency;
  final int daysLeft;
  final String periodLabel;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final VoidCallback? onKebabTap;

  /// Right-side external spacing when used in a horizontal scroller.
  final double trailingPad;

  // Card bg changes when urgent
  Color get _bgColor =>
      (daysLeft <= 3) ? AppColors.primary : const Color(0xFFE2BDD1);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: trailingPad),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Ink(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header row: icon + kebab
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.textPurple,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.textPurple, width: 1),
                      ),
                      child: const Icon(Icons.water_drop,
                          size: 18, color: Colors.white),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: onKebabTap ??
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditFinancePage(
                                  title: title,
                                  dateTime: DateTime.now(),
                                  participants: const [],
                                  category: 'Bill',
                                  totalAmount: amount.toDouble(),
                                  splitType: 'Evenly',
                                  customSplits: null,
                                  paidBy: const [],
                                ),
                              ),
                            );
                          },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.textPurple.withOpacity(.35),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.more_vert,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // title
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPurple,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 6),

                // amount / period
                Text(
                  '${_fmt(amount)} $currency$periodLabel',
                  style: TextStyle(
                    color: AppColors.textPurple.withOpacity(.8),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),

                const Spacer(),

                // days left (goes red + pulses if urgent)
                _PulsingDaysLeft(
                  daysLeft: daysLeft,
                  baseStyle: const TextStyle(
                    color: AppColors.textPurple,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    var c = 0;
    for (var i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      c++;
      if (c == 3 && i != 0) {
        buf.write(',');
        c = 0;
      }
    }
    return buf.toString().split('').reversed.join();
  }
}

/// Pulses the "days left" text and turns it red when daysLeft <= 3
class _PulsingDaysLeft extends StatefulWidget {
  const _PulsingDaysLeft({
    required this.daysLeft,
    required this.baseStyle,
  });

  final int daysLeft;
  final TextStyle baseStyle;

  @override
  State<_PulsingDaysLeft> createState() => _PulsingDaysLeftState();
}

class _PulsingDaysLeftState extends State<_PulsingDaysLeft>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 1.12)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  bool get _urgent => widget.daysLeft <= 3;

  @override
  void initState() {
    super.initState();
    if (_urgent) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _PulsingDaysLeft oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_urgent && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!_urgent && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _urgent ? const Color(0xFFB84B6A) : widget.baseStyle.color;
    final weight = _urgent ? FontWeight.w800 : widget.baseStyle.fontWeight;

    final text = Text(
      '${widget.daysLeft} days left',
      style: widget.baseStyle.copyWith(color: color, fontWeight: weight),
    );

    return _urgent ? ScaleTransition(scale: _scale, child: text) : text;
  }
}
