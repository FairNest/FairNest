import 'package:fairnestui/components/AccentBorderedCard.dart';
import 'package:fairnestui/components/ChoresProgressCard.dart';
import 'package:fairnestui/components/FinancesProgressCard.dart';
import 'package:fairnestui/components/LavenderBorderedCard.dart';
import 'package:fairnestui/components/RoomCompatibilityCard.dart';
import 'package:fairnestui/components/RoommateOverviewCard.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/widgets/room_header_appbar.dart';
import 'package:fairnestui/widgets/app_bottom_nav.dart';

class RoomDashboardPage extends StatefulWidget {
  const RoomDashboardPage({super.key});

  @override
  State<RoomDashboardPage> createState() => _RoomDashboardPageState();
}

class _RoomDashboardPageState extends State<RoomDashboardPage> {
  int _tab = 0; // pill tabs: 0 = Room, 1 = Your
  int _bottomIndex = 0; // bottom nav: 0..4 (Home, List, Center, Cash, Profile)

  void _onBottomTab(int i) {
    setState(() => _bottomIndex = i);

    // TODO: handle navigation per index (examples):
    // if (i == 0) { /* already on Home/RoomDashboard */ }
    // if (i == 1) { Navigator.push(context, MaterialPageRoute(builder: (_) => const ListPage())); }
    // if (i == 3) { Navigator.push(context, MaterialPageRoute(builder: (_) => const CashPage())); }
    // if (i == 4) { Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())); }
  }

  void _onCenterAction() {
    // Example: open compose/add sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SizedBox(
        height: 260,
        child:
            Center(child: Text('Create something…', style: AppFonts.heading1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: RoomHeaderAppBar(
        avatarImage: const AssetImage('assets/images/sample_face.jpg'),
        scoreText: '50 Points',
        progress: 0.5,
        onTapNotifications: () {},
        onTapSettings: () {},
      ),
      body: Padding(
        // tip: leave a bit more bottom padding so content never feels cramped above the nav
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome Back, George!",
              style: AppFonts.heading1.copyWith(color: AppColors.textPurple),
            ),
            const SizedBox(height: 12),
            _PillSegmentedControl(
              tabs: const ['Room Dashboard', 'Your Dashboard'],
              initialIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: const [
                  _RoomDashContent(),
                  _YourDashContent(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _bottomIndex,
        onTabSelected: _onBottomTab,
        onCenterAction: _onCenterAction,
      ),
    );
  }
}

/* ---------- Example content widgets ---------- */
class _RoomDashContent extends StatelessWidget {
  const _RoomDashContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // ← left-align children
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              "Notices",
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textPurple),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE2BDD1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black54),
            ),
            child: Stack(
              children: [
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 13, 10, 10),
                    child: Container(
                      height: 34,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Color(0xFFFAEDE5),
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Max added a new bill: Electricity ฿1,200 — due in 5 days ⚡",
                          style: TextStyle(
                              color: AppColors.textPink,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                      ),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 56, 10, 10),
                    child: Container(
                      height: 34,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Color(0xFFFAEDE5),
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Lando settled his part of the water bill 💧",
                          style: TextStyle(
                              color: AppColors.textPink,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                      ),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 100, 10, 10),
                    child: Container(
                      height: 34,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Color(0xFFFAEDE5),
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "New payment reminder: Rent due in 3 days 🏠",
                          style: TextStyle(
                              color: AppColors.textPink,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Text(
                  "Overall Room Status",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPurple),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 70, bottom: 15),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.background, // cream bg
                    foregroundColor: AppColors.darkPurple, // text color
                    elevation: 3, // remove shadow
                    padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    shape: const StadiumBorder(
                      side: BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    textStyle: AppFonts.heading1.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text("House Rules"),
                ),
              )
            ],
          ),
          LavenderBorderedCard(
              child: Column(
            children: [
              Container(
                height: 350,
                child: Column(
                  children: [
                    RoomCompatibilityCard(value: 0.5),
                    SizedBox(
                      height: 10,
                    ),
                    ChoresProgressCard(
                      totalTasks: 6,
                      completedTasks: 5,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    FinancesProgressCard(completedFinances: 2, totalFinances: 6)
                  ],
                ),
              ),
            ],
          )),
          SizedBox(
            height: 15,
          ),
          Container(
            child: Text(
              "Roommate Overview",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPurple),
            ),
          ),
          AccentBorderedCard(
            child: Container(
              height: 350,
              width: double.infinity,
              child: Column(
                children: [
                  Roommateoverviewcard(
                    name: "Max",
                    compatibilityScore: 43,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Roommateoverviewcard(name: "George", compatibilityScore: 50),
                  SizedBox(
                    height: 20,
                  ),
                  Roommateoverviewcard(name: "Lando", compatibilityScore: 1)
                ],
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}

class _YourDashContent extends StatelessWidget {
  const _YourDashContent({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          Text('Your personal dashboard stuff here', style: AppFonts.heading1),
    );
  }
}

/* ---------- Baked-in pill control ---------- */
class _PillSegmentedControl extends StatefulWidget {
  const _PillSegmentedControl({
    required this.tabs,
    required this.onChanged,
    this.initialIndex = 0,
    this.height = 44,
    super.key,
  });

  final List<String> tabs;
  final int initialIndex;
  final ValueChanged<int> onChanged;
  final double height;

  @override
  State<_PillSegmentedControl> createState() => _PillSegmentedControlState();
}

class _PillSegmentedControlState extends State<_PillSegmentedControl> {
  late int _index = widget.initialIndex;

  // Baked-in brand colors
  static const Color _pink = Color(0xFFFF8FB5); // track
  static const Color _cream = Color(0xFFFFF1E8); // thumb
  static const EdgeInsets _padding = EdgeInsets.all(6);

  Alignment _alignmentFor(int i, int len) {
    // Map index to alignmentX in [-1, 1]
    if (len <= 1) return Alignment.center;
    final step = 2.0 / (len - 1); // distance between slots
    final x = -1.0 + (i * step);
    return Alignment(x, 0);
  }

  @override
  Widget build(BuildContext context) {
    final tabCount = widget.tabs.length.clamp(1, 6); // safety

    return SizedBox(
      width: double.infinity, // ensure full width so fractions work
      child: Container(
        height: widget.height,
        padding: _padding,
        decoration: BoxDecoration(
          color: _pink,
          borderRadius: BorderRadius.circular(widget.height),
        ),
        child: Stack(
          children: [
            // Cream thumb under labels (now using AnimatedAlign + FractionallySizedBox)
            AnimatedAlign(
              alignment: _alignmentFor(_index, tabCount),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: FractionallySizedBox(
                widthFactor: 1 / tabCount,
                heightFactor: 1,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(widget.height),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Labels layer
            Row(
              children: List.generate(tabCount, (i) {
                final selected = i == _index;
                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(widget.height),
                    onTap: () {
                      if (_index != i) {
                        setState(() => _index = i);
                        widget.onChanged(i);
                      }
                    },
                    child: Center(
                      child: Text(
                        widget.tabs[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.heading1.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.textPink
                              : AppColors.textPurple,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
