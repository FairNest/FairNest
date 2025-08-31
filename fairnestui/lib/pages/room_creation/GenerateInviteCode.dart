// generate_invite_code_page.dart
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/components/MainButton.dart';

class GenerateInviteCodePage extends StatelessWidget {
  const GenerateInviteCodePage({
    super.key,
    required this.roomCode,
    this.onCreateRoom,
  });

  /// The invite code returned from the backend (room_code).
  final String? roomCode;

  /// Optional callback when the “See your Room” button is pressed.
  final void Function(String inviteCode)? onCreateRoom;

  Future<void> _copy(BuildContext context) async {
    final code = roomCode ?? '';
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite code copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final code = (roomCode ?? '').trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
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
                    controller: TextEditingController(text: code),
                    readOnly: true,
                    style: const TextStyle(
                      fontFamily: 'Krub',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black,
                      letterSpacing: 1.0,
                    ),
                    decoration: InputDecoration(
                      hintText: 'No code returned',
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

                  // Copy button
                  MainButton(
                    text: 'Copy Code',
                    backgroundColor: AppColors.secondary,
                    textColor: Colors.black,
                    width: double.infinity,
                    height: 52,
                    borderRadius: 12,
                    onPressed: code.isEmpty ? null : () => _copy(context),
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFDBD3C8), thickness: 2),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      "Now let’s see your room!",
                      style: TextStyle(
                        fontFamily: 'Krub',
                        fontSize: 12,
                        color: Color(0xFF6C6577),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // See your Room
                  MainButton(
                    text: 'See your Room',
                    backgroundColor: const Color(0xFFD8A85B),
                    textColor: Colors.black,
                    width: double.infinity,
                    height: 52,
                    borderRadius: 12,
                    onPressed:
                        code.isEmpty ? null : () => onCreateRoom?.call(code),
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
