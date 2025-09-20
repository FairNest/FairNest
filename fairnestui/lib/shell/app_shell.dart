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
import 'package:fairnestui/widgets/loading_3d_widget.dart';

// ---- Header centralization helpers ----
import 'package:fairnestui/shell/header_controller.dart';
import 'package:fairnestui/shell/header_scope.dart';

// ---- Profile service & model ----
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
  bool _isLoading = true;

  /// Single source of truth for the header (score, progress, icons, avatar).
  final HeaderController _header = HeaderController();

  // Order must match your AppBottomNav icons:
  // 0 Home, 1 List, 2 Add (center), 3 Cash, 4 User
  late final List<Widget> _tabs = [
    const RoomDashboardPage(), // 0
    const Chorespage(), // 1
    const SizedBox.shrink(), // 2 (center Add handled separately)
    const Financepage(), // 3
    const CompatibilityPage(), // 4
  ];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _header.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Show loading for minimum time to display the animation
    final loadingFuture = Future.delayed(const Duration(milliseconds: 1500));

    // Set initial neutral header
    _header.set(const HeaderConfig(
      scoreText: '0 Points',
      progress: 0.0,
      showNotifications: true,
      showSettings: true,
    ));

    // Load profile data
    final profileFuture = _loadProfileCacheThenRefresh();

    // Wait for both loading animation and profile data
    await Future.wait([loadingFuture, profileFuture]);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
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
                    await reloadProfile();
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
                    await reloadProfile();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Only the active tab is allowed to tick animations.
  List<Widget> _stackedTabs() {
    final effectiveIndex = _index == 2 ? 0 : _index; // ignore center slot
    return List<Widget>.generate(_tabs.length, (i) {
      final active = i == effectiveIndex;
      return TickerMode(
        enabled: active,
        child: KeyedSubtree(
          key: PageStorageKey('tab_$i'),
          child: _tabs[i],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _isLoading
          ? Scaffold(
              key: const ValueKey('loading'),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: const RepaintBoundary(
                  child: Loading3DWidget(
                message: 'Loading your space...',
                primaryColor: Color(0xFFC7BDE2),
                secondaryColor: Color(0xFF645A80),
                size: 110,
                showOrbit: false, // ← hide bubbles for a crisp house
                showSparkles: true,
                showLogo: false,
              )),
            )
          : HeaderScope(
              key: const ValueKey('main'),
              controller: _header,
              child: Scaffold(
                // Centralized AppBar that rebuilds immediately on header changes.
                appBar: const PreferredSize(
                  preferredSize: Size.fromHeight(88),
                  child: RepaintBoundary(
                    child: _HeaderAppBarBuilder(),
                  ),
                ),

                // Keep all tabs alive; only the active one ticks & is visible.
                body: IndexedStack(
                  index: _index == 2 ? 0 : _index,
                  children: _stackedTabs(),
                ),

                bottomNavigationBar: RepaintBoundary(
                  child: AppBottomNav(
                    currentIndex: _index,
                    onTabSelected: _onTabSelected,
                    onCenterAction: _onCenterAction,
                  ),
                ),
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
