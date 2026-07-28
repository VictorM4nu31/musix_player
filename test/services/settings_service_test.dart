import 'package:flutter_test/flutter_test.dart';
import 'package:musix_player/services/settings/settings_service.dart';
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
}
