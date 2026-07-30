import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/theme_catalog.dart';
import '../../app/theme/theme_definition.dart';
import '../../app/theme/theme_id.dart';
import '../../visual/models/animation_preset.dart';
import '../../visual/models/progress_style.dart';
import '../../visual/models/visual_quality.dart';
import '../../visual/models/visualizer_type.dart';

export '../../app/theme/theme_id.dart' show ThemeId, ThemePreference;

enum SortPreference { title, artist, album, duration }

class SettingsService {
  static const _themeKeyLegacy = 'theme_preference';
  static const _themeIdKey = 'theme_id';
  static const _sortKey = 'sort_preference';
  static const _animationKey = 'player_animation';
  static const _visualizerTypeKey = 'visualizer_type';
  static const _animationPresetKey = 'animation_preset';
  static const _visualQualityKey = 'visual_quality';
  static const _visualIntensityKey = 'visual_intensity';
  static const _audioReactiveKey = 'audio_reactive';
  static const _animationsEnabledKey = 'animations_enabled';
  static const _progressStyleKey = 'progress_style';
  static const _shuffleKey = 'playback_shuffle';
  static const _loopKey = 'playback_loop';

  final _controller = StreamController<ThemeId>.broadcast();
  final _themeModeController = StreamController<ThemeMode>.broadcast();
  final _sortController = StreamController<SortPreference>.broadcast();
  final _visualizerTypeController =
      StreamController<VisualizerType>.broadcast();
  final _animationPresetController =
      StreamController<AnimationPreset>.broadcast();
  final _visualQualityController = StreamController<VisualQuality>.broadcast();
  final _visualIntensityController = StreamController<double>.broadcast();
  final _audioReactiveController = StreamController<bool>.broadcast();
  final _animationsEnabledController = StreamController<bool>.broadcast();
  final _progressStyleController = StreamController<ProgressStyle>.broadcast();

  ThemeId _themePreference = ThemeId.system;
  SortPreference _sortPreference = SortPreference.title;
  VisualizerType _visualizerType = VisualizerType.vinyl;
  AnimationPreset _animationPreset = AnimationPreset.vinyl;
  VisualQuality _visualQuality = VisualQuality.medium;
  double _visualIntensity = 0.7;
  bool _audioReactive = true;
  bool _animationsEnabled = true;
  ProgressStyle _progressStyle = ProgressStyle.auto;
  bool _shuffleEnabled = false;

  /// Matches [LoopMode] index: 0=off, 1=one, 2=all.
  int _loopModeIndex = 0;

  Stream<ThemeId> get themeStream => _controller.stream;
  Stream<ThemeMode> get themeModeStream => _themeModeController.stream;
  Stream<SortPreference> get sortStream => _sortController.stream;
  Stream<VisualizerType> get visualizerTypeStream =>
      _visualizerTypeController.stream;
  Stream<AnimationPreset> get animationPresetStream =>
      _animationPresetController.stream;
  Stream<VisualQuality> get visualQualityStream =>
      _visualQualityController.stream;
  Stream<double> get visualIntensityStream => _visualIntensityController.stream;
  Stream<bool> get audioReactiveStream => _audioReactiveController.stream;
  Stream<bool> get animationsEnabledStream =>
      _animationsEnabledController.stream;
  Stream<ProgressStyle> get progressStyleStream =>
      _progressStyleController.stream;

  /// Backward-compatible alias used by older call sites.
  Stream<VisualizerType> get animationStream => visualizerTypeStream;

  ThemeId get themePreference => _themePreference;
  ThemeId get themeId => _themePreference;
  SortPreference get sortPreference => _sortPreference;
  VisualizerType get visualizerType => _visualizerType;
  AnimationPreset get animationPreset => _animationPreset;
  VisualQuality get visualQuality => _visualQuality;
  double get visualIntensity => _visualIntensity;
  bool get audioReactive => _audioReactive;
  bool get animationsEnabled => _animationsEnabled;
  ProgressStyle get progressStyle => _progressStyle;

  /// Legacy name — same as [visualizerType].
  VisualizerType get playerAnimation => _visualizerType;

  bool get shuffleEnabled => _shuffleEnabled;
  int get loopModeIndex => _loopModeIndex;

  ThemeMode get themeMode =>
      ThemeCatalog.materialConfig(_themePreference).themeMode;

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

    _visualizerType = _loadVisualizerType(prefs);

    _animationPreset =
        AnimationPreset.tryParse(prefs.getString(_animationPresetKey)) ??
            AnimationPreset.vinyl;
    _visualQuality =
        VisualQuality.tryParse(prefs.getString(_visualQualityKey)) ??
            VisualQuality.medium;
    _visualIntensity =
        (prefs.getDouble(_visualIntensityKey) ?? 0.7).clamp(0.0, 1.0);
    _audioReactive = prefs.getBool(_audioReactiveKey) ?? true;
    _animationsEnabled = prefs.getBool(_animationsEnabledKey) ?? true;
    _progressStyle =
        ProgressStyle.tryParse(prefs.getString(_progressStyleKey)) ??
            ProgressStyle.auto;

    _shuffleEnabled = prefs.getBool(_shuffleKey) ?? false;
    final loopIndex = prefs.getInt(_loopKey) ?? 0;
    _loopModeIndex = (loopIndex >= 0 && loopIndex <= 2) ? loopIndex : 0;

    _controller.add(_themePreference);
    _themeModeController.add(themeMode);
    _sortController.add(_sortPreference);
    _visualizerTypeController.add(_visualizerType);
    _animationPresetController.add(_animationPreset);
    _visualQualityController.add(_visualQuality);
    _visualIntensityController.add(_visualIntensity);
    _audioReactiveController.add(_audioReactive);
    _animationsEnabledController.add(_animationsEnabled);
    _progressStyleController.add(_progressStyle);
  }

  VisualizerType _loadVisualizerType(SharedPreferences prefs) {
    final named = VisualizerType.tryParse(prefs.getString(_visualizerTypeKey));
    if (named != null) return named;

    final animIndex = prefs.getInt(_animationKey);
    if (animIndex != null) {
      return VisualizerType.fromLegacyIndex(animIndex);
    }
    // Historical default index 4 = minimal in old enum; product default is vinyl.
    return VisualizerType.vinyl;
  }

  ThemeId _loadThemeId(SharedPreferences prefs) {
    final stored = ThemeId.tryParse(prefs.getString(_themeIdKey));
    if (stored != null) return stored;

    final legacy = prefs.getInt(_themeKeyLegacy);
    if (legacy != null) {
      final migrated = ThemeId.fromLegacyIndex(legacy);
      prefs.setString(_themeIdKey, migrated.storageId);
      return migrated;
    }

    return ThemeId.system;
  }

  Future<void> setThemePreference(ThemeId preference) async {
    _themePreference = preference;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeIdKey, preference.storageId);
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

  Future<void> setVisualizerType(VisualizerType type) async {
    _visualizerType = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_visualizerTypeKey, type.storageId);
    await prefs.setInt(_animationKey, type.legacyIndex);
    _visualizerTypeController.add(_visualizerType);
  }

  /// Legacy API — maps old animation enum indices via [VisualizerType].
  Future<void> setPlayerAnimation(VisualizerType animation) =>
      setVisualizerType(animation);

  Future<void> setAnimationPreset(AnimationPreset preset) async {
    _animationPreset = preset;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_animationPresetKey, preset.storageId);
    _animationPresetController.add(_animationPreset);
  }

  /// Applies preset defaults for visualizer, quality and intensity.
  Future<void> applyAnimationPreset(AnimationPreset preset) async {
    await setAnimationPreset(preset);
    await setVisualizerType(preset.defaultVisualizer);
    await setVisualQuality(preset.defaultQuality);
    await setVisualIntensity(preset.defaultIntensity);
  }

  Future<void> setVisualQuality(VisualQuality quality) async {
    _visualQuality = quality;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_visualQualityKey, quality.storageId);
    _visualQualityController.add(_visualQuality);
  }

  Future<void> setVisualIntensity(double intensity) async {
    _visualIntensity = intensity.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_visualIntensityKey, _visualIntensity);
    _visualIntensityController.add(_visualIntensity);
  }

  Future<void> setAudioReactive(bool enabled) async {
    _audioReactive = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_audioReactiveKey, enabled);
    _audioReactiveController.add(_audioReactive);
  }

  Future<void> setAnimationsEnabled(bool enabled) async {
    _animationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_animationsEnabledKey, enabled);
    _animationsEnabledController.add(_animationsEnabled);
  }

  Future<void> setProgressStyle(ProgressStyle style) async {
    _progressStyle = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressStyleKey, style.storageId);
    _progressStyleController.add(_progressStyle);
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
    await _visualizerTypeController.close();
    await _animationPresetController.close();
    await _visualQualityController.close();
    await _visualIntensityController.close();
    await _audioReactiveController.close();
    await _animationsEnabledController.close();
    await _progressStyleController.close();
  }
}
