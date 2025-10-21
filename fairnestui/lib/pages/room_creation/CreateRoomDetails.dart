import 'package:fairnestui/pages/room_creation/CreateLivingSetup.dart';
import 'package:fairnestui/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';

// NEW: Provider + controller
import 'package:provider/provider.dart';
import 'package:fairnestui/pages/room_creation/room_creation_controller.dart';

class CreateRoomDetails extends StatefulWidget {
  const CreateRoomDetails({super.key, this.onSubmit});

  final void Function(CreateRoomData data)? onSubmit;

  @override
  State<CreateRoomDetails> createState() => _CreateRoomDetailsState();
}

class _CreateRoomDetailsState extends State<CreateRoomDetails> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _roommatesCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  GroupType _type = GroupType.private;

  @override
  void initState() {
    super.initState();
    // Prefill from controller if user navigated back
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = context.read<RoomCreationController>();
      if (c.roomName != null) _nameCtrl.text = c.roomName!;
      if (c.roommateCount != null && c.roommateCount! > 0) {
        _roommatesCtrl.text = c.roommateCount!.toString();
      }
      if (c.roomDescription != null) _descCtrl.text = c.roomDescription!;
      if (c.groupType != null) _type = c.groupType!;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roommatesCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _onNext() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final data = CreateRoomData(
      name: _nameCtrl.text.trim(),
      type: _type,
      roommateCount: int.tryParse(_roommatesCtrl.text.trim()) ?? 0,
      description: _descCtrl.text.trim(),
    );

    // Optional external callback (kept for reusability)
    widget.onSubmit?.call(data);

    // Save to controller (single source of truth for the flow)
    context.read<RoomCreationController>().setDetails(data);

    // Go to the next step
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateLivingSetup()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppHeader(
            title: 'Create a Room',
            showBack: true,
            rightType: AppHeaderRightType.none,
          ),

          // Form body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section title
                    Text(
                      'Room Details',
                      style: AppFonts.heading1.copyWith(
                        color: const Color(0xFF645A80),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Room Name
                    const _FieldLabel('Room Name'),
                    const SizedBox(height: 8),
                    _Input(
                      controller: _nameCtrl,
                      hint: 'Your group name',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Room name is required'
                          : null,
                    ),
                    const SizedBox(height: 18),

                    // Group Type
                    const _FieldLabel('Group Type'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _SegmentButton(
                            text: 'Private',
                            selected: _type == GroupType.private,
                            onTap: () =>
                                setState(() => _type = GroupType.private),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SegmentButton(
                            text: 'Public',
                            selected: _type == GroupType.public,
                            onTap: () =>
                                setState(() => _type = GroupType.public),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Number of Roommates
                    const _FieldLabel('Number of Roommates'),
                    const SizedBox(height: 8),
                    _Input(
                      controller: _roommatesCtrl,
                      hint: 'Enter number',
                      keyboardType: TextInputType.number,
                      // Keep input digits only and avoid leading zeros if you want
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter a number';
                        }
                        final n = int.tryParse(v);
                        if (n == null || n <= 0) {
                          return 'Enter a valid positive number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Description
                    const _FieldLabel('Room Description'),
                    const SizedBox(height: 8),
                    _Input(
                      controller: _descCtrl,
                      hint: 'Enter room description (optional)',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    // Next button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent, // gold-ish
                          foregroundColor: Colors.black,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _onNext,
                        child: Text(
                          'Next',
                          style:
                              AppFonts.heading3.copyWith(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== Models & Enums ===================== */

/* ===================== UI Bits ===================== */

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.bottom = 0});
  final String text;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Krub',
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.hint,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: const TextStyle(
        fontFamily: 'Krub',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Krub',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
        filled: true,
        fillColor: const Color(0xFFECE9E6),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF645A80), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF645A80), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF645A80), width: 1.6),
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFF645A80);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEDE8F4) : const Color(0xFFECE9E6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Krub',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: selected ? const Color(0xFF645A80) : const Color(0xFF6F6A68),
          ),
        ),
      ),
    );
  }
}
