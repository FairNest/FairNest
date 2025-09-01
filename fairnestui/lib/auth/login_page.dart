import 'package:fairnestui/auth/SignUpPage.dart';
import 'package:fairnestui/pages/FindRoommate/GroupCheckPage.dart';
import 'package:fairnestui/services/user_service.dart';
import 'package:fairnestui/shell/app_shell.dart' show AppShell;
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/components/MainButton.dart';
import 'package:fairnestui/services/auth_service.dart';
import 'package:fairnestui/services/storage_service.dart';
import 'package:fairnestui/services/api_client.dart'; // <-- NEW

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
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      // 1) Login
      final result = await AuthService.login(
        email: _emailCtrl.text.trim(),
        password: _pwCtrl.text,
      );

      // 2) Persist auth
      await StorageService.saveToken(result['token']);
      await StorageService.saveUserData({
        'user_id': result['user_id'],
        'email': result['email'],
      });

      // 3) Extract user id (from JWT or whatever UserService implements)
      final userId = await UserService.getUserIdFromToken();
      if (mounted) {
        debugPrint("User ID from token: $userId");
      }

      // 4) Check whether the user already has a room
      bool hasRoom = false;
      try {
        final resp = await ApiClient.get('/CheckUserHasRoomOrNot/$userId');
        // Expecting: { "has_room": true/false }
        final data = resp.data;
        if (data is Map && data.containsKey('has_room')) {
          final v = data['has_room'];
          hasRoom = v == true || v == 'true' || v == 1;
        }
      } catch (e) {
        // If the check fails, default to onboarding (GroupCheckPage)
        debugPrint('⚠️ has_room check failed: $e');
      }

      // 5) Optional external callback
      widget.onSubmit?.call(_emailCtrl.text.trim(), _pwCtrl.text);

      // 6) Navigate based on hasRoom
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => hasRoom ? const AppShell() : const GroupCheckPage(),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(hasRoom ? 'Welcome back!' : 'Let’s set up your room.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                'assets/images/log-in-bg.png',
                fit: BoxFit.fill,
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 210),
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    "Log In",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF645A80),
                      fontSize: 22,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
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
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(v.trim())) {
                                return 'Please enter a valid email';
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

                          const SizedBox(height: 45),

                          // Login Button
                          MainButton(
                            text: _isLoading ? 'Logging in...' : 'Log In',
                            backgroundColor: const Color(0xFFE8B86D),
                            textColor: const Color(0xFF000000),
                            width: double.infinity,
                            height: 52,
                            borderRadius: 12,
                            onPressed: _isLoading ? null : _handleLogin,
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
                                      fontSize: 13,
                                      color: AppColors.textOrange,
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

            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFE8B86D)),
                  ),
                ),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        suffixIcon: suffix,
      ),
    );
  }
}
