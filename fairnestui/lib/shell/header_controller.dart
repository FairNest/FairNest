// lib/shell/header_controller.dart
import 'package:flutter/material.dart';

class HeaderConfig {
  final String scoreText;
  final double progress;
  final bool showNotifications;
  final bool showSettings;
  final VoidCallback? onTapNotifications;
  final VoidCallback? onTapSettings;
  final ImageProvider? avatarImage;

  const HeaderConfig(
      {this.scoreText = '0 Points',
      this.progress = 0.0,
      this.showNotifications = true,
      this.showSettings = true,
      this.onTapNotifications,
      this.onTapSettings,
      this.avatarImage});

  HeaderConfig copyWith({
    String? scoreText,
    double? progress,
    bool? showNotifications,
    bool? showSettings,
    VoidCallback? onTapNotifications,
    VoidCallback? onTapSettings,
    ImageProvider? avatarImage,
  }) =>
      HeaderConfig(
        scoreText: scoreText ?? this.scoreText,
        progress: progress ?? this.progress,
        showNotifications: showNotifications ?? this.showNotifications,
        showSettings: showSettings ?? this.showSettings,
        onTapNotifications: onTapNotifications ?? this.onTapNotifications,
        onTapSettings: onTapSettings ?? this.onTapSettings,
        avatarImage: avatarImage ?? this.avatarImage,
      );
}

class HeaderController extends ChangeNotifier {
  HeaderConfig _config = const HeaderConfig();
  HeaderConfig get config => _config;

  void set(HeaderConfig config) {
    _config = config;
    notifyListeners();
  }

  void update({
    String? scoreText,
    double? progress,
    bool? showNotifications,
    bool? showSettings,
    VoidCallback? onTapNotifications,
    VoidCallback? onTapSettings,
  }) {
    _config = _config.copyWith(
      scoreText: scoreText,
      progress: progress,
      showNotifications: showNotifications,
      showSettings: showSettings,
      onTapNotifications: onTapNotifications,
      onTapSettings: onTapSettings,
    );
    notifyListeners();
  }
}
