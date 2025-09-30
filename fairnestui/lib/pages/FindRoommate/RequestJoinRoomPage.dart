// lib/roommate/find_roommate_detail_page.dart
import 'package:flutter/material.dart';
import 'package:fairnestui/util/HouseRules.dart';
import 'package:fairnestui/widgets/LifestyleOverview.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/widgets/app_header.dart';
import 'package:fairnestui/components/MainButton.dart';
import 'package:fairnestui/components/RoomComponentsCard.dart';

// services
import 'package:fairnestui/services/api_client.dart';

class Requestjoinroompage extends StatefulWidget {
  const Requestjoinroompage({
    super.key,
    required this.roomId,
    this.onRequestJoin,
    this.showBack = true,
  });

  final int roomId; // 🔑 passed from the card
  final VoidCallback? onRequestJoin;
  final bool showBack;

  @override
  State<Requestjoinroompage> createState() => _RequestjoinroompageState();
}

class _RequestjoinroompageState extends State<Requestjoinroompage> {
  late Future<Map<String, dynamic>> _detailsFuture;

  static const _lavender = Color(0xFF645A80);

  @override
  void initState() {
    super.initState();
    _detailsFuture = _fetchRoomDetails(widget.roomId);
  }

  Future<Map<String, dynamic>> _fetchRoomDetails(int roomId) async {
    final resp = await ApiClient.get("/GetRoomDetailsByRoomId/$roomId");
    final data = resp.data as Map<String, dynamic>;

    // Normalize fields for easier rendering
    return {
      "id": data["room_id"],
      "name": data["room_name"],
      "desc": data["room_description"],
      "current": data["room_current_capacity"],
      "max": data["room_max_capacity"],
      "compat": (data["room_compatibility_score"] is num)
          ? (data["room_compatibility_score"] as num).round()
          : 0,
      "picture": data["room_picture"],

      // Overview
      "living_space_name": data["living_space_name"],
      "rent_cost": data["rent_cost"], // per month
      "electricity": data["electricity_cost_per_unit"],
      "water": data["water_cost_per_unit"],
      "other_utils": data["other_utility_details"],
      "shared_space": data["shared_space"],
      "split_costs": data["split_costs"] == true,
      "quiet_hours_start": data["quiet_hours_start"],
      "guest_stay_over": data["guest_stay_over"],
      "handle_cleaning": data["handle_cleaning"],

      // Lifestyle averages (0–1)
      "avg_tidiness": (data["avg_tidiness"] as num?)?.toDouble() ?? 0.0,
      "avg_noise_activity":
          (data["avg_noise_activity"] as num?)?.toDouble() ?? 0.0,
      "avg_schedule": (data["avg_schedule"] as num?)?.toDouble() ?? 0.0,
      "avg_guest_frequency":
          (data["avg_guest_frequency"] as num?)?.toDouble() ?? 0.0,
      "avg_task_structure":
          (data["avg_task_structure"] as num?)?.toDouble() ?? 0.0,
      "avg_money_attitude":
          (data["avg_money_attitude"] as num?)?.toDouble() ?? 0.0,

      // Members
      "members": (data["members"] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((m) => {
                "name": (m["firstname"]?.toString()?.isNotEmpty ?? false)
                    ? "${m["firstname"] ?? ""} ${m["lastname"] ?? ""}".trim()
                    : (m["username"]?.toString() ?? "Member"),
                "pic": m["user_picture"]?.toString(),
              })
          .toList(),
    };
  }

  Future<void> _refresh() async {
    final newF = _fetchRoomDetails(widget.roomId);
    setState(() {
      _detailsFuture = newF;
    });
    await newF;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9E0EC),
      body: Column(
        children: [
          // Header (bell hidden by passing null)
          const Stack(
            children: [
              AppHeader(
                title: 'Find Roommate',
                onNotificationTap: null,
                rightType: AppHeaderRightType.profile,
              ),
            ],
          ),

          // Content
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _detailsFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final hasError = snap.hasError;
                final data = snap.data;

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (hasError)
                          Text(
                            "❌ Failed to load room details: ${snap.error}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        if (data != null) ...[
                          // Room card (uses backend data)
                          RoomComponentsCard(
                            title: data["name"] ?? "-",
                            description: data["desc"] ?? "-",
                            memberCount: data["current"] ?? 0,
                            memberMax: data["max"] ?? 0,
                            compatibilityPct: data["compat"] ?? 0,
                            imageUrl: data["picture"],
                            width: double.infinity,
                            height: 210,
                            onTap: () {},
                          ),

                          const SizedBox(height: 12),

                          // Room Overview
                          const _SectionTitle('Room Overview'),
                          const SizedBox(height: 8),
                          _OverviewCard(
                            apartmentName:
                                (data["living_space_name"]?.toString() ?? "—"),
                            leftRightRows: [
                              (
                                "Rent • ${_fmtMoney(data["rent_cost"])} Baht/Month",
                                data["other_utils"]?.toString() ?? "—"
                              ),
                              (
                                "Electricity ${_fmtMoney(data["electricity"])} Baht/Unit",
                                "Water ${_fmtMoney(data["water"])} Baht/Unit"
                              ),
                              (
                                "Shared spaces: ${data["shared_space"] ?? "—"}",
                                "Split costs: ${data["split_costs"] == true ? "Yes" : "No"}"
                              ),
                              (
                                "Quiet hours start: ${data["quiet_hours_start"] ?? "—"}",
                                "Guests: ${data["guest_stay_over"] ?? "—"}"
                              ),
                              (
                                "Cleaning: ${data["handle_cleaning"] ?? "—"}",
                                ""
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Lifestyle Overview
                          const _SectionTitle('Lifestyle Overview'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECE9E6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _lavender, width: 1),
                            ),
                            child: LifestyleOverview(
                              barHeight: 10,
                              metrics: [
                                LifestyleMetric(
                                  kind: LifestyleMetricKind.tidiness,
                                  value: data["avg_tidiness"] ?? 0.0,
                                ),
                                LifestyleMetric(
                                  kind: LifestyleMetricKind.noiseActivity,
                                  value: data["avg_noise_activity"] ?? 0.0,
                                ),
                                LifestyleMetric(
                                  kind: LifestyleMetricKind.schedule,
                                  value: data["avg_schedule"] ?? 0.0,
                                ),
                                LifestyleMetric(
                                  kind: LifestyleMetricKind.guestFrequency,
                                  value: data["avg_guest_frequency"] ?? 0.0,
                                ),
                                LifestyleMetric(
                                  kind: LifestyleMetricKind.taskStructure,
                                  value: data["avg_task_structure"] ?? 0.0,
                                ),
                                LifestyleMetric(
                                  kind: LifestyleMetricKind.moneyAttitude,
                                  value: data["avg_money_attitude"] ?? 0.0,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Roommates
                          const _SectionTitle('Roommates'),
                          const SizedBox(height: 8),
                          _RoommatesRow(
                            members: (data["members"] as List)
                                .map<(String, String)>((m) => (
                                      m["pic"]?.toString() ??
                                          "assets/images/fairnest.png",
                                      m["name"]?.toString() ?? "Member"
                                    ))
                                .toList(),
                          ),

                          const SizedBox(height: 22),

                          // CTA
                          MainButton(
                            text: 'Request to Join Room',
                            backgroundColor: AppColors.accent,
                            textColor: Colors.black,
                            width: double.infinity,
                            height: 54,
                            borderRadius: 12,
                            onPressed: widget.onRequestJoin ??
                                () async {
                                  final confirmed =
                                      await showHouseRulesDialog(context);
                                  if (confirmed == true) {
                                    // TODO: send join request API call here
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Request sent!')),
                                    );
                                  }
                                },
                          ),
                        ],
                        if (!hasError && data == null)
                          const Text("Room details not available."),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _fmtMoney(dynamic v) {
    if (v == null) return "—";
    if (v is num) return v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
    return v.toString();
  }
}

/* ----------------- Small pieces (unchanged styles) ----------------- */

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppFonts.heading3.copyWith(
        color: const Color(0xFF645A80),
      ),
    );
  }
}

/// Room overview card with bold/bigger apartment name and smaller details
class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.apartmentName,
    required this.leftRightRows,
  });

  final String apartmentName;
  final List<(String left, String right)> leftRightRows;

  static const _border = Color(0xFF645A80);

  @override
  Widget build(BuildContext context) {
    const double titleSize = 14;
    const double detailSize = titleSize - 2;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFECE9E6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  apartmentName,
                  style: const TextStyle(
                    fontFamily: 'Krub',
                    fontWeight: FontWeight.w700,
                    fontSize: titleSize,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < leftRightRows.length; i++) ...[
            _RowLine(
              left: leftRightRows[i].$1,
              right: leftRightRows[i].$2,
              fontSize: detailSize,
            ),
            if (i != leftRightRows.length - 1) const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _RowLine extends StatelessWidget {
  const _RowLine({
    required this.left,
    required this.right,
    this.fontSize = 12,
  });
  final String left;
  final String right;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final leftStyle = TextStyle(
      fontFamily: 'Krub',
      fontWeight: FontWeight.w400,
      fontSize: fontSize,
      color: Colors.black,
    );
    final rightStyle = TextStyle(
      fontFamily: 'Krub',
      fontWeight: FontWeight.w400,
      fontSize: fontSize,
      color: Colors.black87,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(left, style: leftStyle)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            right,
            style: rightStyle,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _RoommatesRow extends StatelessWidget {
  const _RoommatesRow({required this.members});

  final List<(String, String)> members;
  static const _lavender = Color(0xFF645A80);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFECE9E6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lavender, width: 1),
      ),
      child: Row(
        children: [
          for (final m in members) ...[
            _MemberChip(asset: m.$1, label: m.$2),
            const SizedBox(width: 8),
          ],
          const Spacer(),
        ],
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  const _MemberChip({required this.asset, required this.label});
  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isNetwork = asset.startsWith('http');
    return Column(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: Colors.white,
          child: ClipOval(
            child: isNetwork
                ? Image.network(asset, width: 32, height: 32, fit: BoxFit.cover)
                : Image.asset(asset, width: 32, height: 32, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Krub',
            fontSize: 10,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
