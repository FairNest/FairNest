import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';

class TransactionCard extends StatelessWidget {
  final String category; // e.g. "Food"
  final String date; // e.g. "29 March 2025"
  final String amount; // e.g. "THB 20"
  final String paidTo; // e.g. "Paid to Max"
  final int points; // e.g. 10

  const TransactionCard({
    super.key,
    required this.category,
    required this.date,
    required this.amount,
    required this.paidTo,
    required this.points,
  });

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case "food":
        return Icons.fastfood_rounded;
      case "transport":
        return Icons.directions_bus_rounded;
      case "entertainment":
        return Icons.movie_rounded;
      case "shopping":
        return Icons.shopping_bag_rounded;
      case "utilities":
        return Icons.lightbulb_outline_rounded;
      default:
        return Icons.receipt_long_rounded; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textPurple, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Icon + details
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.textPurple,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  _getIconForCategory(category),
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPurple,
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPurple.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right: Amount + paidTo
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPurple,
                ),
              ),
              Text(
                paidTo,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textPurple.withOpacity(0.7),
                ),
              ),
            ],
          ),

          // Points badge
          Container(
            margin: const EdgeInsets.only(left: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '+$points',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
