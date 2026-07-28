import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'router.dart';
import 'theme/theme_catalog.dart';
import 'theme/theme_definition.dart';
import '../core/constants/app_constants.dart';
import '../core/service_locator.dart';
import '../services/audio/audio_player_service.dart';
import '../services/audio/audio_handler.dart';
import '../services/blacklist/blacklist_service.dart';
import '../services/favorites/favorites_service.dart';
import '../services/history/history_service.dart';
import '../services/playlist/playlist_service.dart';
import '../services/settings/settings_service.dart';
import '../services/widget/home_widget_service.dart';
import '../screens/splash/splash_screen.dart';

class MusixPlayerApp extends StatefulWidget {
  const MusixPlayerApp({super.key});

  @override
  State<MusixPlayerApp> createState() => _MusixPlayerAppState();
}

class _MusixPlayerAppState extends State<MusixPlayerApp> {
  bool _initialized = false;
  String? _error;
  StreamSubscription? _positionSub;
  StreamSubscription? _songSub;
  int? _historyCandidateId;
  DateTime? _historyCandidateSince;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _songSub?.cancel();
    homeWidgetService?.dispose();
    super.dispose();
  }

  Future<void> _initServices() async {
    try {
      await SharedPreferences.getInstance();

      settingsService = SettingsService();
      await settingsService.init();

      historyService = HistoryService();
      await historyService.init();

      final blacklistSvc = BlacklistService();
      await blacklistSvc.init();
      blacklistService = blacklistSvc;

      final favoritesSvc = FavoritesService();
      await favoritesSvc.init();
      favoritesService = favoritesSvc;

      final playlistSvc = PlaylistService();
      await playlistSvc.init();
      playlistService = playlistSvc;

      audioService = AudioPlayerService();
      audioService.setBlacklistChecker(blacklistService.isBlacklisted);
      final loopValues = LoopMode.values;
      final savedLoop = settingsService.loopModeIndex;
      audioService.restorePlaybackModes(
        shuffle: settingsService.shuffleEnabled,
        loopMode: (savedLoop >= 0 && savedLoop < loopValues.length)
            ? loopValues[savedLoop]
            : LoopMode.off,
      );
      audioService.onPlaybackModesChanged = (shuffle, loopMode) {
        settingsService.setShuffleEnabled(shuffle);
        settingsService.setLoopModeIndex(loopMode.index);
      };

      _songSub = audioService.currentSongStream.listen((song) {
        if (song == null) {
          _historyCandidateId = null;
          _historyCandidateSince = null;
          return;
        }
        if (_historyCandidateId != song.id) {
          _historyCandidateId = song.id;
          _historyCandidateSince = DateTime.now();
        }
      });

      _positionSub = audioService.positionStream.listen((position) {
        final song = audioService.currentSong;
        if (song == null || _historyCandidateId != song.id) return;
        if (position < AppConstants.historyMinPlayDuration) return;
        final since = _historyCandidateSince;
        if (since == null) return;
        // Record once per candidate song after threshold.
        _historyCandidateSince = null;
        historyService.addEntry(song);
      });

      // notificationColor is applied at service init (Android MediaStyle accent).
      // Layout/typography of the system notification cannot be themed from Flutter.
      audioHandler = await AudioService.init(
        builder: () => MusixAudioHandler(audioService),
        config: AudioServiceConfig(
          androidNotificationChannelId: 'com.musix_player.channel.audio',
          androidNotificationChannelName: 'Musix Player',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
          androidNotificationIcon: 'mipmap/ic_launcher',
          notificationColor:
              ThemeCatalog.notificationAccent(settingsService.themePreference),
        ),
      );

      homeWidgetService = HomeWidgetService(audioService);
      await homeWidgetService!.start();
    } catch (e) {
      setState(() => _error = e.toString());
      return;
    }

    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _ErrorScreen(_error!),
      );
    }

    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      );
    }

    return const ProviderScope(
      child: _AppWithTheme(),
    );
  }
}

class _AppWithTheme extends ConsumerStatefulWidget {
  const _AppWithTheme();

  @override
  ConsumerState<_AppWithTheme> createState() => _AppWithThemeState();
}

class _AppWithThemeState extends ConsumerState<_AppWithTheme> {
  late MaterialThemeConfig _themeConfig;
  StreamSubscription<ThemeId>? _themeSub;

  @override
  void initState() {
    super.initState();
    _themeConfig = settingsService.materialThemeConfig;
    _themeSub = settingsService.themeStream.listen((_) {
      if (mounted) {
        setState(() => _themeConfig = settingsService.materialThemeConfig);
      }
    });
  }

  @override
  void dispose() {
    _themeSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Musix Player',
      debugShowCheckedModeBanner: false,
      theme: _themeConfig.theme,
      darkTheme: _themeConfig.darkTheme,
      themeMode: _themeConfig.themeMode,
      routerConfig: router,
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen(this._error);
  final String _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'Error de inicialización',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
