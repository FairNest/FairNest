import 'package:fairnestui/components/SecondaryButton.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_fonts.dart';

// =================== Shared styles ===================
const _cardSize = Size(382, 247);
const _bgColor = Color(0xFFECE9E6);
const _accent = Color(0xFF645A80);

// =================== Notified dialog ===================
const _notifSize = Size(284, 193);

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
          width: _notifSize.width,
          height: _notifSize.height,
          child: Container(
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  color: Colors.black.withValues(alpha: .12),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 12,
                  right: 12,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 28,
                      height: 28,
                      child:
                          Icon(Icons.close_rounded, size: 22, color: _accent),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/mail-notification.png',
                        width: 56,
                        height: 56,
                        color: _accent,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$name has been notified!',
                        textAlign: TextAlign.center,
                        style: AppFonts.heading3.copyWith(color: _accent),
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

// =================== Reminder dialog (opens notified on Yes) ===================
Future<bool?> showReminderDialog(BuildContext context, {required String name}) {
  // capture outer context for chaining dialogs safely
  final rootContext = context;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(
      child: Dialog(
        elevation: 10,
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: _cardSize.width,
          height: _cardSize.height,
          child: Container(
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  color: Colors.black.withValues(alpha: .15),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/images/notifications-sound.png',
                  width: 56,
                  height: 56,
                  color: _accent,
                  colorBlendMode: BlendMode.srcIn,
                ),
                Text(
                  'Do you want to send $name a Reminder?',
                  textAlign: TextAlign.center,
                  style: AppFonts.heading3.copyWith(color: _accent),
                ),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: 'No',
                        onPressed: () => Navigator.of(rootContext).pop(false),
                        width: double.infinity,
                        height: 48,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SecondaryButton(
                        text: 'Yes!',
                        backgroundColor: const Color(0xFF6CC08B),
                        textColor: Colors.white,
                        width: double.infinity,
                        height: 48,
                        onPressed: () {
                          // 1) Close this dialog
                          Navigator.of(rootContext).pop(true);
                          // 2) Then show the "notified" dialog
                          Future.microtask(() {
                            showNotifiedDialog(rootContext, name: name);
                          });
                        },
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
  );
}
