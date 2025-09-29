import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;

class Loading3DWidget extends StatefulWidget {
  final String message;
  final Color primaryColor;
  final Color secondaryColor;
  final double size;

  /// NEW: reduce clutter / boost clarity
  final bool showOrbit; // roommate bubbles
  final bool showSparkles; // construction sparkles
  final bool showLogo; // interior logo

  const Loading3DWidget({
    super.key,
    this.message = 'Loading...',
    this.primaryColor = const Color(0xFFC7BDE2),
    this.secondaryColor = const Color(0xFF645A80),
    this.size = 120.0,
    this.showOrbit = true,
    this.showSparkles = true,
    this.showLogo = false,
  });

  @override
  State<Loading3DWidget> createState() => _Loading3DWidgetState();
}

class _Loading3DWidgetState extends State<Loading3DWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _roommateController;
  late AnimationController _bounceController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _roommateAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _roommateController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    _roommateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _roommateController, curve: Curves.linear),
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
    _roommateController.repeat();
    _bounceController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _roommateController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([
              _pulseAnimation,
              _roommateAnimation,
              _bounceAnimation,
            ]),
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(0, _bounceAnimation.value),
                child: Transform.scale(
                  scale: _pulseAnimation.value,
                  child: _buildScene(),
                ),
              );
            },
          ),
          const SizedBox(height: 36),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, _) {
              final op =
                  (0.9 + (_pulseAnimation.value - 1) * 0.2).clamp(0.0, 1.0);
              return Opacity(
                opacity: op,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_rounded,
                        color: widget.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.message,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: widget.primaryColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.people_rounded,
                        color: Color(0xFFFF96B4), size: 20),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildActivityIndicators(),
        ],
      ),
    );
  }

  Widget _buildScene() {
    // scene sized slightly larger so nothing looks cramped
    return SizedBox(
      width: widget.size * 1.8,
      height: widget.size * 1.8,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (widget.showOrbit) ..._buildOrbitingRoommates(behind: true),
          if (widget.showOrbit) ..._buildFloatingActivities(behind: true),
          _buildLottieHouse(),
          if (widget.showOrbit) ..._buildOrbitingRoommates(behind: false),
          if (widget.showOrbit) ..._buildFloatingActivities(behind: false),
        ],
      ),
    );
  }

  Widget _buildLottieHouse() {
    return Center(
      child: Lottie.asset(
        'assets/animations/house_popup_fairnest.json', // Make sure to add this to your assets
        width: widget.size * 4,
        height: widget.size * 4,
        fit: BoxFit.contain,
        repeat: true,
        reverse: false,
        animate: true,
      ),
    );
  }

  // --- EFFECTS & ORBITS -----------------------------------------------------

  List<Widget> _buildOrbitingRoommates({bool behind = false}) {
    final icons = [
      Icons.person_rounded,
      Icons.person_2_rounded,
      Icons.person_3_rounded,
      Icons.person_4_rounded,
    ];
    final colors = [
      const Color(0xFFFF96B4),
      const Color(0xFFE7AC66),
      widget.primaryColor,
      widget.secondaryColor,
    ];

    return List.generate(4, (i) {
      return AnimatedBuilder(
        animation: _roommateAnimation,
        builder: (context, _) {
          final angle = _roommateAnimation.value + i * math.pi / 2;
          final radius = widget.size * (behind ? 1.10 : 0.9); // farther out
          final cx = widget.size * 0.80;
          final cy = widget.size * 0.78 - 6;
          final x = math.cos(angle) * radius;
          final y = math.sin(angle) * radius;
          final bob = math.sin(_roommateAnimation.value * 3 + i) * 5;

          return Positioned(
            left: cx + x - 20,
            top: cy + y - 20 + bob,
            child: Transform.scale(
              scale: 0.9 + math.sin(_roommateAnimation.value * 2 + i) * 0.12,
              child: Opacity(
                opacity: behind ? 0.6 : 1.0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors[i].withAlpha(190),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors[i].withAlpha(76),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(icons[i], color: Colors.white, size: 20),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  List<Widget> _buildFloatingActivities({bool behind = false}) {
    final activityIcons = [
      Icons.cleaning_services_rounded,
      Icons.kitchen_rounded,
      Icons.bed_rounded,
      Icons.tv_rounded,
      Icons.local_laundry_service_rounded,
      Icons.spa_rounded,
    ];

    return List.generate(6, (i) {
      return AnimatedBuilder(
        animation: _roommateAnimation,
        builder: (context, _) {
          final angle = (_roommateAnimation.value * 0.5) + (i * math.pi / 3);
          final radius = widget.size * (behind ? 1.25 : 1.05) +
              math.sin(_roommateAnimation.value * 4 + i) * 10;
          final cx = widget.size * 0.80;
          final cy = widget.size * 0.78 - 6;
          final x = math.cos(angle) * radius;
          final y = math.sin(angle) * radius;

          final scale =
              0.65 + math.sin(_roommateAnimation.value * 3 + i) * 0.25;
          final opacity = ((behind ? 0.4 : 0.8) +
                  math.sin(_roommateAnimation.value * 2 + i) * 0.15)
              .clamp(0.0, 1.0);

          return Positioned(
            left: cx + x - 12,
            top: cy + y - 12,
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withAlpha(178),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withAlpha(76),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(activityIcons[i], color: Colors.white, size: 12),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  // --- UI bits --------------------------------------------------------------

  Widget _buildActivityIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _activityDot(
            'Chores', Icons.cleaning_services_rounded, const Color(0xFFE7AC66)),
        const SizedBox(width: 16),
        _activityDot(
            'Finance', Icons.receipt_long_rounded, const Color(0xFFFF96B4)),
        const SizedBox(width: 16),
        _activityDot(
            'Compatibility', Icons.chat_bubble_rounded, widget.primaryColor),
      ],
    );
  }

  Widget _activityDot(String label, IconData icon, Color color) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final delay = label.hashCode % 3;
        final scale =
            0.85 + math.sin(_pulseController.value * math.pi + delay) * 0.15;

        return Transform.scale(
          scale: scale,
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withAlpha(210),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(76),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }
}
