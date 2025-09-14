import 'package:fairnestui/components/AccentBorderedCard.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ChoresTaskCard extends StatefulWidget {
  const ChoresTaskCard({
    super.key,

    // NEW configurable fields
    this.title = 'Take Out the Trash',
    this.points = 10,
    this.assignedName = 'Max',
    this.autoRotate = true,
    this.recurrence = 'Weekly',
    this.reminderTime = '4PM',
    this.reminderRepeat = 'Every Tue',

    // existing
    this.paidByImage, // avatar for the assignee
    this.paidByRingColor = AppColors.textPurple,
    this.onReminderTap,
    this.initiallyChecked = false,
    this.onCheckedChanged,
  });

  // --- configurable content ---
  final String title;
  final int points;
  final String assignedName;
  final bool autoRotate;
  final String recurrence;
  final String reminderTime; // shown in "Reminder Time <X>"
  final String reminderRepeat; // pill text

  // --- existing props ---
  final ImageProvider? paidByImage; // assignee avatar
  final Color paidByRingColor;
  final VoidCallback? onReminderTap;

  /// checkbox state
  final bool initiallyChecked;
  final ValueChanged<bool>? onCheckedChanged;

  @override
  State<ChoresTaskCard> createState() => _ChoresTaskCardState();
}

class _ChoresTaskCardState extends State<ChoresTaskCard> {
  static const _purple = Color(0xFF645A80);
  static const _lavender = Color(0xFFD9CFF1);

  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.initiallyChecked;
  }

  // Keep card in sync if parent updates initiallyChecked later
  @override
  void didUpdateWidget(covariant ChoresTaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyChecked != widget.initiallyChecked) {
      _checked = widget.initiallyChecked;
    }
  }

  void _toggleChecked() {
    setState(() => _checked = !_checked);
    widget.onCheckedChanged?.call(_checked); // notify parent
  }

  @override
  Widget build(BuildContext context) {
    const Color iconBg = AppColors.textPurple;
    const Color titleColor = AppColors.textPurple;
    const Color badgeBg = AppColors.accent;

    // Live “Status” chip based on _checked
    final String statusText = _checked ? 'Completed' : 'Incomplete';
    final Color statusColor =
        _checked ? const Color(0xFF49B67A) : AppColors.textOrange;

    return AccentBorderedCard(
      child: SizedBox(
        height: 170,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            SizedBox(
              height: 36,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                        color: iconBg, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const Icon(Icons.receipt_long_rounded,
                        color: AppColors.background, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              titleColor.withValues(alpha: _checked ? 0.65 : 1),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          decoration: _checked
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '+${widget.points}',
                      style: const TextStyle(
                        color: AppColors.textOrange,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // CHIPS
            Row(
              children: [
                _StatChip(
                  label: "Auto-Rotate",
                  color: const Color(0xFF8D8B8B),
                  text: widget.autoRotate ? "Yes" : "No",
                ),
                const SizedBox(width: 15),
                _StatChip(
                  label: "Recurrence",
                  color: const Color(0xFF8D8B8B),
                  text: widget.recurrence,
                ),
                const SizedBox(width: 15),
                // Status chip (reacts to checkbox)
                _StatChip(
                    label: "Status", color: statusColor, text: statusText),
              ],
            ),

            const SizedBox(height: 10),

            // BOTTOM ROW
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Assigned to
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Assigned to",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPurple)),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 11.0),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.paidByRingColor.withValues(alpha: .15),
                        ),
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          radius: 13,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: widget.paidByImage,
                          child: widget.paidByImage == null
                              ? const Icon(Icons.person,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      width: 60,
                      child: Text(
                        widget.assignedName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPurple),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // Reminder pill
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Reminder Time ${widget.reminderTime}",
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPurple)),
                    const SizedBox(height: 6),
                    _MiniLavenderPill(
                      text: widget.reminderRepeat,
                      icon: Icons.sync,
                      onTap: widget.onReminderTap,
                    ),
                  ],
                ),

                const Spacer(),

                // Clickable checkbox
                _CheckBoxSquare(
                  checked: _checked,
                  onTap: _toggleChecked,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.label, required this.color, required this.text});
  final String label;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPurple)),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 18,
          width: 70,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
          alignment: Alignment.center,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.background,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniLavenderPill extends StatelessWidget {
  const _MiniLavenderPill({required this.text, this.icon, this.onTap});
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const lavenderFill = Color(0xFFD9CFF1);
    const purple = Color(0xFF645A80);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: lavenderFill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: purple, width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: .10),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: purple),
                const SizedBox(width: 6),
              ],
              Text(text,
                  style: const TextStyle(
                      color: purple, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Clickable square checkbox styled like your mock.
class _CheckBoxSquare extends StatelessWidget {
  const _CheckBoxSquare({required this.checked, required this.onTap});
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF645A80);
    const lavender = Color(0xFFD9CFF1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: checked ? lavender : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: purple, width: 2),
          ),
          child:
              checked ? const Icon(Icons.check, size: 20, color: purple) : null,
        ),
      ),
    );
  }
}
