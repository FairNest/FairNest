// lib/profile/complete_profile_page.dart
import 'package:flutter/material.dart';
import 'package:fairnestui/widgets/LifestyleOverview.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/components/MainButton.dart';

// ⬇️ If your file is named signup_page.dart, change this import accordingly.
import 'package:fairnestui/auth/SignUpPage.dart' show SignUpData;

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({
    super.key,
    required this.signUpData, // from SignUp page
    required this.quizAnswers, // map: questionIndex (1..12) -> score (1..5)
    this.onSubmit,
    this.initialUsername = '',
    this.initialBio = '',
    this.avatarChoices = const [
      'assets/images/bird.png',
      'assets/images/char.png',
      'assets/images/pikachu.png',
      'assets/images/poke.png',
    ],
    this.metrics = const [
      LifestyleMetric(kind: LifestyleMetricKind.tidiness, value: 0.82),
      LifestyleMetric(kind: LifestyleMetricKind.noiseActivity, value: 0.45),
      LifestyleMetric(kind: LifestyleMetricKind.schedule, value: 0.90),
      LifestyleMetric(kind: LifestyleMetricKind.guestFrequency, value: 0.40),
      LifestyleMetric(kind: LifestyleMetricKind.taskStructure, value: 0.95),
      LifestyleMetric(kind: LifestyleMetricKind.moneyAttitude, value: 0.93),
    ],
  });

  final SignUpData signUpData;
  final Map<int, int> quizAnswers;

  final void Function(CompleteProfileData data)? onSubmit;
  final String initialUsername;
  final String initialBio;
  final List<String> avatarChoices;
  final List<LifestyleMetric> metrics;

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  int? _selectedAvatarIndex; // 0..(avatarChoices.length - 1)

  @override
  void initState() {
    super.initState();
    _usernameCtrl.text = widget.initialUsername;
    _bioCtrl.text = widget.initialBio;
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedAvatarIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a profile picture')),
      );
      return;
    }

    final data = CompleteProfileData(
      username: _usernameCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      avatarAsset: widget.avatarChoices[_selectedAvatarIndex!],
      metrics: widget.metrics,
      // If you want, you can also copy signUpData/quizAnswers into this DTO.
    );

    // Debug: see everything you're about to submit
    debugPrint('SignUpData: '
        '${widget.signUpData.name}, ${widget.signUpData.email}, '
        '${widget.signUpData.nationalIdOrPassport}, ${widget.signUpData.phoneNumber}');
    debugPrint('Quiz answers (1..5): ${widget.quizAnswers}');
    debugPrint(
        'CompleteProfileData: ${data.username}, ${data.bio}, ${data.avatarAsset}');

    widget.onSubmit?.call(data);

    // Success toast (and optionally navigate)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile completed!')),
    );
    // Navigator.pop(context); // or navigate to your app home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // same background as SignUp
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative blobs — match SignUp vibe
            const _Blob(
              color: AppColors.pinkSoft,
              width: 160,
              height: 100,
              top: 20,
              left: -20,
              angle: -0.08,
            ),
            const _Blob(
              color: AppColors.pinkSoft,
              width: 150,
              height: 90,
              top: 80,
              right: -24,
              angle: 0.15,
            ),

            Column(
              children: [
                const SizedBox(height: 24),
                Text(
                  'Complete Your\nProfile',
                  textAlign: TextAlign.center,
                  style: AppFonts.heading1.copyWith(
                    color: const Color(0xFF645A80),
                  ),
                ),
                const SizedBox(height: 16),

                // Pink rounded container like SignUp
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                    decoration: const BoxDecoration(
                      color: AppColors.secondary, // pink
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(36),
                        topRight: Radius.circular(36),
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
                            // LifestyleOverview inside small card-like container
                            Text(
                              'Lifestyle Overview',
                              style: AppFonts.heading3.copyWith(
                                color: const Color(0xFF4A3F5C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFECE9E6),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF645A80),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: LifestyleOverview(
                                metrics: widget.metrics,
                                barHeight: 10,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Choose avatar
                            const _FieldLabel('Choose Your Profile Picture'),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                  widget.avatarChoices.length, (i) {
                                final isSelected = _selectedAvatarIndex == i;
                                return _AvatarChoice(
                                  asset: widget.avatarChoices[i],
                                  selected: isSelected,
                                  onTap: () =>
                                      setState(() => _selectedAvatarIndex = i),
                                );
                              }),
                            ),

                            const SizedBox(height: 18),

                            // Username
                            const _FieldLabel('Enter Your Username'),
                            const SizedBox(height: 10),
                            _Input(
                              controller: _usernameCtrl,
                              hint: 'Your Username',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Username is required'
                                  : null,
                            ),

                            const SizedBox(height: 18),

                            // Bio
                            const _FieldLabel('Tell us about yourself'),
                            const SizedBox(height: 10),
                            _Input(
                              controller: _bioCtrl,
                              hint: 'What do you like?',
                              maxLines: 3,
                            ),

                            const SizedBox(height: 24),

                            // Main button (AppColors.primary)
                            MainButton(
                              text: "Let's Get Started!",
                              backgroundColor: AppColors.primary,
                              textColor: const Color.fromARGB(255, 0, 0, 0),
                              width: double.infinity,
                              height: 52,
                              borderRadius: 12,
                              onPressed: _submit,
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

/* ===================== Data ===================== */

class CompleteProfileData {
  final String username;
  final String bio;
  final String avatarAsset;
  final List<LifestyleMetric> metrics;

  CompleteProfileData({
    required this.username,
    required this.bio,
    required this.avatarAsset,
    required this.metrics,
  });
}

/* ===================== Small widgets ===================== */

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
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(
        fontFamily: 'Krub',
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: AppColors.textDark,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Krub',
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Color(0xFF888888),
        ),
        filled: true,
        fillColor: const Color(0xFFEFECE9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _AvatarChoice extends StatelessWidget {
  const _AvatarChoice({
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  final String asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE0DFDC),
          border: Border.all(
            color: selected ? const Color(0xFF645A80) : Colors.transparent,
            width: selected ? 3 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.person, size: 28, color: Colors.black26),
        ),
      ),
    );
  }
}

/* =============== Decorative blob (same flavor as SignUp) =============== */

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
