import 'package:flutter/material.dart';
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
  late AnimationController _buildController;
  late AnimationController _pulseController;
  late AnimationController _roommateController;
  late AnimationController _bounceController;

  late Animation<double> _buildAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _roommateAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _buildController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _buildAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _buildController, curve: Curves.easeInOut),
    );

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

    _buildController.forward(); // build once
    _pulseController.repeat(reverse: true);
    _roommateController.repeat();
    _bounceController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _buildController.dispose();
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
              _buildAnimation,
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
          if (widget.showOrbit && _buildAnimation.value > 0.3)
            ..._buildOrbitingRoommates(behind: true),
          if (widget.showOrbit && _buildAnimation.value > 0.6)
            ..._buildFloatingActivities(behind: true),
          _buildHouseStructure(),
          if (widget.showSparkles && _buildAnimation.value < 1.0)
            ..._buildConstructionEffects(),
        ],
      ),
    );
  }

  Widget _buildHouseStructure() {
    final progress = _buildAnimation.value;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (progress > 0.0)
            AnimatedOpacity(
              opacity: (progress * 4).clamp(0.0, 1.0),
              duration: const Duration(milliseconds: 350),
              child: _foundation(),
            ),
          if (progress > 0.25)
            AnimatedOpacity(
              opacity: ((progress - 0.25) * 4).clamp(0.0, 1.0),
              duration: const Duration(milliseconds: 350),
              child: _walls(),
            ),
          if (progress > 0.5)
            AnimatedOpacity(
              opacity: ((progress - 0.5) * 4).clamp(0.0, 1.0),
              duration: const Duration(milliseconds: 350),
              child: _roof(),
            ),
          if (progress > 0.75)
            AnimatedOpacity(
              opacity: ((progress - 0.75) * 4).clamp(0.0, 1.0),
              duration: const Duration(milliseconds: 350),
              child: _interior(),
            ),
        ],
      ),
    );
  }

  // --- HOUSE PARTS ----------------------------------------------------------

  Widget _foundation() {
    return Positioned(
      bottom: widget.size * 0.12,
      child: Container(
        width: widget.size * 0.98,
        height: widget.size * 0.12,
        decoration: BoxDecoration(
          color: widget.secondaryColor.withAlpha(210),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: widget.secondaryColor.withAlpha(70),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _walls() {
    final w = widget.size * 0.8;
    final h = widget.size * 0.72;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1EC),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: widget.primaryColor.withAlpha(140), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: widget.secondaryColor.withAlpha(50),
            blurRadius: 14,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _roof() {
    final roofW = widget.size * 0.98; // wider overhang
    final roofH = widget.size * 0.36;

    return Positioned(
      top: widget.size * 0.0,
      child: SizedBox(
        width: roofW,
        height: roofH,
        child: CustomPaint(
          painter: _RoofPainter(const Color(0xFFD28B40),
              stroke: const Color(0xFFB57835)),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // chimney
              Positioned(
                right: roofW * 0.14,
                top: -roofH * 0.28,
                child: Container(
                  width: 14,
                  height: roofH * 0.62,
                  decoration: BoxDecoration(
                    color: widget.secondaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _interior() {
    final inset = widget.size * 0.12;

    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(inset, inset * 1.05, inset, inset * 0.9),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.showLogo) ...[
              Expanded(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Image.asset('assets/images/fairnest.png'),
                ),
              ),
              const SizedBox(height: 6),
            ],
            // windows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_window(), _window()],
            ),
            const SizedBox(height: 10),
            // door
            Container(
              width: widget.size * 0.20,
              height: widget.size * 0.24,
              decoration: BoxDecoration(
                color: const Color(0xFFE6D0BE),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: widget.secondaryColor.withAlpha(150), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: widget.secondaryColor.withAlpha(40),
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: widget.secondaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _window() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: widget.primaryColor.withAlpha(70),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: widget.primaryColor, width: 2.5),
      ),
      child: Stack(
        children: [
          Center(
              child:
                  Container(width: 2, height: 14, color: widget.primaryColor)),
          Center(
              child:
                  Container(width: 14, height: 2, color: widget.primaryColor)),
        ],
      ),
    );
  }

  // --- EFFECTS & ORBITS -----------------------------------------------------

  List<Widget> _buildConstructionEffects() {
    return List.generate(6, (index) {
      return AnimatedBuilder(
        animation: _buildController,
        builder: (context, _) {
          final p = (_buildController.value * 3 + index * 0.33) % 1.0;
          final angle = index * math.pi / 3;
          final radius = widget.size * 0.42 * p;
          final x = math.cos(angle) * radius;
          final y = math.sin(angle) * radius;

          return Positioned(
            left: widget.size * 0.5 + x - 4,
            top: widget.size * 0.5 + y - 4,
            child: Opacity(
              opacity: (1 - p).clamp(0.0, 1.0),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFD28B40),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD28B40).withAlpha(120),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

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
                opacity: behind ? 0.8 : 1.0,
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
        animation: _buildController,
        builder: (context, _) {
          final angle =
              (_buildController.value * 2 * math.pi * 0.5) + (i * math.pi / 3);
          final radius = widget.size * (behind ? 1.25 : 1.05) +
              math.sin(_buildController.value * 4 * math.pi + i) * 10;
          final cx = widget.size * 0.80;
          final cy = widget.size * 0.78 - 6;
          final x = math.cos(angle) * radius;
          final y = math.sin(angle) * radius;

          final scale =
              0.65 + math.sin(_buildController.value * 3 * math.pi + i) * 0.25;
          final opacity = ((behind ? 0.55 : 0.8) +
                  math.sin(_buildController.value * 2 * math.pi + i) * 0.15)
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
        _activityDot('Chat', Icons.chat_bubble_rounded, widget.primaryColor),
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

// Triangular roof painter with an outline stroke for readability
class _RoofPainter extends CustomPainter {
  final Color fill;
  final Color stroke;
  _RoofPainter(this.fill, {this.stroke = const Color(0xFFB57835)});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();

    // subtle drop shadow
    canvas.drawShadow(path, fill.withAlpha(110), 8, true);

    // fill
    final paintFill = Paint()..color = fill;
    canvas.drawPath(path, paintFill);

    // stroke/outline
    final paintStroke = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(path, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
