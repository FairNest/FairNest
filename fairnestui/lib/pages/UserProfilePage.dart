// lib/profile/my_profile_page.dart
import 'package:flutter/material.dart';

import 'package:fairnestui/theme/app_colors.dart';
import 'package:fairnestui/theme/app_fonts.dart';

import 'package:fairnestui/widgets/app_header.dart';
import 'package:fairnestui/components/LavenderBorderedCard.dart';
import 'package:fairnestui/components/MainButton.dart';
import 'package:fairnestui/widgets/LifestyleOverview.dart';

// Profile service & model (paths aligned to your service snippet)
import 'package:fairnestui/services/user_profile_service.dart';
import 'package:fairnestui/model/user_profile_model.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  UserProfile? _profile;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadProfileSWR(); // cache-first, then refresh
  }

  Future<void> _loadProfileSWR() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1) Cached first (fast)
      final cached = await UserProfileService.instance.getCurrentUserProfile();
      if (!mounted) return;
      if (cached != null) {
        final img = _avatarProviderFor(cached.userPicture);
        try {
          await precacheImage(img, context);
        } catch (_) {}
        setState(() {
          _profile = cached;
          _loading = false;
        });
      }

      // 2) Fresh afterwards (force refresh)
      final fresh =
          await UserProfileService.instance.refreshCurrentUserProfile();
      if (!mounted) return;
      if (fresh != null) {
        final img = _avatarProviderFor(fresh.userPicture);
        try {
          await precacheImage(img, context);
        } catch (_) {}
        setState(() {
          _profile = fresh;
          _loading = false;
        });
      } else if (cached == null) {
        setState(() => _loading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  ImageProvider _avatarProviderFor(String url) {
    if (url.isEmpty) {
      return const AssetImage('assets/images/poke.png');
    }
    // Decode roughly to on-screen size (radius 54 => 108px; double for HiDPI)
    return ResizeImage(NetworkImage(url), width: 216, height: 216);
  }

  double _unit(double v) => v.clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header with overlay back button
          Stack(
            children: [
              AppHeader(
                title: 'My Profile',
                rightType: AppHeaderRightType.notification,
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

          Expanded(
            child: Builder(
              builder: (context) {
                if (_loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_error != null) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.redAccent, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load profile.',
                          style:
                              AppFonts.heading3.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_error',
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        MainButton(
                          text: 'Retry',
                          backgroundColor: const Color(0xFFD8A85B),
                          textColor: Colors.black,
                          width: double.infinity,
                          height: 48,
                          borderRadius: 12,
                          onPressed: _loadProfileSWR,
                        ),
                      ],
                    ),
                  );
                }

                final p = _profile!;
                final avatar = _avatarProviderFor(p.userPicture);

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Avatar + username
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 54,
                            backgroundColor: Colors.white,
                            backgroundImage: const AssetImage(
                                'assets/images/poke.png'), // instant placeholder
                            foregroundImage: avatar, // fades in when ready
                          ),
                          const SizedBox(height: 8),
                          Text(
                            p.username, // 👈 username only
                            style: AppFonts.heading3.copyWith(
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // About Me
                      LavenderBorderedCard(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        backgroundColor: const Color(0xFFD6CCE6),
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
                              (p.userAboutMe.isEmpty)
                                  ? 'No bio yet.'
                                  : p.userAboutMe,
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

                      // Lifestyle Overview
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
                            LifestyleOverview(
                              barHeight: 10,
                              metrics: [
                                LifestyleMetric(
                                  kind: LifestyleMetricKind.tidiness,
                                  value: _unit(p.userTidiness),
                                ),
                                LifestyleMetric(
                                  kind: LifestyleMetricKind.noiseActivity,
                                  value: _unit(p.userNoiseActivity),
                                ),
                                LifestyleMetric(
                                  kind: LifestyleMetricKind.schedule,
                                  value: _unit(p.userSchedule),
                                ),
                                LifestyleMetric(
                                  kind: LifestyleMetricKind.guestFrequency,
                                  value: _unit(p.userGuestFrequency),
                                ),
                                LifestyleMetric(
                                  kind: LifestyleMetricKind.taskStructure,
                                  value: _unit(p.userTaskStructure),
                                ),
                                LifestyleMetric(
                                  kind: LifestyleMetricKind.moneyAttitude,
                                  value: _unit(p.userMoneyAttitude),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
