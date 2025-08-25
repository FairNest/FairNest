import 'package:fairnestui/pages/room_creation/CreateLivingSetup.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';

class CreateRoomdetails extends StatefulWidget {
  const CreateRoomdetails({super.key, this.onSubmit});

  final void Function(CreateRoomData data)? onSubmit;

  @override
  State<CreateRoomdetails> createState() => _CreateRoomdetailsState();
}

class _CreateRoomdetailsState extends State<CreateRoomdetails> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _roommatesCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  GroupType _type = GroupType.private;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roommatesCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final count = int.tryParse(_roommatesCtrl.text.trim()) ?? 0;

    widget.onSubmit?.call(
      CreateRoomData(
        name: _nameCtrl.text.trim(),
        type: _type,
        roommateCount: count,
        description: _descCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header (purple bar with back + centered title)
          Container(
            width: double.infinity,
            height: top + 69,
            padding: EdgeInsets.only(top: top),
            color: AppColors.primary,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // back
                Positioned(
                  left: 12,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF645A80), size: 26),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                // title
                Text(
                  'Create a Room',
                  style: AppFonts.heading1
                      .copyWith(color: const Color(0xFF645A80)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter a number';
                        }
                        final n = int.tryParse(v);
                        if (n == null || n <= 0)
                          return 'Enter a valid positive number';
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
                          backgroundColor:
                              AppColors.accent, // gold-ish like mock
                          foregroundColor: Colors.black,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateLivingSetup()),
                          );
                        },
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

enum GroupType { private, public }

class CreateRoomData {
  final String name;
  final GroupType type;
  final int roommateCount;
  final String description;

  CreateRoomData({
    required this.name,
    required this.type,
    required this.roommateCount,
    required this.description,
  });
}

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
  });

  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
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
    final border = const Color(0xFF645A80);

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
