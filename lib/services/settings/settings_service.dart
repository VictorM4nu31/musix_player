import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/theme_catalog.dart';
import '../../app/theme/theme_definition.dart';
import '../../app/theme/theme_id.dart';
import '../../core/widgets/player_animations/animation_type.dart';

export '../../app/theme/theme_id.dart' show ThemeId, ThemePreference;

enum SortPreference { title, artist, album, duration }

class SettingsService {
  static const _themeKeyLegacy = 'theme_preference';
  static const _themeIdKey = 'theme_id';
  static const _sortKey = 'sort_preference';
  static const _animationKey = 'player_animation';
  static const _shuffleKey = 'playback_shuffle';
  static const _loopKey = 'playback_loop';

  final _controller = StreamController<ThemeId>.broadcast();
  final _themeModeController = StreamController<ThemeMode>.broadcast();
  final _sortController = StreamController<SortPreference>.broadcast();
  final _animationController = StreamController<PlayerAnimationType>.broadcast();

  ThemeId _themePreference = ThemeId.system;
  SortPreference _sortPreference = SortPreference.title;
  PlayerAnimationType _playerAnimation = PlayerAnimationType.vinyl;
  bool _shuffleEnabled = false;

  /// Matches [LoopMode] index: 0=off, 1=one, 2=all.
  int _loopModeIndex = 0;

  Stream<ThemeId> get themeStream => _controller.stream;
  Stream<ThemeMode> get themeModeStream => _themeModeController.stream;
  Stream<SortPreference> get sortStream => _sortController.stream;
  Stream<PlayerAnimationType> get animationStream => _animationController.stream;

  ThemeId get themePreference => _themePreference;
  ThemeId get themeId => _themePreference;
  SortPreference get sortPreference => _sortPreference;
  PlayerAnimationType get playerAnimation => _playerAnimation;
  bool get shuffleEnabled => _shuffleEnabled;
  int get loopModeIndex => _loopModeIndex;

  ThemeMode get themeMode => ThemeCatalog.materialConfig(_themePreference).themeMode;

  MaterialThemeConfig get materialThemeConfig =>
      ThemeCatalog.materialConfig(_themePreference);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    _themePreference = _loadThemeId(prefs);

    final sortIndex = prefs.getInt(_sortKey) ?? 0;
    if (sortIndex >= 0 && sortIndex < SortPreference.values.length) {
      _sortPreference = SortPreference.values[sortIndex];
    } else {
      _sortPreference = SortPreference.title;
    }

    final animIndex = prefs.getInt(_animationKey) ?? 4;
    if (animIndex >= 0 && animIndex < PlayerAnimationType.values.length) {
      _playerAnimation = PlayerAnimationType.values[animIndex];
    }

    _shuffleEnabled = prefs.getBool(_shuffleKey) ?? false;
    final loopIndex = prefs.getInt(_loopKey) ?? 0;
    _loopModeIndex = (loopIndex >= 0 && loopIndex <= 2) ? loopIndex : 0;

    _controller.add(_themePreference);
    _themeModeController.add(themeMode);
    _sortController.add(_sortPreference);
    _animationController.add(_playerAnimation);
  }

  ThemeId _loadThemeId(SharedPreferences prefs) {
    final stored = ThemeId.tryParse(prefs.getString(_themeIdKey));
    if (stored != null) return stored;

    final legacy = prefs.getInt(_themeKeyLegacy);
    if (legacy != null) {
      final migrated = ThemeId.fromLegacyIndex(legacy);
      // Fire-and-forget migration to string key.
      prefs.setString(_themeIdKey, migrated.storageId);
      return migrated;
    }

    return ThemeId.system;
  }

  Future<void> setThemePreference(ThemeId preference) async {
    _themePreference = preference;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeIdKey, preference.storageId);
    // Keep legacy int in sync for older builds / rollback safety (capped ids).
    final legacyIndex = switch (preference) {
      ThemeId.system => 0,
      ThemeId.light => 1,
      ThemeId.dark => 2,
      ThemeId.pixelArt => 3,
      _ => preference.index,
    };
    await prefs.setInt(_themeKeyLegacy, legacyIndex);
    _controller.add(_themePreference);
    _themeModeController.add(themeMode);
  }

  Future<void> setThemeId(ThemeId id) => setThemePreference(id);

  Future<void> setSortPreference(SortPreference preference) async {
    _sortPreference = preference;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sortKey, preference.index);
    _sortController.add(_sortPreference);
  }

  Future<void> setPlayerAnimation(PlayerAnimationType animation) async {
    _playerAnimation = animation;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_animationKey, animation.index);
    _animationController.add(_playerAnimation);
  }

  Future<void> setShuffleEnabled(bool enabled) async {
    _shuffleEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shuffleKey, enabled);
  }

  /// [index] must match just_audio LoopMode: 0=off, 1=one, 2=all.
  Future<void> setLoopModeIndex(int index) async {
    _loopModeIndex = (index >= 0 && index <= 2) ? index : 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_loopKey, _loopModeIndex);
  }

  Future<void> dispose() async {
    await _controller.close();
    await _themeModeController.close();
    await _sortController.close();
    await _animationController.close();
  }
}
