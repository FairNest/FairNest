// lib/shell/app_shell.dart
import 'package:fairnestui/pages/Compatibility/CompatibilityPage.dart';
import 'package:fairnestui/pages/Home/RoomDashboardPage.dart';
import 'package:fairnestui/pages/Chores/AddChorePage.dart';
import 'package:fairnestui/pages/Finance/AddFinancePage.dart';
import 'package:flutter/material.dart';

// your custom bottom nav
import 'package:fairnestui/widgets/app_bottom_nav.dart';

// your real pages

// temporary placeholders (replace when you have real pages)
class _ListPage extends StatelessWidget {
  const _ListPage();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('List Page')));
}

class _CashPage extends StatelessWidget {
  const _CashPage();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Cash Page')));
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});
  final int initialIndex; // start tab (0 = Home)

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;

  // Order must match your AppBottomNav icons:
  // 0 Home, 1 List, 2 Add (center), 3 Cash, 4 User
  late final List<Widget> _tabs = const [
    RoomDashboardPage(), // 0
    _ListPage(), // 1
    SizedBox.shrink(), // 2 (center Add handled separately)
    _CashPage(), // 3
    CompatibilityPage(), // 4
  ];

  void _onTabSelected(int i) {
    if (i == 2) return; // center handled by _onCenterAction
    setState(() => _index = i);
  }

  void _onCenterAction() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: SizedBox(
          height: 260,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Create something…',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.cleaning_services_rounded),
                title: const Text('Add Chore'),
                onTap: () async {
                  Navigator.pop(context); // close the sheet
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddChorePage()),
                  );

                  if (result != null) {
                    // TODO: handle the created chore data (e.g., call API / state update)
                    // print(result);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long_rounded),
                title: const Text('Add Finance'),
                onTap: () async {
                  Navigator.pop(context); // close the sheet
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddFinancePage()),
                  );

                  if (result != null) {
                    // TODO: handle the created chore data (e.g., call API / state update)
                    // print(result);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep all tabs alive; only the active one is visible.
      body: IndexedStack(
        index: _index == 2 ? 0 : _index, // ignore center slot visually
        children: _tabs,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTabSelected: _onTabSelected,
        onCenterAction: _onCenterAction,
      ),
    );
  }
}
