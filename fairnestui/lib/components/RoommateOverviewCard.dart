import 'package:fairnestui/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Roommateoverviewcard extends StatelessWidget {
  const Roommateoverviewcard({
    super.key,
    this.avatarImage, // AssetImage / NetworkImage / null
    this.avatarColor, // optional ring/bg color
    this.name, // optional name label
  });

  final ImageProvider? avatarImage;
  final Color? avatarColor;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 21,
            ),
            CircleAvatar(
              radius: 24,
              backgroundColor:
                  (avatarColor ?? AppColors.textOrange).withOpacity(0.6),
              backgroundImage: avatarImage,
              child: avatarImage == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            SizedBox(height: 5),
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
        SizedBox(
          width: 15,
        ),
        Container(
          height: 100,
          width: 260,
          child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF645A80), width: 2),
                borderRadius: BorderRadius.circular(8),
                color: Color(0XFFDED6CB),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        height: 80,
                        width: 70,
                        // color: Colors.amber,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xFF645A80), width: 2),
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.primary),
                          child: Text(
                            "5/7",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        height: 80,
                        width: 70,
                        // color: Colors.amber,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color(0xFF645A80), width: 2),
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.primary))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        height: 80,
                        width: 70,
                        // color: Colors.amber,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color(0xFF645A80), width: 2),
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.primary))),
                  ),
                ],
              )),
        ),
      ],
    );
  }
}
