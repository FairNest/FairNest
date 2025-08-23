import 'package:fairnestui/auth/SignUpPage.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/components/MainButton.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.onTapRegister, this.onSubmit});

  final VoidCallback? onTapRegister;
  final void Function(String email, String password)? onSubmit;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative pink blobs
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
                const SizedBox(height: 60),
                Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // Email
                          const _FieldLabel('Email'),
                          const SizedBox(height: 12),
                          _Input(
                            controller: _emailCtrl,
                            hint: 'Your Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Email is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password
                          const _FieldLabel('Password'),
                          const SizedBox(height: 12),
                          _Input(
                            controller: _pwCtrl,
                            hint: '••••••••••',
                            obscureText: _obscure,
                            suffix: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password is required';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 40),

                          // MainButton (reusable)
                          MainButton(
                            text: 'Log In',
                            backgroundColor: const Color(0xFFE8B86D),
                            textColor: const Color(0xFF000000),
                            width: double.infinity,
                            height: 52,
                            borderRadius: 12,
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                widget.onSubmit?.call(
                                  _emailCtrl.text.trim(),
                                  _pwCtrl.text,
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 20),

                          // Register link
                          Center(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color: AppColors.textDark,
                                    fontSize: 12,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignUpPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Register here',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondary,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w600,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ------------ Helper widgets ------------ */

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textDark,
        fontWeight: FontWeight.w600,
        fontSize: 13,
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
      style: const TextStyle(color: AppColors.textDark, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
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
