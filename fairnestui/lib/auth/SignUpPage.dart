// signup_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/components/MainButton.dart';

// adjust import to your LoginPage location
import 'package:fairnestui/auth/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    super.key,
    this.onSubmit,
  });

  final void Function(SignUpData data)? onSubmit;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();

  bool _obscure = true;
  bool _agree = false;

  File? _userPhoto;
  File? _verificationPhoto;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _emailCtrl.dispose();
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _phoneCtrl.dispose();
    _bankCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool forVerification}) async {
    final choice = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text(
                'Take a photo',
                style: TextStyle(
                  fontFamily: 'Krub',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              onTap: () => Navigator.pop(_, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text(
                'Choose from gallery',
                style: TextStyle(
                  fontFamily: 'Krub',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              onTap: () => Navigator.pop(_, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (choice == null) return;

    final xFile = await _picker.pickImage(source: choice, imageQuality: 85);
    if (xFile == null) return;

    setState(() {
      if (forVerification) {
        _verificationPhoto = File(xFile.path);
      } else {
        _userPhoto = File(xFile.path);
      }
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please accept the terms to continue.',
            style: TextStyle(
              fontFamily: 'Krub',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      );
      return;
    }
    widget.onSubmit?.call(
      SignUpData(
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text,
        email: _emailCtrl.text.trim(),
        firstName: _firstCtrl.text.trim(),
        lastName: _lastCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        bankAccountNumber: _bankCtrl.text.trim(),
        userPicture: _userPhoto,
        verificationPicture: _verificationPhoto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            const _Blob(
              color: AppColors.pinkSoft,
              width: 140,
              height: 80,
              top: 40,
              right: -20,
              angle: -0.1,
            ),
            const _Blob(
              color: AppColors.pinkSoft,
              width: 120,
              height: 100,
              top: 120,
              left: -30,
              angle: 0.2,
            ),
            Column(
              children: [
                const SizedBox(height: 36),
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontFamily: 'Krub',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Username'),
                            const SizedBox(height: 10),
                            _Input(
                              controller: _usernameCtrl,
                              hint: 'Your username',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Username is required'
                                  : null,
                            ),
                            const SizedBox(height: 18),

                            const _FieldLabel('Password'),
                            const SizedBox(height: 10),
                            _Input(
                              controller: _passwordCtrl,
                              hint: '••••••••••',
                              obscureText: _obscure,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[700],
                                  size: 22,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Password is required'
                                  : null,
                            ),
                            const SizedBox(height: 18),

                            const _FieldLabel('Email'),
                            const SizedBox(height: 10),
                            _Input(
                              controller: _emailCtrl,
                              hint: 'Your email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Email is required'
                                  : null,
                            ),
                            const SizedBox(height: 18),

                            const _FieldLabel('First Name'),
                            const SizedBox(height: 10),
                            _Input(
                              controller: _firstCtrl,
                              hint: 'Your first name',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'First name is required'
                                  : null,
                            ),
                            const SizedBox(height: 18),

                            const _FieldLabel('Last Name'),
                            const SizedBox(height: 10),
                            _Input(
                              controller: _lastCtrl,
                              hint: 'Your last name',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Last name is required'
                                  : null,
                            ),
                            const SizedBox(height: 18),

                            const _FieldLabel('Phone Number'),
                            const SizedBox(height: 10),
                            _Input(
                              controller: _phoneCtrl,
                              hint: 'e.g. +66 812345678',
                              keyboardType: TextInputType.phone,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Phone number is required'
                                  : null,
                            ),
                            const SizedBox(height: 18),

                            const _FieldLabel('User Picture'),
                            const SizedBox(height: 10),
                            _ImagePickerTile(
                              file: _userPhoto,
                              onTap: () => _pickImage(forVerification: false),
                              placeholder: 'Tap to take/upload photo',
                            ),
                            const SizedBox(height: 18),

                            const _FieldLabel('Bank Account Number'),
                            const SizedBox(height: 10),
                            _Input(
                              controller: _bankCtrl,
                              hint: 'Your bank account number',
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Bank account number is required'
                                  : null,
                            ),
                            const SizedBox(height: 18),

                            const _FieldLabel('User Verification Picture'),
                            const SizedBox(height: 10),
                            _ImagePickerTile(
                              file: _verificationPhoto,
                              onTap: () => _pickImage(forVerification: true),
                              placeholder: 'Selfie of yourself and ID card',
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Checkbox(
                                  value: _agree,
                                  onChanged: (v) =>
                                      setState(() => _agree = v ?? false),
                                  side: const BorderSide(
                                    color: AppColors.textDark,
                                    width: 1.2,
                                  ),
                                ),
                                const Expanded(
                                  child: Text(
                                    'I accept the terms and privacy policy',
                                    style: TextStyle(
                                      fontFamily: 'Krub',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            MainButton(
                              text: 'Next',
                              backgroundColor: const Color(0xFFBDB0E1),
                              textColor: const Color(0xFF000000),
                              width: double.infinity,
                              height: 52,
                              borderRadius: 12,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 14),

                            // Bottom row (exception)
                            Center(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Log in here',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Krub',
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFC34C04),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpData {
  final String username;
  final String password;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String bankAccountNumber;
  final File? userPicture;
  final File? verificationPicture;

  SignUpData({
    required this.username,
    required this.password,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.bankAccountNumber,
    this.userPicture,
    this.verificationPicture,
  });
}

/* ------------ Helpers ------------ */

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Krub',
        color: AppColors.textDark,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'Krub',
        color: AppColors.textDark,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Krub',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color(0xFF888888),
        ),
        filled: true,
        fillColor: Color(0xFFEFECE9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffix,
      ),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  const _ImagePickerTile({
    required this.file,
    required this.onTap,
    required this.placeholder,
  });

  final File? file;
  final VoidCallback onTap;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Color(0xFFEFECE9),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: file == null
                  ? const Icon(Icons.camera_alt_rounded,
                      size: 22, color: Colors.black54)
                  : Image.file(file!, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                file == null ? placeholder : 'Photo selected',
                style: const TextStyle(
                  fontFamily: 'Krub',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF555555),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 22, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.color,
    required this.width,
    required this.height,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.angle = 0,
  });

  final Color color;
  final double width;
  final double height;
  final double? top, left, right, bottom;
  final double angle;

  @override
  Widget build(BuildContext context) {
    final child = Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(60),
        ),
      ),
    );

    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: child,
    );
  }
}
