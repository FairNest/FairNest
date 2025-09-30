import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessPopup extends StatelessWidget {
  final String message;
  final VoidCallback? onClose;
  final Duration autoCloseDuration;
  final bool showCloseButton;
  final Color backgroundColor;
  final Color textColor;
  final double animationSize;

  const SuccessPopup({
    super.key,
    required this.message,
    this.onClose,
    this.autoCloseDuration = const Duration(seconds: 3),
    this.showCloseButton = false,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.animationSize = 120.0,
  });

  /// Show success popup as an overlay
  static void show(
    BuildContext context, {
    required String message,
    VoidCallback? onClose,
    Duration autoCloseDuration = const Duration(seconds: 3),
    bool showCloseButton = false,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black87,
    double animationSize = 120.0,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => SuccessPopup(
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
    return _SuccessPopupContent(
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

class _SuccessPopupContent extends StatefulWidget {
  final String message;
  final VoidCallback? onClose;
  final Duration autoCloseDuration;
  final bool showCloseButton;
  final Color backgroundColor;
  final Color textColor;
  final double animationSize;

  const _SuccessPopupContent({
    required this.message,
    this.onClose,
    required this.autoCloseDuration,
    required this.showCloseButton,
    required this.backgroundColor,
    required this.textColor,
    required this.animationSize,
  });

  @override
  State<_SuccessPopupContent> createState() => _SuccessPopupContentState();
}

class _SuccessPopupContentState extends State<_SuccessPopupContent>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    return PopScope(
      canPop: false,
      child: Material(
        type: MaterialType.transparency,
        child: Center(
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

                    // Success animation
                    Lottie.asset(
                      'assets/animations/success.json', // Your success animation
                      width: widget.animationSize,
                      height: widget.animationSize,
                      fit: BoxFit.contain,
                      repeat: false,
                      animate: true,
                    ),

                    const SizedBox(height: 16),

                    // Success message
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Krub',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
