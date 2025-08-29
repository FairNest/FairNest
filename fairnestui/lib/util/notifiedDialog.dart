import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_fonts.dart';

const _notifCardSize = Size(284, 193);
const _notifBg = Color(0xFFECE9E6);
const _notifAccent = Color(0xFF645A80);

Future<void> showNotifiedDialog(BuildContext context, {required String name}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => Center(
      child: Dialog(
        elevation: 10,
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: _notifCardSize.width,
          height: _notifCardSize.height,
          child: Container(
            decoration: BoxDecoration(
              color: _notifBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  color: Colors.black.withOpacity(0.12),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Close (X)
                Positioned(
                  top: 12,
                  right: 12,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 28,
                      height: 28,
                      child: Icon(Icons.close_rounded,
                          size: 22, color: _notifAccent),
                    ),
                  ),
                ),

                // Content
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Image.asset(
                        'assets/images/mail-notification.png', // ensure in pubspec.yaml
                        width: 120,
                        height: 120,
                        color: _notifAccent,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$name has been notified!',
                        textAlign: TextAlign.center,
                        style: AppFonts.heading3.copyWith(color: _notifAccent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
