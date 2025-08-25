// lib/profile/my_profile_page.dart
import 'package:fairnestui/widgets/LifestyleOverview.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';

import 'package:fairnestui/widgets/app_header.dart';
import 'package:fairnestui/components/LavenderBorderedCard.dart';
import 'package:fairnestui/components/MainButton.dart';

// If you put LifestyleOverview elsewhere, adjust the import:

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({
    super.key,
    this.name = 'Max',
    this.avatarAsset = 'assets/images/fairnest.png',
    this.about =
        "I’m a night owl who loves sketching and ambient music. I’m mostly quiet "
            "but love the occasional deep convos in the kitchen. I keep my space tidy, "
            "cook often, and value mutual respect in shared living. You’ll probably "
            "find me in my corner with a matcha and a weird playlist.",
    this.onEditProfile,
  });

  final String name;
  final String avatarAsset;
  final String about;
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header with overlay back button (keeps AppHeader unmodified)
          Stack(
            children: [
              AppHeader(
                title: 'My Profile',
                onNotificationTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications tapped')),
                  );
                },
              ),
              Positioned(
                left: 4,
                top: top + 6,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF645A80)),
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: 'Back',
                ),
              ),
            ],
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar + name
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.asset(
                            avatarAsset,
                            width: 104,
                            height: 104,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: AppFonts.heading3.copyWith(
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // About Me (card)
                  LavenderBorderedCard(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    backgroundColor: const Color(0xFFD6CCE6), // soft lavender
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About Me',
                          style: AppFonts.heading3.copyWith(
                            color: const Color(0xFF645A80),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          about,
                          style: const TextStyle(
                            fontFamily: 'Krub',
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Lifestyle Overview (outer lavender card + inner stats card)
                  LavenderBorderedCard(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    backgroundColor: const Color(0xFFD6CCE6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lifestyle Overview',
                          style: AppFonts.heading3.copyWith(
                            color: const Color(0xFF645A80),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Inner stats card
                        LifestyleOverview(
                          barHeight: 10,
                          metrics: const [
                            LifestyleMetric(
                              kind: LifestyleMetricKind.tidiness,
                              value: 0.82,
                            ),
                            LifestyleMetric(
                              kind: LifestyleMetricKind.noiseActivity,
                              value: 0.45,
                            ),
                            LifestyleMetric(
                              kind: LifestyleMetricKind.schedule,
                              value: 0.92,
                            ),
                            LifestyleMetric(
                              kind: LifestyleMetricKind.guestFrequency,
                              value: 0.42,
                            ),
                            LifestyleMetric(
                              kind: LifestyleMetricKind.taskStructure,
                              value: 1.00,
                            ),
                            LifestyleMetric(
                              kind: LifestyleMetricKind.moneyAttitude,
                              value: 0.95,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Edit Profile button
                  MainButton(
                    text: 'Edit Profile',
                    backgroundColor: const Color(0xFFD8A85B),
                    textColor: Colors.black,
                    width: double.infinity,
                    height: 56,
                    borderRadius: 12,
                    onPressed: onEditProfile ??
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Edit Profile tapped')),
                          );
                        },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
