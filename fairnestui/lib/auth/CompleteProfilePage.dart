// lib/profile/complete_profile_page.dart
import 'package:flutter/material.dart';
import 'package:fairnestui/widgets/LifestyleOverview.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/components/MainButton.dart';
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
    this.metrics, // ⬅️ optional: if provided by the quiz page we use it directly
  });

  final SignUpData signUpData;
  final Map<int, int> quizAnswers;

  final void Function(CompleteProfileData data)? onSubmit;
  final String initialUsername;
  final String initialBio;
  final List<String> avatarChoices;
  final List<LifestyleMetric>? metrics; // ⬅️ may come from LifestyleQuizPage

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  int? _selectedAvatarIndex; // 0..(avatarChoices.length - 1)

  // The metrics actually rendered on this page.
  late final List<LifestyleMetric> _metrics;

  @override
  void initState() {
    super.initState();
    _usernameCtrl.text = widget.initialUsername;
    _bioCtrl.text = widget.initialBio;

    // Prefer incoming metrics from the quiz page; otherwise compute from answers.
    _metrics = widget.metrics ?? _computeFromAnswers(widget.quizAnswers);

    debugPrint('SignUpData: '
        '${widget.signUpData.name}, ${widget.signUpData.email}, '
        '${widget.signUpData.nationalIdOrPassport}, ${widget.signUpData.phoneNumber}');
    debugPrint('Quiz answers (1..5): ${widget.quizAnswers}');
    debugPrint('Computed/received metrics: $_metrics');
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  // === Mapping Q1..Q12 (1..5) -> 6 Lifestyle metrics (0..1) ===
  List<LifestyleMetric> _computeFromAnswers(Map<int, int> a) {
    // All questions must exist; if you want extra safety add defaults.
    double _avg(List<int> xs) =>
        xs.isEmpty ? 0 : xs.reduce((p, c) => p + c) / xs.length;
    double _norm(double v) => (v / 5.0).clamp(0.0, 1.0);

    return [
      // Tidiness Level: Q1, Q2
      LifestyleMetric(
        kind: LifestyleMetricKind.tidiness,
        value: _norm(_avg([a[1]!, a[2]!])),
      ),
      // Noise & Activity: Q3, Q4
      LifestyleMetric(
        kind: LifestyleMetricKind.noiseActivity,
        value: _norm(_avg([a[3]!, a[4]!])),
      ),
      // Schedule Type: Q5, Q6
      LifestyleMetric(
        kind: LifestyleMetricKind.schedule,
        value: _norm(_avg([a[5]!, a[6]!])),
      ),
      // Guest Frequency: Q7, Q8
      LifestyleMetric(
        kind: LifestyleMetricKind.guestFrequency,
        value: _norm(_avg([a[7]!, a[8]!])),
      ),
      // Task Structure: Q9, Q10
      LifestyleMetric(
        kind: LifestyleMetricKind.taskStructure,
        value: _norm(_avg([a[9]!, a[10]!])),
      ),
      // Money Attitude: Q11, Q12
      LifestyleMetric(
        kind: LifestyleMetricKind.moneyAttitude,
        value: _norm(_avg([a[11]!, a[12]!])),
      ),
    ];
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
      metrics: _metrics, // ⬅️ use actual metrics
    );

    widget.onSubmit?.call(data);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile completed!')),
    );
    // Navigate to your app home if desired
    // Navigator.pop(context);
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
                            // LifestyleOverview inside card
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
                                metrics: _metrics, // ⬅️ real values
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
