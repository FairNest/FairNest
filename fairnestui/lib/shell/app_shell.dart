// lib/shell/app_shell.dart
import 'package:flutter/material.dart';

// ---- Your pages ----
import 'package:fairnestui/pages/Home/RoomDashboardPage.dart';
import 'package:fairnestui/pages/Chores/ChoresPage.dart';
import 'package:fairnestui/pages/Finance/FinancePage.dart';
import 'package:fairnestui/pages/Compatibility/CompatibilityPage.dart';
import 'package:fairnestui/pages/Chores/AddChorePage.dart';
import 'package:fairnestui/pages/Finance/AddFinancePage.dart';

// ---- Your widgets ----
import 'package:fairnestui/widgets/app_bottom_nav.dart';
import 'package:fairnestui/widgets/room_header_appbar.dart';

// ---- Header centralization helpers ----
import 'package:fairnestui/shell/header_controller.dart';
import 'package:fairnestui/shell/header_scope.dart';

// ---- Profile service & model (paths aligned to your service snippet) ----
import 'package:fairnestui/services/user_profile_service.dart';
import 'package:fairnestui/model/user_profile_model.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});
  final int initialIndex; // start tab (0 = Home)

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;

  /// Single source of truth for the header (score, progress, icons, avatar).
  final HeaderController _header = HeaderController();

  // Order must match your AppBottomNav icons:
  // 0 Home, 1 List, 2 Add (center), 3 Cash, 4 User
  late final List<Widget> _tabs = const [
    RoomDashboardPage(), // 0
    Chorespage(), // 1
    SizedBox.shrink(), // 2 (center Add handled separately)
    Financepage(), // 3
    CompatibilityPage(), // 4
  ];

  @override
  void initState() {
    super.initState();

    // Neutral header fast (will be replaced by cached/fresh).
    _header.set(const HeaderConfig(
      scoreText: '0 Points',
      progress: 0.0,
      showNotifications: true,
      showSettings: true,
      // avatarImage: null (fallback handled in builder)
    ));

    // Cache-first, then refresh to keep it correct.
    _loadProfileCacheThenRefresh();
  }

  @override
  void dispose() {
    _header.dispose();
    super.dispose();
  }

  /// Public helper if pages want to trigger a refresh after actions.
  Future<void> reloadProfile() => _loadProfileCacheThenRefresh();

  Future<void> _loadProfileCacheThenRefresh() async {
    // 1) Cached (fast)
    final cached = await UserProfileService.instance.getCurrentUserProfile();
    if (mounted && cached != null) {
      await _applyProfileToHeader(cached);
    }

    // 2) Fresh (force refresh)
    try {
      final fresh =
          await UserProfileService.instance.refreshCurrentUserProfile();
      if (mounted && fresh != null) {
        await _applyProfileToHeader(fresh);
      }
    } catch (_) {
      // Keep cached UI if network fails.
    }
  }

  Future<void> _applyProfileToHeader(UserProfile p) async {
    final int score = p.roommateScore;
    final double progress = (score / 100).clamp(0.0, 1.0);

    final ImageProvider avatar = (p.userPicture.isNotEmpty)
        ? ResizeImage(NetworkImage(p.userPicture), width: 192, height: 192)
        : const AssetImage('assets/images/poke.png');

    // Warm the image cache so the first paint is snappy.
    try {
      await precacheImage(avatar, context);
    } catch (_) {}

    _header.set(HeaderConfig(
      scoreText: '$score Points',
      progress: progress,
      showNotifications: true,
      showSettings: true,
      avatarImage: avatar,
    ));
  }

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
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddChorePage()),
                  );
                  if (result != null) {
                    // Optionally refresh if score changes:
                    // await reloadProfile();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long_rounded),
                title: const Text('Add Finance'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddFinancePage()),
                  );
                  if (result != null) {
                    // Optionally refresh if score changes:
                    // await reloadProfile();
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
    return HeaderScope(
      controller: _header, // expose header to descendants if needed
      child: Scaffold(
        // Centralized AppBar that rebuilds immediately on header changes.
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(88),
          child: _HeaderAppBarBuilder(),
        ),

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
      ),
    );
  }
}

/// Extracted to keep build() clean. Rebuilds whenever HeaderController notifies.
class _HeaderAppBarBuilder extends StatelessWidget {
  const _HeaderAppBarBuilder();

  @override
  Widget build(BuildContext context) {
    final header = HeaderScope.of(context);

    return AnimatedBuilder(
      animation: header,
      builder: (context, _) {
        final c = header.config;
        return RoomHeaderAppBar(
          avatarImage:
              c.avatarImage ?? const AssetImage('assets/images/poke.png'),
          scoreText: c.scoreText,
          progress: c.progress,
          onTapNotifications:
              c.showNotifications ? (c.onTapNotifications ?? () {}) : null,
          onTapSettings: c.showSettings ? (c.onTapSettings ?? () {}) : null,
        );
      },
    );
  }
}
