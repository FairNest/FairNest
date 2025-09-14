// signup_page.dart
import 'package:fairnestui/auth/LifestyleQuizPage.dart';
import 'package:flutter/material.dart';

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

  // Controllers for the required fields
  final _firstnameCtrl = TextEditingController();
  final _lastnameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();

  bool _obscurePw = true;
  bool _obscureConfirm = true;
  bool _agree = false;

  @override
  void dispose() {
    _firstnameCtrl.dispose();
    _lastnameCtrl.dispose();
    _emailCtrl.dispose();
    _nationalIdCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  // ✅ UPDATED: after validate, navigate to LifestyleQuizPage with data
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

    final data = SignUpData(
      firstname: _firstnameCtrl.text.trim(),
      lastname: _lastnameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      nationalIdOrPassport: _nationalIdCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    // optional callback for analytics / API
    widget.onSubmit?.call(data);

    // 👉 navigate to LifestyleQuizPage, passing the collected data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LifestyleQuizPage(signUpData: data),
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
            Positioned.fill(
                child: Image.asset(
              'assets/images/sign-up-bg.png',
              fit: BoxFit.fill,
            )),
            Column(
              children: [
                const SizedBox(height: 210),
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF645A80),
                        fontSize: 22),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    decoration: const BoxDecoration(
                      color: AppColors.secondary, // pink card
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
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
                            // Name
                            const _FieldLabel('First Name'),
                            const SizedBox(height: 10),
                            _Input(
                              controller: _firstnameCtrl,
                              hint: 'Your First Name',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Name is required'
                                  : null,
                            ),
                            const SizedBox(height: 18),

                            const _FieldLabel('Last Name'),
                            const SizedBox(height: 10),
                            _Input(
                              controller: _lastnameCtrl,
                              hint: 'Your Last Name',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Name is required'
                                  : null,
                            ),
                            const SizedBox(height: 18),

                            // Email
                            const _FieldLabel('Email'),
                            const SizedBox(height: 10),
                            _Input(
                              controller: _emailCtrl,
                              hint: 'Your Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Email is required'
                                  : null,
                            ),
                            const SizedBox(height: 18),

                            // National ID / Passport
                            const _FieldLabel('National ID or Passport Number'),
                            const SizedBox(height: 10),
                            _Input(
                              controller: _nationalIdCtrl,
                              hint: 'Your National ID or Passport No.',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'This field is required'
                                  : null,
                            ),
                            const SizedBox(height: 18),

                            // Phone Number
                            const _FieldLabel('Phone Number'),
                            const SizedBox(height: 10),
                            _Input(
                              controller: _phoneCtrl,
                              hint: 'Your Phone No.',
                              keyboardType: TextInputType.phone,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Phone number is required'
                                  : null,
                            ),
                            const SizedBox(height: 18),

                            // Password
                            const _FieldLabel('Password'),
                            const SizedBox(height: 10),
                            _Input(
                              controller: _passwordCtrl,
                              hint: '••••••••••',
                              obscureText: _obscurePw,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePw
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[700],
                                  size: 22,
                                ),
                                onPressed: () =>
                                    setState(() => _obscurePw = !_obscurePw),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Password is required'
                                  : null,
                            ),
                            const SizedBox(height: 18),

                            // Confirm Password
                            const _FieldLabel('Confirm Password'),
                            const SizedBox(height: 10),
                            _Input(
                              controller: _confirmPwCtrl,
                              hint: '••••••••••',
                              obscureText: _obscureConfirm,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[700],
                                  size: 22,
                                ),
                                onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (v != _passwordCtrl.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Terms
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
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Next button
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

                            // Bottom auth row
                            Center(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      fontSize: 13,
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

/// Data you’ll receive on submit (simplified to match current fields)
class SignUpData {
  final String firstname;
  final String lastname;
  final String email;
  final String nationalIdOrPassport;
  final String phoneNumber;
  final String password;

  SignUpData({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.nationalIdOrPassport,
    required this.phoneNumber,
    required this.password,
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
        fillColor: const Color(0xFFEFECE9),
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
