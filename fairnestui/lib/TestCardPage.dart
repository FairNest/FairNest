// user_profile_test_page.dart
import 'package:fairnestui/model/user_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:fairnestui/services/user_profile_service.dart';
import 'package:fairnestui/services/user_service.dart';
import 'package:fairnestui/services/storage_service.dart';

class UserProfileTestPage extends StatefulWidget {
  const UserProfileTestPage({Key? key}) : super(key: key);

  @override
  State<UserProfileTestPage> createState() => _UserProfileTestPageState();
}

class _UserProfileTestPageState extends State<UserProfileTestPage> {
  UserProfile? _userProfile;
  bool _isLoading = false;
  String _status = 'Ready to test';
  String _cacheInfo = '';
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadInitialInfo();
  }

  Future<void> _loadInitialInfo() async {
    final userId = await UserService.getUserIdFromToken();
    final hasCached = await UserProfileService.instance.hasCachedProfile();
    final cacheAge = await UserProfileService.instance.getCacheAge();

    setState(() {
      _currentUserId = userId;
      _cacheInfo = 'Has cached: $hasCached';
      if (cacheAge != null) {
        _cacheInfo += '\nCache age: ${cacheAge.inMinutes} minutes';
      }
    });
  }

  Future<void> _getCurrentUserProfile() async {
    setState(() {
      _isLoading = true;
      _status = 'Fetching current user profile...';
    });

    try {
      final profile = await UserProfileService.instance.getCurrentUserProfile();
      setState(() {
        _userProfile = profile;
        _status = profile != null
            ? 'Profile loaded successfully!'
            : 'No profile found';
        _isLoading = false;
      });
      _loadInitialInfo(); // Refresh cache info
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _getCachedProfile() async {
    setState(() {
      _isLoading = true;
      _status = 'Loading cached profile only...';
    });

    try {
      final profile = await UserProfileService.instance.getCachedProfile();
      setState(() {
        _userProfile = profile;
        _status = profile != null
            ? 'Cached profile loaded!'
            : 'No cached profile found';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error loading cache: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _isLoading = true;
      _status = 'Force refreshing profile...';
    });

    try {
      final profile =
          await UserProfileService.instance.refreshCurrentUserProfile();
      setState(() {
        _userProfile = profile;
        _status = profile != null
            ? 'Profile refreshed successfully!'
            : 'Failed to refresh profile';
        _isLoading = false;
      });
      _loadInitialInfo(); // Refresh cache info
    } catch (e) {
      setState(() {
        _status = 'Refresh error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _clearCache() async {
    setState(() {
      _status = 'Clearing cache...';
    });

    try {
      await UserProfileService.instance.clearCache();
      setState(() {
        _userProfile = null;
        _status = 'Cache cleared successfully!';
      });
      _loadInitialInfo(); // Refresh cache info
    } catch (e) {
      setState(() {
        _status = 'Error clearing cache: $e';
      });
    }
  }

  Future<void> _checkAuthStatus() async {
    setState(() {
      _status = 'Checking authentication...';
    });

    try {
      final isAuth = await StorageService.isAuthenticated();
      final token = await StorageService.getToken();
      final userId = await UserService.getUserIdFromToken();
      final email = await UserService.getEmailFromToken();

      setState(() {
        _status = '''
Auth Status: $isAuth
User ID from token: $userId
Email from token: $email
Token exists: ${token != null}
Token preview: ${token?.substring(0, 20) ?? 'null'}...
''';
      });
    } catch (e) {
      setState(() {
        _status = 'Auth check error: $e';
      });
    }
  }

  Widget _buildProfileCard() {
    if (_userProfile == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No profile data',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    final profile = _userProfile!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            _buildInfoRow('User ID', profile.userId.toString()),
            _buildInfoRow('Username', profile.username),
            _buildInfoRow('Full Name', profile.fullName),
            _buildInfoRow('About Me', profile.userAboutMe),
            _buildInfoRow('Room ID', profile.roomId.toString()),
            _buildInfoRow('Roommate Score', profile.roommateScore.toString()),
            const SizedBox(height: 8),
            Text(
              'Personality Scores:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            _buildInfoRow('Tidiness', profile.userTidiness.toString()),
            _buildInfoRow(
                'Noise Activity', profile.userNoiseActivity.toString()),
            _buildInfoRow('Schedule', profile.userSchedule.toString()),
            _buildInfoRow(
                'Guest Frequency', profile.userGuestFrequency.toString()),
            _buildInfoRow(
                'Task Structure', profile.userTaskStructure.toString()),
            _buildInfoRow(
                'Money Attitude', profile.userMoneyAttitude.toString()),
            const SizedBox(height: 8),
            _buildInfoRow('Last Updated', profile.lastUpdated.toString()),
            _buildInfoRow('Cache Expired', profile.isCacheExpired().toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile Service Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    if (_currentUserId != null) ...[
                      const SizedBox(height: 4),
                      Text('Current User ID: $_currentUserId'),
                    ],
                    if (_cacheInfo.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(_cacheInfo),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Actions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _getCurrentUserProfile,
                          icon: const Icon(Icons.person),
                          label: const Text('Get Current Profile'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _getCachedProfile,
                          icon: const Icon(Icons.storage),
                          label: const Text('Get Cached Only'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _refreshProfile,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Force Refresh'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _clearCache,
                          icon: const Icon(Icons.delete),
                          label: const Text('Clear Cache'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _checkAuthStatus,
                          icon: const Icon(Icons.security),
                          label: const Text('Check Auth'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Loading Indicator
            if (_isLoading)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Loading...'),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Profile Data
            _buildProfileCard(),
          ],
        ),
      ),
    );
  }
}

// Usage in your app:
// Add this to your routes or navigate directly:
/*
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const UserProfileTestPage(),
  ),
);
*/
