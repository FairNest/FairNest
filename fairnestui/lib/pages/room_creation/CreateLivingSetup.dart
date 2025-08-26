// create_living_setup.dart
import 'package:fairnestui/components/MainButton.dart';
import 'package:fairnestui/pages/room_creation/RoommateAgreement.dart';
import 'package:fairnestui/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';

class CreateLivingSetup extends StatefulWidget {
  const CreateLivingSetup({super.key, this.onSubmit});

  final void Function(CreateLivingSetupData data)? onSubmit;

  @override
  State<CreateLivingSetup> createState() => _CreateLivingSetupState();
}

class _CreateLivingSetupState extends State<CreateLivingSetup> {
  final _formKey = GlobalKey<FormState>();

  final _spaceNameCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  final _electricCtrl = TextEditingController();
  final _waterCtrl = TextEditingController();
  final _otherCtrl = TextEditingController();

  @override
  void dispose() {
    _spaceNameCtrl.dispose();
    _rentCtrl.dispose();
    _electricCtrl.dispose();
    _waterCtrl.dispose();
    _otherCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    widget.onSubmit?.call(
      CreateLivingSetupData(
        livingSpaceName: _spaceNameCtrl.text.trim(),
        rentCost: double.tryParse(_rentCtrl.text.trim()) ?? 0,
        electricityCostPerUnit: double.tryParse(_electricCtrl.text.trim()) ?? 0,
        waterCostPerUnit: double.tryParse(_waterCtrl.text.trim()) ?? 0,
        otherUtilityDetails: _otherCtrl.text.trim(),
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
          const AppHeader(
            title: 'Create a Room',
            showBack: true,
            rightType: AppHeaderRightType.none,
          ),

          // Body
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
                      'Living Space Setup',
                      style: AppFonts.heading1
                          .copyWith(color: const Color(0xFF645A80)),
                    ),
                    const SizedBox(height: 18),

                    // Living Space Name
                    const _FieldLabel('Living Space Name'),
                    const SizedBox(height: 8),
                    _Input(
                      controller: _spaceNameCtrl,
                      hint: 'Your Apartment/Dorm name',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please enter a name'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Rent Cost
                    const _FieldLabel('Rent Cost'),
                    const SizedBox(height: 8),
                    _Input(
                      controller: _rentCtrl,
                      keyboardType: TextInputType.number,
                      hint: 'Enter the Rent Cost',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Please enter rent cost';
                        final d = double.tryParse(v);
                        if (d == null || d < 0) return 'Enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Electricity Cost per Unit
                    const _FieldLabel('Electricity Cost per Unit'),
                    const SizedBox(height: 8),
                    _Input(
                      controller: _electricCtrl,
                      keyboardType: TextInputType.number,
                      hint: 'Enter the Electricity Cost',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter electricity cost per unit';
                        }
                        final d = double.tryParse(v);
                        if (d == null || d < 0) return 'Enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Water Cost per Unit
                    const _FieldLabel('Water Cost per Unit'),
                    const SizedBox(height: 8),
                    _Input(
                      controller: _waterCtrl,
                      keyboardType: TextInputType.number,
                      hint: 'Enter the Water Cost',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter water cost per unit';
                        }
                        final d = double.tryParse(v);
                        if (d == null || d < 0) return 'Enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Other Utility Details (optional)
                    const _FieldLabel('Other Utility Details'),
                    const SizedBox(height: 8),
                    _Input(
                      controller: _otherCtrl,
                      hint:
                          'Enter Other Details e.g. Wifi cost, Pet fee, Washing Machines (Optional)',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Next
// Next
                    MainButton(
                      text: 'Next',
                      backgroundColor:
                          const Color(0xFFD8A85B), // orange-ish gold
                      textColor: Colors.black,
                      width: double.infinity,
                      height: 52,
                      borderRadius: 12,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RoommateAgreementPage()),
                        );
                      },
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

/* ========= Data model ========= */

class CreateLivingSetupData {
  final String livingSpaceName;
  final double rentCost;
  final double electricityCostPerUnit;
  final double waterCostPerUnit;
  final String otherUtilityDetails;

  CreateLivingSetupData({
    required this.livingSpaceName,
    required this.rentCost,
    required this.electricityCostPerUnit,
    required this.waterCostPerUnit,
    required this.otherUtilityDetails,
  });
}

/* ========= UI Bits ========= */

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Krub',
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: Colors.black,
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
