import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/player_animations/animation_type.dart';

enum ThemePreference { system, light, dark, pixelArt }

enum SortPreference { title, artist, album, duration, dateAdded }

class SettingsService {
  static const _themeKey = 'theme_preference';
  static const _sortKey = 'sort_preference';
  static const _notificationsKey = 'show_notifications';
  static const _animationKey = 'player_animation';

  final _controller = StreamController<ThemePreference>.broadcast();
  final _themeModeController = StreamController<ThemeMode>.broadcast();
  ThemePreference _themePreference = ThemePreference.system;
  SortPreference _sortPreference = SortPreference.title;
  bool _showNotifications = true;
  PlayerAnimationType _playerAnimation = PlayerAnimationType.vinyl;

  Stream<ThemePreference> get themeStream => _controller.stream;
  Stream<ThemeMode> get themeModeStream => _themeModeController.stream;
  ThemePreference get themePreference => _themePreference;
  SortPreference get sortPreference => _sortPreference;
  bool get showNotifications => _showNotifications;
  PlayerAnimationType get playerAnimation => _playerAnimation;

  ThemeMode get themeMode {
    switch (_themePreference) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
      case ThemePreference.pixelArt:
        return ThemeMode.dark;
    }
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _themePreference = ThemePreference.values[themeIndex];

    final sortIndex = prefs.getInt(_sortKey) ?? 0;
    _sortPreference = SortPreference.values[sortIndex];

    _showNotifications = prefs.getBool(_notificationsKey) ?? true;

    final animIndex = prefs.getInt(_animationKey) ?? 4;
    _playerAnimation = PlayerAnimationType.values[animIndex];

    _controller.add(_themePreference);
    _themeModeController.add(themeMode);
  }

  Future<void> setThemePreference(ThemePreference preference) async {
    _themePreference = preference;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, preference.index);
    _controller.add(_themePreference);
    _themeModeController.add(themeMode);
  }

  Future<void> setSortPreference(SortPreference preference) async {
    _sortPreference = preference;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sortKey, preference.index);
  }

  Future<void> setShowNotifications(bool show) async {
    _showNotifications = show;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, show);
  }

  Future<void> setPlayerAnimation(PlayerAnimationType animation) async {
    _playerAnimation = animation;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_animationKey, animation.index);
  }

  Future<void> dispose() async {
    await _controller.close();
    await _themeModeController.close();
  }
}
