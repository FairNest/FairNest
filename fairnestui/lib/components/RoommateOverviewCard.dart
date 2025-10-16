import 'package:fairnestui/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum FinanceStatus { owesYou, youOwe, allSettled }

class Roommateoverviewcard extends StatelessWidget {
  const Roommateoverviewcard({
    super.key,
    this.avatarImage,
    this.avatarColor, // optional ring/bg color
    required this.name,
    required this.tasksCompleted,
    required this.tasksTotal,
    required this.amount,
    required this.financeStatus,
    required this.compatibilityScore,
    this.currencyLabel = 'THB',
  });

  final ImageProvider? avatarImage;
  final Color? avatarColor;
  final String name;

  final int tasksCompleted;
  final int tasksTotal;

  final int amount;
  final FinanceStatus financeStatus;
  final String currencyLabel;

  final int compatibilityScore;

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String badgeLabel;
    switch (financeStatus) {
      case FinanceStatus.owesYou:
        badgeColor = AppColors.accent; // orange
        badgeLabel = "Owes You";
        break;
      case FinanceStatus.youOwe:
        badgeColor = const Color(0xFF9DCDAA); // blue
        badgeLabel = "You Owe";
        break;
      case FinanceStatus.allSettled:
        badgeColor = AppColors.textPurple; // green
        badgeLabel = "All Settled";
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 21),
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    (avatarColor ?? AppColors.textOrange).withValues(alpha: .6),
                backgroundImage: avatarImage,
                child: avatarImage == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: 60,
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 100,
            width: 260,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF645A80), width: 2),
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFDED6CB),
              ),
              child: Row(
                children: [
                  // Tasks card
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 80,
                      width: 70,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFF645A80), width: 2),
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.primary,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (tasksTotal == 0 && tasksCompleted == 0)
                              const Text(
                                "No tasks today",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              )
                            else ...[
                              Text(
                                "$tasksCompleted/$tasksTotal",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Tasks Completed",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Finance card
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 80,
                      width: 70,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFF645A80), width: 2),
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.primary,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$amount",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              currencyLabel,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Container(
                              height: 15,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: badgeColor,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                badgeLabel,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Compatibility card
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 80,
                      width: 70,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFF645A80), width: 2),
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.primary,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: compatibilityScore.toString().length <= 2
                                    ? 6
                                    : 3,
                              ),
                              child: Text(
                                "$compatibilityScore%",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "Compatibility Match",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
