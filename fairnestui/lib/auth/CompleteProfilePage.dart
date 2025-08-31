import 'package:fairnestui/auth/login_page.dart';
import 'package:fairnestui/pages/FindRoommate/GroupCheckPage.dart';
import 'package:fairnestui/pages/FindRoommate/GroupHomePage.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:fairnestui/widgets/LifestyleOverview.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';
import 'package:fairnestui/components/MainButton.dart';

// Keep your existing import style to match your project:
import 'package:fairnestui/auth/SignUpPage.dart' show SignUpData;

// ✅ API client
import 'package:fairnestui/services/api_client.dart';

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

  bool _submitting = false;

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
    double avg(List<double> xs) =>
        xs.isEmpty ? 0 : xs.reduce((p, c) => p + c) / xs.length;

    double g(int k) => (a[k] ?? 0).toDouble();

    double norm(double v) => (v / 5.0).clamp(0.0, 1.0);

    return [
      LifestyleMetric(
        kind: LifestyleMetricKind.tidiness,
        value: norm(avg([g(1), g(2)])),
      ),
      LifestyleMetric(
        kind: LifestyleMetricKind.noiseActivity,
        value: norm(avg([g(3), g(4)])),
      ),
      LifestyleMetric(
        kind: LifestyleMetricKind.schedule,
        value: norm(avg([g(5), g(6)])),
      ),
      LifestyleMetric(
        kind: LifestyleMetricKind.guestFrequency,
        value: norm(avg([g(7), g(8)])),
      ),
      LifestyleMetric(
        kind: LifestyleMetricKind.taskStructure,
        value: norm(avg([g(9), g(10)])),
      ),
      LifestyleMetric(
        kind: LifestyleMetricKind.moneyAttitude,
        value: norm(avg([g(11), g(12)])),
      ),
    ];
  }

  // Map asset (bird.png, etc.) → CDN
  String _avatarAssetToCdn(String assetPath) {
    final file = assetPath.split('/').last.toLowerCase();
    const base = 'https://minio.bocchikitsunei.com/fairnest';
    switch (file) {
      case 'bird.png':
        return '$base/bird.png';
      case 'char.png':
        return '$base/char.png';
      case 'poke.png':
        return '$base/poke.png';
      case 'pikachu.png':
        return '$base/pikachu.png';
      default:
        return '$base/$file';
    }
  }

  ({String first, String last}) _splitName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return (first: '', last: '');
    if (parts.length == 1) return (first: parts.first, last: '');
    return (first: parts.first, last: parts.sublist(1).join(' '));
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedAvatarIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a profile picture')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      // Ensure client is ready
      ApiClient.initialize();

      final username = _usernameCtrl.text.trim();
      final bio = _bioCtrl.text.trim();
      final avatarAsset = widget.avatarChoices[_selectedAvatarIndex!];
      final userPictureUrl = _avatarAssetToCdn(avatarAsset);

      final (first: firstname, last: lastname) =
          _splitName(widget.signUpData.name);

      // Build multipart/form-data exactly as backend expects.
      // We send empty strings "" for the three fields you requested,
      // and "true" string for the boolean (Go can parse it to bool).
      final form = FormData.fromMap({
        "username": username,
        "password": widget.signUpData.password,
        "email": widget.signUpData.email,
        "firstname": firstname,
        "lastname": lastname,
        "phone_number": widget.signUpData.phoneNumber,
        "user_picture": userPictureUrl,
        "user_about_me": bio,

        // Forced empties / boolean
        "bank_account_number": "1234567890",
        "user_verification_picture": "",
        "user_identity_document_number": "1234567891231",
        "user_identity_document_type": "true",

        // Raw answers (1..5)
        "q1": widget.quizAnswers[1],
        "q2": widget.quizAnswers[2],
        "q3": widget.quizAnswers[3],
        "q4": widget.quizAnswers[4],
        "q5": widget.quizAnswers[5],
        "q6": widget.quizAnswers[6],
        "q7": widget.quizAnswers[7],
        "q8": widget.quizAnswers[8],
        "q9": widget.quizAnswers[9],
        "q10": widget.quizAnswers[10],
        "q11": widget.quizAnswers[11],
        "q12": widget.quizAnswers[12],

        // Metrics (0..1). Numbers are fine in FormData; Dio will encode correctly.
        "user_tidiness": _metrics
            .firstWhere((m) => m.kind == LifestyleMetricKind.tidiness)
            .value,
        "user_noise_activity": _metrics
            .firstWhere((m) => m.kind == LifestyleMetricKind.noiseActivity)
            .value,
        "user_schedule": _metrics
            .firstWhere((m) => m.kind == LifestyleMetricKind.schedule)
            .value,
        "user_guest_frequency": _metrics
            .firstWhere((m) => m.kind == LifestyleMetricKind.guestFrequency)
            .value,
        "user_task_structure": _metrics
            .firstWhere((m) => m.kind == LifestyleMetricKind.taskStructure)
            .value,
        "user_money_attitude": _metrics
            .firstWhere((m) => m.kind == LifestyleMetricKind.moneyAttitude)
            .value,
      });

      final resp = await ApiClient.post(
        '/Register',
        data: form,
        // Options not needed; Dio sets multipart headers for FormData.
      );

      // If your API returns a token, you can store it here:
      // await StorageService.setToken(resp.data['token']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile completed & registered!')),
      );

      // Optional navigation:
      // if (!mounted) return;
      // Navigator.pushReplacementNamed(context, '/home');

      // Also call the original onSubmit (for local state/analytics)
      widget.onSubmit?.call(
        CompleteProfileData(
          username: username,
          bio: bio,
          avatarAsset: avatarAsset,
          metrics: _metrics,
        ),
      );

      if (resp.statusCode != null &&
          resp.statusCode! >= 200 &&
          resp.statusCode! < 300) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Register failed: $msg')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Register failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
                              text: _submitting
                                  ? "Submitting..."
                                  : "Let's Get Started!",
                              backgroundColor: AppColors.primary,
                              textColor: const Color.fromARGB(255, 0, 0, 0),
                              width: double.infinity,
                              height: 52,
                              borderRadius: 12,
                              onPressed: _submitting ? null : _submit,
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
