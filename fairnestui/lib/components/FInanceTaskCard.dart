import 'package:fairnestui/components/AccentBorderedCard.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Financetaskcard extends StatelessWidget {
  const Financetaskcard({
    super.key,
    this.paidByImage,
    this.paidByRingColor = AppColors.textPurple,
    this.onSettleNow, // <-- tap handler
  });

  final ImageProvider? paidByImage;
  final Color paidByRingColor;
  final VoidCallback? onSettleNow;

  @override
  Widget build(BuildContext context) {
    const Color iconBg = AppColors.textPurple;
    const Color titleColor = AppColors.textPurple;
    const Color badgeBg = AppColors.accent;

    return AccentBorderedCard(
      child: SizedBox(
        height: 170, // a bit taller to fit the button comfortably
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER ROW
            SizedBox(
              height: 36,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // circular icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.receipt_long_rounded,
                        color: AppColors.background, size: 20),
                  ),
                  const SizedBox(width: 10),

                  // title
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Water Bill - March',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // +10 badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      '+10',
                      style: TextStyle(
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

            // Row of little stat chips (Total / Split / You Owe)
            Row(
              children: const [
                _StatChip(
                    label: "Total", color: Color(0xFF8D8B8B), text: "400 Baht"),
                SizedBox(width: 15),
                _StatChip(
                    label: "Split", color: Color(0xFF8D8B8B), text: "Even"),
                SizedBox(width: 15),
                _StatChip(
                    label: "You Owe",
                    color: AppColors.textOrange,
                    text: '200 Baht'),
              ],
            ),

            const SizedBox(height: 10),

            // Paid By + avatar
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Paid By",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: paidByRingColor.withOpacity(0.15),
                      ),
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: 13,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: paidByImage,
                        child: paidByImage == null
                            ? const Icon(Icons.person,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const SizedBox(
                      width: 35,
                      child: Text(
                        "Max",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                Spacer(
                  flex: 3,
                ),

                // SETTLE NOW button (fills remaining width nicely)
                Expanded(
                  flex: 30,
                  child: _SettleNowButton(
                    text: 'Settle Now',
                    onTap: onSettleNow,
                  ),
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          height: 18,
          width: 70,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
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

/// Lavender pill button with purple border + small shadow.
class _SettleNowButton extends StatelessWidget {
  const _SettleNowButton({required this.text, this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const lavenderFill = Color(0xFFD9CFF1); // soft lavender
    const purpleBorder = Color(0xFF645A80); // text/border purple

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 38,
          decoration: BoxDecoration(
            color: lavenderFill,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: purpleBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: purpleBorder,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
