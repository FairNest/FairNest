import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ErrorPopup extends StatelessWidget {
  final String message;
  final VoidCallback? onClose;
  final VoidCallback? onRetry;
  final Duration autoCloseDuration;
  final bool showCloseButton;
  final bool showRetryButton;
  final Color backgroundColor;
  final Color textColor;
  final double animationSize;

  const ErrorPopup({
    super.key,
    required this.message,
    this.onClose,
    this.onRetry,
    this.autoCloseDuration = const Duration(seconds: 4),
    this.showCloseButton = true,
    this.showRetryButton = false,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.animationSize = 100.0,
  });

  /// Show error popup as an overlay
  static void show(
    BuildContext context, {
    required String message,
    VoidCallback? onClose,
    VoidCallback? onRetry,
    Duration autoCloseDuration = const Duration(seconds: 4),
    bool showCloseButton = true,
    bool showRetryButton = false,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black87,
    double animationSize = 100.0,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => ErrorPopup(
        message: message,
        onClose: onClose ?? () => Navigator.of(context).pop(),
        onRetry: onRetry,
        autoCloseDuration: autoCloseDuration,
        showCloseButton: showCloseButton,
        showRetryButton: showRetryButton,
        backgroundColor: backgroundColor,
        textColor: textColor,
        animationSize: animationSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ErrorPopupContent(
      message: message,
      onClose: onClose,
      onRetry: onRetry,
      autoCloseDuration: autoCloseDuration,
      showCloseButton: showCloseButton,
      showRetryButton: showRetryButton,
      backgroundColor: backgroundColor,
      textColor: textColor,
      animationSize: animationSize,
    );
  }
}

class _ErrorPopupContent extends StatefulWidget {
  final String message;
  final VoidCallback? onClose;
  final VoidCallback? onRetry;
  final Duration autoCloseDuration;
  final bool showCloseButton;
  final bool showRetryButton;
  final Color backgroundColor;
  final Color textColor;
  final double animationSize;

  const _ErrorPopupContent({
    required this.message,
    this.onClose,
    this.onRetry,
    required this.autoCloseDuration,
    required this.showCloseButton,
    required this.showRetryButton,
    required this.backgroundColor,
    required this.textColor,
    required this.animationSize,
  });

  @override
  State<_ErrorPopupContent> createState() => _ErrorPopupContentState();
}

class _ErrorPopupContentState extends State<_ErrorPopupContent>
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

    // Auto close if specified and no retry button
    if (widget.autoCloseDuration != Duration.zero && !widget.showRetryButton) {
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
      canPop: true,
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
                  border: Border.all(
                    color: const Color(0xFFD13030).withAlpha(50),
                    width: 1,
                  ),
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
                    if (widget.showCloseButton && !widget.showRetryButton)
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

                    // Error animation
                    Lottie.asset(
                      'assets/animations/error.json', // Your error animation
                      width: widget.animationSize,
                      height: widget.animationSize,
                      fit: BoxFit.contain,
                      repeat: false,
                      animate: true,
                    ),

                    const SizedBox(height: 16),

                    // Error message
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Krub',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.textColor,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Action buttons
                    if (widget.showRetryButton || widget.showCloseButton)
                      Row(
                        children: [
                          if (widget.showCloseButton && widget.showRetryButton)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _close,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'Krub',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          if (widget.showCloseButton && widget.showRetryButton)
                            const SizedBox(width: 12),
                          if (widget.showRetryButton)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _close();
                                  if (widget.onRetry != null) {
                                    widget.onRetry!();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD13030),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(
                                    fontFamily: 'Krub',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          if (!widget.showRetryButton && widget.showCloseButton)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _close,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade600,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text(
                                  'OK',
                                  style: TextStyle(
                                    fontFamily: 'Krub',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
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
