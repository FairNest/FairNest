import 'package:flutter/material.dart';

enum FairDialogType { confirm, success, info }

class FairDialog {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    FairDialogType type = FairDialogType.info,
    String? primaryLabel,
    Color? primaryColor,
    VoidCallback? onPrimary,
    String? secondaryLabel,
    Color? secondaryColor,
    VoidCallback? onSecondary,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFFECE9E6), // Popup background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF645A80), // Heading color
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons
                if (type == FairDialogType.confirm) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                secondaryColor ?? Colors.orange, // Cancel color
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: onSecondary,
                          child: Text(secondaryLabel ?? 'Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                primaryColor ?? Colors.green, // Confirm color
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: onPrimary,
                          child: Text(primaryLabel ?? 'OK'),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryColor ?? const Color(0xFFE7AC66),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onPrimary ?? () => Navigator.pop(context),
                      child: Text(primaryLabel ?? 'Okay'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
