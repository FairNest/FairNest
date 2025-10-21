import 'package:dio/dio.dart';
import 'package:fairnestui/Notification/NotificationPage.dart';
import 'package:fairnestui/model/pending_room_model.dart';
import 'package:fairnestui/pages/FindRoommate/RequestJoinRoomPage.dart';
import 'package:fairnestui/pages/FindRoommate/StartRoommatePage.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/widgets/app_header.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/components/RoomComponentsCard.dart';

// Services
import 'package:fairnestui/services/api_client.dart';
import 'package:fairnestui/services/user_service.dart';

class RoomFilters {
  final int? maxCapacity;
  final double? minRent;
  final double? maxRent;
  final double? maxElectricity;
  final double? maxWater;
  final String? quietHoursStart;
  final double? minCompatibility;

  RoomFilters({
    this.maxCapacity,
    this.minRent,
    this.maxRent,
    this.maxElectricity,
    this.maxWater,
    this.quietHoursStart,
    this.minCompatibility,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (maxCapacity != null) map['maxCapacity'] = maxCapacity;
    if (minRent != null) map['minRent'] = minRent;
    if (maxRent != null) map['maxRent'] = maxRent;
    if (maxElectricity != null) map['maxElectricity'] = maxElectricity;
    if (maxWater != null) map['maxWater'] = maxWater;
    if (quietHoursStart != null) map['quietHoursStart'] = quietHoursStart;
    if (minCompatibility != null) map['minCompatibility'] = minCompatibility;

    return map;
  }

  bool get hasFilters => toMap().isNotEmpty;

  RoomFilters copyWith({
    int? maxCapacity,
    double? minRent,
    double? maxRent,
    double? maxElectricity,
    double? maxWater,
    String? quietHoursStart,
    double? minCompatibility,
    bool clearMaxCapacity = false,
    bool clearMinRent = false,
    bool clearMaxRent = false,
    bool clearMaxElectricity = false,
    bool clearMaxWater = false,
    bool clearQuietHoursStart = false,
    bool clearMinCompatibility = false,
  }) {
    return RoomFilters(
      maxCapacity: clearMaxCapacity ? null : (maxCapacity ?? this.maxCapacity),
      minRent: clearMinRent ? null : (minRent ?? this.minRent),
      maxRent: clearMaxRent ? null : (maxRent ?? this.maxRent),
      maxElectricity:
          clearMaxElectricity ? null : (maxElectricity ?? this.maxElectricity),
      maxWater: clearMaxWater ? null : (maxWater ?? this.maxWater),
      quietHoursStart: clearQuietHoursStart
          ? null
          : (quietHoursStart ?? this.quietHoursStart),
      minCompatibility: clearMinCompatibility
          ? null
          : (minCompatibility ?? this.minCompatibility),
    );
  }
}

class GroupHomePage extends StatefulWidget {
  const GroupHomePage({super.key, this.onFilterTap});

  final VoidCallback? onFilterTap;

  @override
  State<GroupHomePage> createState() => _GroupHomePageState();
}

class _GroupHomePageState extends State<GroupHomePage> {
  int _tabIndex = 0; // 0 = My room, 1 = Public Rooms
  final GlobalKey<_PublicRoomsTabState> _publicRoomsKey =
      GlobalKey<_PublicRoomsTabState>();

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        onApplyFilters: (filters) {
          _publicRoomsKey.currentState?.applyFilters(filters);
        },
        onClearFilters: () {
          _publicRoomsKey.currentState?.clearFilters();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          AppHeader(
            title: 'Find Roommate',
            rightType: AppHeaderRightType.notification,
            onNotificationTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const Notificationpage(),
                ),
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
                _FilterButton(
                  onTap: _tabIndex == 1 ? _showFilterDialog : null,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: [
                const _MyRoomTab(),
                _PublicRoomsTab(key: _publicRoomsKey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* -----------------------------------------------------------
 * Filter Dialog
 * ---------------------------------------------------------*/
class _FilterDialog extends StatefulWidget {
  final Function(RoomFilters) onApplyFilters;
  final VoidCallback onClearFilters;

  const _FilterDialog({
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  final TextEditingController _maxCapacityController = TextEditingController();
  final TextEditingController _minRentController = TextEditingController();
  final TextEditingController _maxRentController = TextEditingController();
  final TextEditingController _maxElectricityController =
      TextEditingController();
  final TextEditingController _maxWaterController = TextEditingController();
  final TextEditingController _minCompatibilityController =
      TextEditingController();
  String? _selectedQuietHours;

  final List<String> _quietHoursOptions = [
    '20:00',
    '21:00',
    '22:00',
    '23:00',
    '00:00'
  ];

  @override
  void dispose() {
    _maxCapacityController.dispose();
    _minRentController.dispose();
    _maxRentController.dispose();
    _maxElectricityController.dispose();
    _maxWaterController.dispose();
    _minCompatibilityController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filters = RoomFilters(
      maxCapacity: _maxCapacityController.text.isNotEmpty
          ? int.tryParse(_maxCapacityController.text)
          : null,
      minRent: _minRentController.text.isNotEmpty
          ? double.tryParse(_minRentController.text)
          : null,
      maxRent: _maxRentController.text.isNotEmpty
          ? double.tryParse(_maxRentController.text)
          : null,
      maxElectricity: _maxElectricityController.text.isNotEmpty
          ? double.tryParse(_maxElectricityController.text)
          : null,
      maxWater: _maxWaterController.text.isNotEmpty
          ? double.tryParse(_maxWaterController.text)
          : null,
      quietHoursStart: _selectedQuietHours,
      minCompatibility: _minCompatibilityController.text.isNotEmpty
          ? double.tryParse(_minCompatibilityController.text)
          : null,
    );

    widget.onApplyFilters(filters);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _maxCapacityController.clear();
      _minRentController.clear();
      _maxRentController.clear();
      _maxElectricityController.clear();
      _maxWaterController.clear();
      _minCompatibilityController.clear();
      _selectedQuietHours = null;
    });

    widget.onClearFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Filter Rooms',
        style: TextStyle(
          fontFamily: 'Krub',
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: AppColors.darkPurple,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Max Capacity
            _FilterField(
              label: 'Max Capacity',
              controller: _maxCapacityController,
              keyboardType: TextInputType.number,
              suffix: 'people',
            ),

            const SizedBox(height: 16),

            // Rent Range
            const Text(
              'Rent Range',
              style: TextStyle(
                fontFamily: 'Krub',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.darkPurple,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _FilterField(
                    label: 'Min',
                    controller: _minRentController,
                    keyboardType: TextInputType.number,
                    suffix: '฿',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FilterField(
                    label: 'Max',
                    controller: _maxRentController,
                    keyboardType: TextInputType.number,
                    suffix: '฿',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Electricity Cost
            _FilterField(
              label: 'Max Electricity Cost',
              controller: _maxElectricityController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              suffix: '฿/unit',
            ),

            const SizedBox(height: 16),

            // Water Cost
            _FilterField(
              label: 'Max Water Cost',
              controller: _maxWaterController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              suffix: '฿/unit',
            ),

            const SizedBox(height: 16),

            // Quiet Hours
            const Text(
              'Quiet Hours Start',
              style: TextStyle(
                fontFamily: 'Krub',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.darkPurple,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF8C8885)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedQuietHours,
                  hint: const Text('Select time'),
                  items: _quietHoursOptions.map((String time) {
                    return DropdownMenuItem<String>(
                      value: time,
                      child: Text(time),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedQuietHours = newValue;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Min Compatibility
            _FilterField(
              label: 'Min Compatibility',
              controller: _minCompatibilityController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              suffix: '%',
            ),
          ],
        ),
      ),
      actions: [
        // Clear Button
        TextButton(
          onPressed: _clearFilters,
          child: const Text(
            'Clear All',
            style: TextStyle(
              fontFamily: 'Krub',
              fontWeight: FontWeight.w600,
              color: Color(0xFF8C8885),
            ),
          ),
        ),

        // Apply Button
        ElevatedButton(
          onPressed: _applyFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Apply Filters',
            style: TextStyle(
              fontFamily: 'Krub',
              fontWeight: FontWeight.w700,
              color: Color(0xFFC34C04),
            ),
          ),
        ),
      ],
    );
  }
}

/* -----------------------------------------------------------
 * Filter Field Widget
 * ---------------------------------------------------------*/
class _FilterField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? suffix;

  const _FilterField({
    required this.label,
    required this.controller,
    required this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Krub',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.darkPurple,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: 'Enter ${label.toLowerCase()}',
            hintStyle: const TextStyle(
              color: Color(0xFF8C8885),
              fontSize: 12,
            ),
            suffixText: suffix,
            suffixStyle: const TextStyle(
              color: Color(0xFF8C8885),
              fontSize: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF8C8885)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF8C8885)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          style: const TextStyle(
            fontFamily: 'Krub',
            fontSize: 14,
          ),
        ),
      ],
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
              const SnackBar(
                  content: Text('Filter only works on Public Rooms tab')),
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
 * Tab: My room - Fetch pending room
 * ---------------------------------------------------------*/
class _MyRoomTab extends StatefulWidget {
  const _MyRoomTab();

  @override
  State<_MyRoomTab> createState() => _MyRoomTabState();
}

class _MyRoomTabState extends State<_MyRoomTab> {
  late Future<PendingRoomModel?> _pendingRoomFuture;

  @override
  void initState() {
    super.initState();
    _pendingRoomFuture = _fetchPendingRoom();
  }

  Future<PendingRoomModel?> _fetchPendingRoom() async {
    try {
      final userId = await UserService.getUserIdFromToken();
      if (userId == null) throw Exception("User not authenticated");

      final response = await ApiClient.get("/GetMyPendingRoomByUserId/$userId");

      if (response.statusCode == 200 && response.data != null) {
        return PendingRoomModel.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (e is DioException) {
        // Handle 500 error with "record not found" message
        if (e.response?.statusCode == 500) {
          final errorMessage = e.response?.data?.toString() ?? '';
          if (errorMessage.toLowerCase().contains('record not found')) {
            // No pending room found - this is not an error, just no data
            return null;
          }
        }
        // Handle 404 as no pending room
        if (e.response?.statusCode == 404) {
          return null;
        }
      }
      // For other errors, rethrow
      rethrow;
    }
  }

  Future<void> _refresh() async {
    final newFuture = _fetchPendingRoom();
    setState(() {
      _pendingRoomFuture = newFuture;
    });
    await newFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PendingRoomModel?>(
      future: _pendingRoomFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading pending room',
                          style: TextStyle(
                            fontFamily: 'Krub',
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pull down to retry',
                          style: TextStyle(
                            fontFamily: 'Krub',
                            fontSize: 14,
                            color: Colors.grey.shade500,
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

        final pendingRoom = snapshot.data;

        if (pendingRoom == null) {
          // No pending room - show empty state with helpful message
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'You haven\'t requested to join a room',
                          style: TextStyle(
                            fontFamily: 'Krub',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Browse public rooms to find your perfect match!',
                          style: TextStyle(
                            fontFamily: 'Krub',
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Show the pending room card
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              RoomComponentsCard(
                title: pendingRoom.roomName,
                description: pendingRoom.roomDescription,
                memberCount: pendingRoom.roomCurrentCapacity,
                memberMax: pendingRoom.roomMaxCapacity,
                compatibilityPct: pendingRoom.roomCompatibilityScore,
                imageUrl: pendingRoom.roomPicture,
                width: double.infinity,
                height: 210,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StartRoommatePage(
                        roomId: pendingRoom.roomId,
                        roomJoinRequestId: pendingRoom.roomJoinRequestId,
                      ),
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
  const _PublicRoomsTab({super.key});

  @override
  State<_PublicRoomsTab> createState() => _PublicRoomsTabState();
}

class _PublicRoomsTabState extends State<_PublicRoomsTab> {
  late Future<List<Map<String, dynamic>>> _roomsFuture;
  bool _isFilterActive = false;
  RoomFilters _currentFilters = RoomFilters();

  @override
  void initState() {
    super.initState();
    _roomsFuture = _fetchAllRooms(); // Default to unfiltered
  }

  // Original method - fetch all rooms without filters
  Future<List<Map<String, dynamic>>> _fetchAllRooms() async {
    final userId = await UserService.getUserIdFromToken();
    if (userId == null) throw Exception("User not authenticated");

    final resp = await ApiClient.get(
        "/FetchAllPublicRoomSuitUserLifestyleByUserId/$userId");
    final List data = resp.data ?? [];

    return _mapRooms(data);
  }

  // New method - fetch filtered rooms
  Future<List<Map<String, dynamic>>> _fetchFilteredRooms(
      Map<String, dynamic> filters) async {
    final userId = await UserService.getUserIdFromToken();
    if (userId == null) throw Exception("User not authenticated");

    // Build query parameters
    final queryParams = <String, dynamic>{};
    filters.forEach((key, value) {
      if (value != null && value != '') {
        queryParams[key] = value.toString();
      }
    });

    final resp = await ApiClient.get(
      "/FilterPublicRoomSuitUserLifestyleByUserId/$userId",
      queryParameters: queryParams,
    );

    final List data = resp.data ?? [];
    return _mapRooms(data);
  }

  // Helper method to map room data
  List<Map<String, dynamic>> _mapRooms(List data) {
    return data.map<Map<String, dynamic>>((room) {
      return {
        "id": room["room_id"],
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

  // Method to apply filters
  void applyFilters(RoomFilters filters) {
    setState(() {
      _currentFilters = filters;
      _isFilterActive = filters.hasFilters;
      _roomsFuture = _isFilterActive
          ? _fetchFilteredRooms(filters.toMap())
          : _fetchAllRooms();
    });

    // Show feedback message
    final filterCount = filters.toMap().length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFilterActive
            ? 'Applied $filterCount filter${filterCount > 1 ? 's' : ''}'
            : 'Showing all rooms'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  // Method to clear filters
  void clearFilters() {
    setState(() {
      _isFilterActive = false;
      _currentFilters = RoomFilters();
      _roomsFuture = _fetchAllRooms();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters cleared'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  Future<void> _refresh() async {
    final newFuture = _isFilterActive
        ? _fetchFilteredRooms(_currentFilters.toMap())
        : _fetchAllRooms();
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

        return Column(
          children: [
            // Filter status indicator
            if (_isFilterActive)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.accent.withValues(alpha: .5)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_alt,
                      size: 16,
                      color: Color(0xFFC34C04),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filters applied (${_currentFilters.toMap().length})',
                      style: const TextStyle(
                        fontFamily: 'Krub',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC34C04),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: clearFilters,
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          fontFamily: 'Krub',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC34C04),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Room list
            Expanded(
              child: RefreshIndicator(
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
                            Text(_isFilterActive
                                ? "No rooms match your filters. Try adjusting your criteria."
                                : "No public rooms available."),
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
                                  builder: (_) =>
                                      Requestjoinroompage(roomId: id),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
