import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';

enum SplitType { even, custom }

class Financetaskcard extends StatelessWidget {
  const Financetaskcard({
    super.key,

    // required data
    required this.title, // e.g. "Water Bill"
    required this.amount, // your share (shown top-right)
    required this.totalAmount, // total bill
    required this.points, // +10 etc

    // split
    required this.splitType, // SplitType.even | SplitType.custom
    this.splitCount, // required when splitType == even
    this.customSplitLabel, // optional label when custom (e.g. "60/40")

    // misc
    this.currency = 'THB',
    this.payToName = 'Max',
    this.paidByImage,
    this.qrData,
    this.onSettled,
    this.isCompleted = false, // ADD THIS: Track completion status
  });

  // ---- data ----
  final String title;
  final int amount; // your share shown in header
  final int totalAmount; // "Total" chip
  final int points; // "+10" badge

  final SplitType splitType;
  final int? splitCount; // used when even
  final String? customSplitLabel; // used when custom

  final String currency;
  final String payToName;
  final ImageProvider? paidByImage;
  final String? qrData; // Now expects base64 string
  final VoidCallback? onSettled;
  final bool isCompleted; // ADD THIS: Track if the task is completed

  String get _splitLabel {
    if (splitType == SplitType.even) {
      final n = (splitCount ?? 1).clamp(1, 99);
      return 'Even ($n)';
    }
    return customSplitLabel?.trim().isNotEmpty == true
        ? customSplitLabel!.trim()
        : 'Custom';
  }

  // Helper to truncate name if longer than maxLength
  String _truncateName(String name, {int maxLength = 10}) {
    if (name.length <= maxLength) return name;
    return '${name.substring(0, maxLength)}...';
  }

  // Helper to convert base64 string to image bytes
  Uint8List? _base64ToImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      // Remove data:image/png;base64, prefix if present
      final base64Data =
          base64String.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
      return base64Decode(base64Data);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    const grayChip = Color(0xFF8D8B8B); // same as your chores chips

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color.fromARGB(255, 106, 166, 130), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Header ----------
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                    color: AppColors.textPurple, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(Icons.payments_rounded,
                    size: 20, color: AppColors.background),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPurple,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${_fmt(amount)} $currency',
                style: const TextStyle(
                  color: AppColors.textPurple,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              // +points badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+$points',
                  style: const TextStyle(
                    color: AppColors.textOrange,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ---------- Total & Split in gray chips ----------
          Row(
            children: [
              _LabeledValueChip(
                label: 'Total',
                value: '${_fmt(totalAmount)} $currency',
                color: grayChip,
              ),
              const SizedBox(width: 18),
              _LabeledValueChip(
                label: 'Split',
                value: _splitLabel,
                color: grayChip,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ---------- Receiver row ----------
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: paidByImage,
                child: paidByImage == null
                    ? const Icon(Icons.person, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pay to ${_truncateName(payToName, maxLength: 10)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPurple,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // UPDATED BUTTON: Changes based on completion status
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted
                      ? const Color(0xFF6CC08B) // Green when settled
                      : const Color(0xFF9C2D3C), // Red when not settled
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isCompleted
                    ? null // Disable button when completed
                    : () => _showQrSheet(
                        context), // Show QR sheet when not completed
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCompleted) ...[
                      const Icon(Icons.check_circle, size: 16),
                      const SizedBox(width: 4),
                    ],
                    Text(isCompleted ? 'Settled' : 'Settle now'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- QR Sheet + Dialog ----------
  Future<void> _showQrSheet(BuildContext context) async {
    final qrImageBytes = _base64ToImage(qrData);

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pay ${_fmt(amount)} $currency to $payToName',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.textPurple,
                  ),
                ),
                const SizedBox(height: 12),
                // QR Code - Now displays actual base64 decoded image
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.textPurple.withValues(alpha: .6),
                        width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.center,
                  child: qrImageBytes != null
                      ? Image.memory(
                          qrImageBytes,
                          fit: BoxFit.contain,
                        )
                      : const Text(
                          'No QR code available',
                          style: TextStyle(
                            color: AppColors.textPurple,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Scan with your banking app to settle.',
                  style: TextStyle(
                    color: AppColors.textPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetCtx),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.pop(sheetCtx);
                          Future.microtask(() {
                            // Call the onSettled callback which should handle polling
                            onSettled?.call();
                          });
                        },
                        child: const Text('Verify'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      count++;
      if (count == 3 && i != 0) {
        buf.write(',');
        count = 0;
      }
    }
    return buf.toString().split('').reversed.join();
  }
}

// --- tiny chip like your chores chips (label on top, gray value below) ---
class _LabeledValueChip extends StatelessWidget {
  const _LabeledValueChip({
    required this.label,
    required this.value,
    this.color = const Color(0xFF8D8B8B),
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPurple)),
        const SizedBox(height: 4),
        Container(
          height: 18,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.background,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
