import 'package:fairnestui/components/MainButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    this.onLogout,
  });

  /// Optional: pass a callback to clear tokens, navigate to login, etc.
  final VoidCallback? onLogout;

  TextStyle get _titleStyle => const TextStyle(
        fontFamily: 'Krub',
        fontWeight: FontWeight.w700,
        color: Colors.black,
      );

  TextStyle get _sectionTitleStyle => const TextStyle(
        fontFamily: 'Krub',
        fontWeight: FontWeight.w600,
        fontSize: 16,
      );

  TextStyle get _bodyStyle => const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        height: 1.35,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: Text('Settings', style: _titleStyle),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          // Privacy & Policy
          _SettingsCard(
            leading: const Icon(Icons.lock, color: Colors.black87),
            title: 'Privacy & Policy',
            titleStyle: _sectionTitleStyle,
            child: _BulletedSection(
              style: _bodyStyle,
              items: const [
                'What we do: FairNest helps with expense management, chore rotation, house rules, and roommate compatibility tracking to reduce conflicts and improve transparency.',
                'Data handling: user accounts and room data are stored securely; only necessary data for features is collected (e.g., tasks, expenses, members).',
                'Security: authentication and authorization via tokens; passwords are hashed using strong algorithms; requests are served by a hardened backend & reverse proxy.',
                'Your control: you can edit or remove house rules, tasks, and expense entries you created, and leave rooms if permitted by room settings.',
              ],
            ),
          ),

          // Help & Support
          _SettingsCard(
            leading: const Icon(Icons.headset, color: Colors.black87),
            title: 'Help & Support',
            titleStyle: _sectionTitleStyle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Common topics',
                    style: _bodyStyle.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                _Bullet(
                    text:
                        'How to split expenses (evenly vs custom) and settle balances.',
                    style: _bodyStyle),
                _Bullet(
                    text:
                        'Setting chore recurrence & auto-rotate for fair distribution.',
                    style: _bodyStyle),
                _Bullet(
                    text: 'Managing house rules and reminders for roommates.',
                    style: _bodyStyle),
                _Bullet(
                    text:
                        'Understanding compatibility insights & improving scores.',
                    style: _bodyStyle),
                const SizedBox(height: 10),
                Text('Contact',
                    style: _bodyStyle.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  'If you run into issues, send logs/screenshots and your app version. '
                  'Support channel can help with account access, room membership, and data corrections.',
                  style: _bodyStyle,
                ),
              ],
            ),
          ),

          // About
          _SettingsCard(
            leading: const Icon(CupertinoIcons.question_circle,
                color: Colors.black87),
            title: 'About',
            titleStyle: _sectionTitleStyle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FairNest',
                    style: _bodyStyle.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  'A smart roommate management system that unifies expense tracking, chore management with auto-rotation, '
                  'house-rule reminders, and compatibility insights—built to promote fairness and reduce conflict in shared living.',
                  style: _bodyStyle,
                ),
                const SizedBox(height: 10),
                Text('Core features',
                    style: _bodyStyle.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                _Bullet(
                    text:
                        'Expense Management: log shared costs (rent, utilities, groceries) with customizable splits.',
                    style: _bodyStyle),
                _Bullet(
                    text:
                        'Chore Manager: recurring tasks with fair auto-rotation and reminders.',
                    style: _bodyStyle),
                _Bullet(
                    text:
                        'House Rules: visible, editable agreements to improve communication.',
                    style: _bodyStyle),
                _Bullet(
                    text:
                        'Compatibility: behavior/feedback-driven insights to support harmony.',
                    style: _bodyStyle),
                const SizedBox(height: 10),
                Text('Tech stack (high level)',
                    style: _bodyStyle.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                _Bullet(
                    text: 'Frontend: Flutter (mobile). Networking via Dio.',
                    style: _bodyStyle),
                _Bullet(
                    text:
                        'Backend: Go + Fiber, JWT for auth, GORM with PostgreSQL.',
                    style: _bodyStyle),
                _Bullet(
                    text:
                        'Security: strong password hashing, reverse proxy, and containerized deployment.',
                    style: _bodyStyle),
                const SizedBox(height: 10),
                Text('Version',
                    style: _bodyStyle.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('App version: 0.1.0 (dev)  •  Build channel: debug',
                    style: _bodyStyle),
              ],
            ),
          ),

          const SizedBox(height: 16),
          // Logout button
          MainButton(
            text: 'Log Out',
            onPressed: onLogout ??
                () {}, // replace with your auth sign-out + navigation
            backgroundColor: const Color(0xFFC34C04),
            textColor: Colors.white,
            width: double.infinity,
            height: 56,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.leading,
    required this.title,
    required this.titleStyle,
    required this.child,
  });

  final Widget leading;
  final String title;
  final TextStyle titleStyle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: leading,
        title: Text(title, style: titleStyle),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [child],
      ),
    );
  }
}

class _BulletedSection extends StatelessWidget {
  const _BulletedSection({required this.items, required this.style});
  final List<String> items;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((t) => _Bullet(text: t, style: style)).toList(),
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text, required this.style});
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}
