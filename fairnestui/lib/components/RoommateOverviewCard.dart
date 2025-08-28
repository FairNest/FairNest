import 'package:fairnestui/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Roommateoverviewcard extends StatelessWidget {
  const Roommateoverviewcard({
    super.key,
    this.avatarImage, // AssetImage / NetworkImage / null
    this.avatarColor, // optional ring/bg color
    this.name, // optional name label
    required this.compatibilityScore, //
  });

  final ImageProvider? avatarImage;
  final Color? avatarColor;
  final String? name;
  final int compatibilityScore; //

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 21),
            CircleAvatar(
              radius: 24,
              backgroundColor:
                  (avatarColor ?? AppColors.textOrange).withOpacity(0.6),
              backgroundImage: avatarImage,
              child: avatarImage == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 5),
            if (name != null) ...[
              const SizedBox(width: 8),
              Text(
                name!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(width: 15),
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
                        children: const [
                          Text(
                            "5/7",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Tasks Completed",
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
                          const Text(
                            "400",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text(
                            "THB",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Container(
                            height: 15,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: AppColors.accent,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                "Owes You",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
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
                                  : 3, // dynamic
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
    );
  }
}
