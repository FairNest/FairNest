import 'package:fairnestui/pages/FindRoommate/RequestJoinRoomPage.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/widgets/app_header.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/components/RoomComponentsCard.dart';

// Services
import 'package:fairnestui/services/api_client.dart';
import 'package:fairnestui/services/user_service.dart';

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

  static const _inactiveBg = Color(0xFFE7DFD6);
  static const _inactiveText = Color(0xFF8C8885);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 150,
        height: 42,
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
 * Filter button
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
            color: const Color(0xFF645A80),
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
 * Tab: My room
 * ---------------------------------------------------------*/
class _MyRoomTab extends StatefulWidget {
  const _MyRoomTab();

  @override
  State<_MyRoomTab> createState() => _MyRoomTabState();
}

class _MyRoomTabState extends State<_MyRoomTab> {
  late Future<Map<String, dynamic>?> _myRoomFuture;

  @override
  void initState() {
    super.initState();
    _myRoomFuture = _fetchMyRoom();
  }

  Future<Map<String, dynamic>?> _fetchMyRoom() async {
    final userId = await UserService.getUserIdFromToken();
    if (userId == null) throw Exception("User not authenticated");

    final resp = await ApiClient.get("/GetMyRoomByUserId/$userId");
    final data = resp.data;

    if (data == null) return null;

    Map<String, dynamic> map;
    if (data is Map<String, dynamic>) {
      map = data;
    } else if (data is List && data.isNotEmpty) {
      map = data.first;
    } else {
      return null;
    }

    return {
      "id": map["room_id"], // 🔑 include id for navigation
      "name": map["room_name"],
      "desc": map["room_description"],
      "current": map["room_current_capacity"],
      "max": map["room_max_capacity"],
      "compat": (map["compatibility_percent"] is num)
          ? (map["compatibility_percent"] as num).round()
          : null,
      "picture": map["room_picture"],
    };
  }

  Future<void> _refresh() async {
    final newFuture = _fetchMyRoom();
    setState(() {
      _myRoomFuture = newFuture;
    });
    await newFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _myRoomFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final room = snap.data;
        final hasError = snap.hasError;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              if (hasError)
                Text("❌ Failed to load your room: ${snap.error}",
                    style: const TextStyle(color: Colors.red)),
              if (!hasError && room == null)
                const Text("You don't have a room yet."),
              if (room != null)
                RoomComponentsCard(
                  title: room["name"] ?? "-",
                  description: room["desc"] ?? "-",
                  memberCount: room["current"] ?? 0,
                  memberMax: room["max"] ?? 0,
                  compatibilityPct: room["compat"] ?? 0,
                  imageUrl: room["picture"],
                  width: double.infinity,
                  height: 210,
                  onTap: () {
                    final id = (room["id"] as num?)?.toInt();
                    if (id == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Room ID not available')),
                      );
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Requestjoinroompage(roomId: id),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 600),
            ],
          ),
        );
      },
    );
  }
}

/* -----------------------------------------------------------
 * Tab: Public rooms
 * ---------------------------------------------------------*/
class _PublicRoomsTab extends StatefulWidget {
  const _PublicRoomsTab();

  @override
  State<_PublicRoomsTab> createState() => _PublicRoomsTabState();
}

class _PublicRoomsTabState extends State<_PublicRoomsTab> {
  late Future<List<Map<String, dynamic>>> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _roomsFuture = _fetchRooms();
  }

  Future<List<Map<String, dynamic>>> _fetchRooms() async {
    final userId = await UserService.getUserIdFromToken();
    if (userId == null) throw Exception("User not authenticated");

    final resp = await ApiClient.get(
        "/FetchAllPublicRoomSuitUserLifestyleByUserId/$userId");
    final List data = resp.data ?? [];

    return data.map<Map<String, dynamic>>((room) {
      return {
        "id": room["room_id"], // 🔑 include id for navigation
        "name": room["room_name"],
        "desc": room["room_description"],
        "current": room["room_current_capacity"],
        "max": room["room_max_capacity"],
        "compat": (room["compatibility_percent"] is num)
            ? (room["compatibility_percent"] as num).round()
            : 0,
        "picture": room["room_picture"],
      };
    }).toList();
  }

  Future<void> _refresh() async {
    final newFuture = _fetchRooms();
    setState(() {
      _roomsFuture = newFuture;
    });
    await newFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _roomsFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final rooms = snap.data ?? [];
        final hasError = snap.hasError;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: rooms.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    if (hasError)
                      Text("❌ Failed to load rooms: ${snap.error}",
                          style: const TextStyle(color: Colors.red))
                    else
                      const Text("No public rooms available."),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: rooms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final room = rooms[i];
                    return RoomComponentsCard(
                      title: room["name"] ?? "-",
                      description: room["desc"] ?? "-",
                      memberCount: room["current"] ?? 0,
                      memberMax: room["max"] ?? 0,
                      compatibilityPct: room["compat"] ?? 0,
                      imageUrl: room["picture"],
                      width: double.infinity,
                      height: 210,
                      onTap: () {
                        final id = (room["id"] as num?)?.toInt();
                        if (id == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Room ID not available')),
                          );
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => Requestjoinroompage(roomId: id),
                          ),
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}
