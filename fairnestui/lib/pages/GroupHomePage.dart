import 'package:fairnestui/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/components/RoomComponentsCard.dart';

class GroupHomePage extends StatefulWidget {
  const GroupHomePage({super.key, this.onFilterTap});

  final VoidCallback? onFilterTap;

  @override
  State<GroupHomePage> createState() => _GroupHomePageState();
}

class _GroupHomePageState extends State<GroupHomePage> {
  int _tabIndex = 0; // 0 = My room, 1 = Public Rooms

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          AppHeader(
            title: 'Find Roommate',
            onNotificationTap: () {
              // TODO: Handle notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications tapped')),
              );
            },
          ),

          // Switcher row + Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _SwitcherPill(
                  text: 'My room',
                  isActive: _tabIndex == 0,
                  onTap: () => setState(() => _tabIndex = 0),
                ),
                const SizedBox(width: 10),
                _SwitcherPill(
                  text: 'Public Rooms',
                  isActive: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1),
                ),
                const Spacer(),
                _FilterButton(onTap: widget.onFilterTap),
              ],
            ),
          ),

          // Content
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: const [
                _MyRoomTab(),
                _PublicRoomsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* -----------------------------------------------------------
 * Switcher pill (active/inactive)
 * ---------------------------------------------------------*/
class _SwitcherPill extends StatelessWidget {
  const _SwitcherPill({
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  final String text;
  final bool isActive;
  final VoidCallback onTap;

  static const _inactiveBg = Color(0xFFE7DFD6); // beige
  static const _inactiveText = Color(0xFF8C8885); // grey-brown

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 150, // adjust as needed
        height: 42, // adjust as needed
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : _inactiveBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Krub',
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: isActive ? const Color(0xFFC34C04) : _inactiveText,
          ),
        ),
      ),
    );
  }
}

/* -----------------------------------------------------------
 * Filter button (tiny icon + label)
 * ---------------------------------------------------------*/
class _FilterButton extends StatelessWidget {
  const _FilterButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Filter tapped')),
            );
          },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/Funnel.png',
            width: 18,
            height: 18,
            color: const Color(0xFF645A80), // lavender
            colorBlendMode: BlendMode.srcIn,
          ),
          const SizedBox(width: 6),
          const Text(
            'Filter',
            style: TextStyle(
              fontFamily: 'Krub',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Color(0xFF645A80),
            ),
          ),
        ],
      ),
    );
  }
}

/* -----------------------------------------------------------
 * Tab: My room (example shows a single, larger card)
 * ---------------------------------------------------------*/
class _MyRoomTab extends StatelessWidget {
  const _MyRoomTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        RoomComponentsCard(
          title: 'Wonderful Trio Casa',
          description:
              "We're early risers, prefer a quiet space, and rotate chores weekly.",
          memberCount: 2,
          memberMax: 3,
          compatibilityPct: 87,
          width: double.infinity,
          height: 210,
          onTap: () {
            // TODO: navigate to detail
          },
        ),
        // Add more widgets below if needed (spacer to mimic left mock’s empty space)
        const SizedBox(height: 600),
      ],
    );
  }
}

/* -----------------------------------------------------------
 * Tab: Public rooms (example list of two)
 * ---------------------------------------------------------*/
class _PublicRoomsTab extends StatelessWidget {
  const _PublicRoomsTab();

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Hobbit Hub',
        "We're early risers, prefer a quiet space, and rotate chores weekly.",
        1,
        3,
        90
      ),
      (
        'Drummer Den',
        "We're early risers, prefer a quiet space, and rotate chores weekly.",
        2,
        4,
        82
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        final it = items[i];
        return RoomComponentsCard(
          title: it.$1,
          description: it.$2,
          memberCount: it.$3,
          memberMax: it.$4,
          compatibilityPct: it.$5,
          width: double.infinity,
          height: 210,
          onTap: () {
            // TODO: navigate to detail
          },
        );
      },
    );
  }
}
