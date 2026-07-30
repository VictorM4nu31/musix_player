import 'package:flutter_test/flutter_test.dart';
import 'package:musix_player/services/settings/settings_service.dart';
import 'package:musix_player/visual/analysis/waveform_service.dart';
import 'package:musix_player/visual/models/animation_preset.dart';
import 'package:musix_player/visual/models/progress_style.dart';
import 'package:musix_player/visual/models/visual_quality.dart';
import 'package:musix_player/visual/models/visualizer_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults shuffle off and loop off', () async {
    final service = SettingsService();
    await service.init();
    expect(service.shuffleEnabled, isFalse);
    expect(service.loopModeIndex, 0);
    expect(service.themePreference, ThemeId.system);
    await service.dispose();
  });

  test('persists shuffle and loop across init', () async {
    final first = SettingsService();
    await first.init();
    await first.setShuffleEnabled(true);
    await first.setLoopModeIndex(2);
    await first.dispose();

    final second = SettingsService();
    await second.init();
    expect(second.shuffleEnabled, isTrue);
    expect(second.loopModeIndex, 2);
    await second.dispose();
  });

  test('clamps invalid loop index to off', () async {
    final service = SettingsService();
    await service.init();
    await service.setLoopModeIndex(99);
    expect(service.loopModeIndex, 0);
    await service.dispose();
  });

  test('loads saved playback modes from prefs', () async {
    SharedPreferences.setMockInitialValues({
      'playback_shuffle': true,
      'playback_loop': 1,
    });
    final service = SettingsService();
    await service.init();
    expect(service.shuffleEnabled, isTrue);
    expect(service.loopModeIndex, 1);
    await service.dispose();
  });

  test('persists theme id as string', () async {
    final first = SettingsService();
    await first.init();
    await first.setThemePreference(ThemeId.pixelArt);
    await first.dispose();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_id'), 'pixelArt');

    final second = SettingsService();
    await second.init();
    expect(second.themePreference, ThemeId.pixelArt);
    await second.dispose();
  });

  test('migrates legacy theme_preference index', () async {
    SharedPreferences.setMockInitialValues({
      'theme_preference': 3,
    });
    final service = SettingsService();
    await service.init();
    expect(service.themePreference, ThemeId.pixelArt);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_id'), 'pixelArt');
    await service.dispose();
  });

  test('loads all custom theme ids', () async {
    for (final id in [
      ThemeId.amoled,
      ThemeId.cyberpunk,
      ThemeId.minimal,
      ThemeId.dark,
      ThemeId.light,
    ]) {
      SharedPreferences.setMockInitialValues({});
      final service = SettingsService();
      await service.init();
      await service.setThemePreference(id);
      await service.dispose();

      final reloaded = SettingsService();
      await reloaded.init();
      expect(reloaded.themePreference, id);
      await reloaded.dispose();
    }
  });

  test('migrates legacy player_animation index to visualizer type', () async {
    // Legacy: 2 = pulse
    SharedPreferences.setMockInitialValues({
      'player_animation': 2,
    });
    final service = SettingsService();
    await service.init();
    expect(service.visualizerType, VisualizerType.pulse);
    await service.dispose();
  });

  test('persists visualizer and preset settings', () async {
    final first = SettingsService();
    await first.init();
    await first.applyAnimationPreset(AnimationPreset.dynamic);
    await first.setVisualQuality(VisualQuality.high);
    await first.setVisualIntensity(0.4);
    await first.setAudioReactive(false);
    await first.setAnimationsEnabled(false);
    await first.setProgressStyle(ProgressStyle.waveform);
    await first.dispose();

    final second = SettingsService();
    await second.init();
    expect(second.animationPreset, AnimationPreset.dynamic);
    expect(second.visualizerType, VisualizerType.spectrum);
    expect(second.visualQuality, VisualQuality.high);
    expect(second.visualIntensity, closeTo(0.4, 0.001));
    expect(second.audioReactive, isFalse);
    expect(second.animationsEnabled, isFalse);
    expect(second.progressStyle, ProgressStyle.waveform);
    await second.dispose();
  });

  test('synthetic waveform samples are stable for same song', () {
    final a = WaveformData.synthetic(
      songId: 42,
      duration: const Duration(minutes: 3),
    );
    final b = WaveformData.synthetic(
      songId: 42,
      duration: const Duration(minutes: 3),
    );
    expect(a.samples, b.samples);
    expect(a.isSynthetic, isTrue);
    expect(a.samples, isNotEmpty);
  });
}
