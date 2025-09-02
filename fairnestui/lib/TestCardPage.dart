import 'package:fairnestui/components/MainButton.dart';
import 'package:fairnestui/pages/Chores/EditChorePage.dart';
import 'package:fairnestui/pages/Finance/EditFinancePage.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';

class UiTestEditPages extends StatelessWidget {
  const UiTestEditPages({super.key});

  Future<void> _openEditChore(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditChorePage(
          title: 'Weekly Kitchen Cleanup',
          taskType: 'Chore',
          dateTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
          assignees: const ['Ayu', 'Bima'],
          category: 'Cleaning',
          recurrence: 'Weekly',
          autoRotate: true,
        ),
      ),
    );

    if (context.mounted && result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chore result: ${result['action']}')),
      );
    }
  }

  Future<void> _openEditFinance(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditFinancePage(
          title: 'Groceries - Weekend',
          taskType: 'Finance',
          dateTime: DateTime.now().add(const Duration(days: 2, hours: 18)),
          participants: const ['Ayu', 'Bima', 'Chai'],
          category: 'Groceries',
          totalAmount: 120.50,
          splitType: 'Custom',
          customSplits: const {'Ayu': 40.00, 'Bima': 40.50, 'Chai': 40.00},
          paidBy: const ['Ayu'],
        ),
      ),
    );

    if (context.mounted && result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Finance result: ${result['action']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'UI Test: Edit Pages',
          style: TextStyle(fontFamily: 'Krub', fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.accent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          children: [
            MainButton(
              text: 'Open Edit Chore (Sample)',
              onPressed: () => _openEditChore(context),
              backgroundColor: AppColors.primary,
              textColor: Colors.black,
              width: double.infinity,
              height: 56,
            ),
            const SizedBox(height: 16),
            MainButton(
              text: 'Open Edit Finance (Sample)',
              onPressed: () => _openEditFinance(context),
              backgroundColor: AppColors.primary,
              textColor: Colors.black,
              width: double.infinity,
              height: 56,
            ),
          ],
        ),
      ),
    );
  }
}
