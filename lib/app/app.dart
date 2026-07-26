import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/pixel_art_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/service_locator.dart';
import '../services/audio/audio_player_service.dart';
import '../services/audio/audio_handler.dart';
import '../services/blacklist/blacklist_service.dart';
import '../services/favorites/favorites_service.dart';
import '../services/history/history_service.dart';
import '../services/playlist/playlist_service.dart';
import '../services/settings/settings_service.dart';
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

      audioHandler = await AudioService.init(
        builder: () => MusixAudioHandler(audioService),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.musix_player.channel.audio',
          androidNotificationChannelName: 'Musix Player',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
          androidNotificationIcon: 'mipmap/ic_launcher',
        ),
      );
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
  late ThemeMode _themeMode;
  StreamSubscription<ThemeMode>? _themeSub;

  @override
  void initState() {
    super.initState();
    _themeMode = settingsService.themeMode;
    _themeSub = settingsService.themeModeStream.listen((mode) {
      if (mounted) {
        setState(() => _themeMode = mode);
      }
    });
  }

  @override
  void dispose() {
    _themeSub?.cancel();
    super.dispose();
  }

  ThemeData _darkTheme() {
    if (settingsService.themePreference == ThemePreference.pixelArt) {
      return AppThemePixelArt.theme;
    }
    return AppTheme.dark;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Musix Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: _darkTheme(),
      themeMode: _themeMode,
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
