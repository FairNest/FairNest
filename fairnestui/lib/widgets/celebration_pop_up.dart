import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CelebrationPopup extends StatelessWidget {
  final String message;
  final VoidCallback? onClose;
  final Duration autoCloseDuration;
  final bool showCloseButton;
  final Color backgroundColor;
  final Color textColor;
  final double animationSize;

  const CelebrationPopup({
    super.key,
    required this.message,
    this.onClose,
    this.autoCloseDuration = const Duration(seconds: 4),
    this.showCloseButton = false,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.animationSize = 200.0,
  });

  /// Show celebration popup as an overlay
  static void show(
    BuildContext context, {
    required String message,
    VoidCallback? onClose,
    Duration autoCloseDuration = const Duration(seconds: 4),
    bool showCloseButton = false,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black87,
    double animationSize = 200.0,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (context) => CelebrationPopup(
        message: message,
        onClose: onClose ?? () => Navigator.of(context).pop(),
        autoCloseDuration: autoCloseDuration,
        showCloseButton: showCloseButton,
        backgroundColor: backgroundColor,
        textColor: textColor,
        animationSize: animationSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _CelebrationPopupContent(
      message: message,
      onClose: onClose,
      autoCloseDuration: autoCloseDuration,
      showCloseButton: showCloseButton,
      backgroundColor: backgroundColor,
      textColor: textColor,
      animationSize: animationSize,
    );
  }
}

class _CelebrationPopupContent extends StatefulWidget {
  final String message;
  final VoidCallback? onClose;
  final Duration autoCloseDuration;
  final bool showCloseButton;
  final Color backgroundColor;
  final Color textColor;
  final double animationSize;

  const _CelebrationPopupContent({
    required this.message,
    this.onClose,
    required this.autoCloseDuration,
    required this.showCloseButton,
    required this.backgroundColor,
    required this.textColor,
    required this.animationSize,
  });

  @override
  State<_CelebrationPopupContent> createState() =>
      _CelebrationPopupContentState();
}

class _CelebrationPopupContentState extends State<_CelebrationPopupContent>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Start entrance animation
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _scaleController.forward();
    });

    // Auto close if specified
    if (widget.autoCloseDuration != Duration.zero) {
      Future.delayed(widget.autoCloseDuration, () {
        if (mounted) _close();
      });
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _close() async {
    if (!mounted) return;

    // Exit animation
    await _scaleController.reverse();
    await _fadeController.reverse();

    if (mounted && widget.onClose != null) {
      widget.onClose!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Full screen confetti animation
          Positioned.fill(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Lottie.asset(
                'assets/animations/celebration.json', // Your confetti animation
                fit: BoxFit.cover,
                repeat: false,
                animate: true,
              ),
            ),
          ),

          // Centered message card
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close button (if enabled)
                      if (widget.showCloseButton)
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: _close,
                            icon: const Icon(Icons.close, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                          ),
                        ),

                      // Celebration emoji or icon
                      const Text(
                        '🎉',
                        style: TextStyle(fontSize: 40),
                      ),

                      const SizedBox(height: 16),

                      // Celebration message
                      Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Krub',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: widget.textColor,
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
