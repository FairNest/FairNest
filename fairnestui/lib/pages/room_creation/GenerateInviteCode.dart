import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/components/MainButton.dart';

class GenerateInviteCodePage extends StatefulWidget {
  const GenerateInviteCodePage({
    super.key,
    this.onCreateRoom,
  });

  /// Callback when the “Create a Room” button is pressed.
  /// You’ll likely navigate to the actual room after persisting.
  final void Function(String inviteCode)? onCreateRoom;

  @override
  State<GenerateInviteCodePage> createState() => _GenerateInviteCodePageState();
}

class _GenerateInviteCodePageState extends State<GenerateInviteCodePage> {
  late final TextEditingController _codeCtrl;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(text: _generateInviteCode());
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  /// Generates a pretty unique code:
  ///   - 4 chars from base36 timestamp
  ///   - 5 chars from secure random (A–Z, 0–9 without confusing chars)
  /// Example:  "XDRWQA11" style
  String _generateInviteCode() {
    final nowPart =
        DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    final timeChunk =
        nowPart.substring(max(0, nowPart.length - 4)); // last 4 chars
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0,1,O,I
    final rand = Random.secure();
    final randPart =
        List.generate(5, (_) => alphabet[rand.nextInt(alphabet.length)]).join();
    return (timeChunk + randPart);
  }

  void _copy() async {
    await Clipboard.setData(ClipboardData(text: _codeCtrl.text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite code copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header (purple with back + centered title)
          Container(
            width: double.infinity,
            height: top + 69,
            padding: EdgeInsets.only(top: top),
            color: AppColors.primary,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 12,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF645A80), size: 26),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                Text(
                  'Create a Room',
                  style: AppFonts.heading1
                      .copyWith(color: const Color(0xFF645A80)),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generate Invite Code',
                    style: AppFonts.heading1
                        .copyWith(color: const Color(0xFF645A80)),
                  ),
                  const SizedBox(height: 18),

                  // Code field (read-only)
                  TextField(
                    controller: _codeCtrl,
                    readOnly: true,
                    style: const TextStyle(
                      fontFamily: 'Krub',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black,
                      letterSpacing: 1.0,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFECE9E6),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF645A80), width: 1.2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF645A80), width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF645A80), width: 1.6),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Copy button (pink)
                  MainButton(
                    text: 'Copy Code',
                    backgroundColor: AppColors.secondary,
                    textColor: Colors.black,
                    width: double.infinity,
                    height: 52,
                    borderRadius: 12,
                    onPressed: _copy,
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFDBD3C8), thickness: 2),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      "Now let’s create your room!",
                      style: TextStyle(
                        fontFamily: 'Krub',
                        fontSize: 12,
                        color: Color(0xFF6C6577),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Create a Room (gold)
                  MainButton(
                    text: 'Create a Room',
                    backgroundColor: const Color(0xFFD8A85B),
                    textColor: Colors.black,
                    width: double.infinity,
                    height: 52,
                    borderRadius: 12,
                    onPressed: () => widget.onCreateRoom?.call(_codeCtrl.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
