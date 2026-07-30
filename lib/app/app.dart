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
import '../data/models/song_model.dart';
import '../providers/songs_provider.dart';
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
  StreamSubscription? _saveSessionSub;
  StreamSubscription? _savePositionSub;
  int? _historyCandidateId;
  DateTime? _historyCandidateSince;
  int? _lastSaveSongId;
  int _lastSaveTime = 0;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _songSub?.cancel();
    _saveSessionSub?.cancel();
    _savePositionSub?.cancel();
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

      _saveSessionSub = audioService.currentSongStream.listen((song) {
        if (song == null) return;
        final queue = audioService.queue;
        _lastSaveSongId = song.id;
        _lastSaveTime = DateTime.now().millisecondsSinceEpoch;
        settingsService.saveLastSession(
          songId: song.id,
          positionMs: 0,
          queueIds: queue.map((s) => s.id).toList(),
        );
      });

      _savePositionSub = audioService.positionStream.listen((pos) {
        final songId = _lastSaveSongId;
        if (songId == null) return;
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - _lastSaveTime <= 15000) return;
        _lastSaveTime = now;
        settingsService.saveLastSession(
          songId: songId,
          positionMs: pos.inMilliseconds,
          queueIds: audioService.queue.map((s) => s.id).toList(),
        );
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
  bool _restoreAttempted = false;
  bool _listenerRegistered = false;

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
    final lastSongId = settingsService.lastSongId;
    if (!_listenerRegistered && lastSongId != null) {
      _listenerRegistered = true;
      ref.listen(songsProvider, (_, next) async {
        if (_restoreAttempted) return;
        final songs = next.valueOrNull;
        if (songs == null || songs.isEmpty) return;
        _restoreAttempted = true;

        final songIndex = songs.indexWhere((s) => s.id == lastSongId);
        if (songIndex == -1) return;
        final song = songs[songIndex];

        final savedIds = settingsService.lastQueueIds;
        List<SongModel> queue;
        if (savedIds.isNotEmpty) {
          queue = [];
          final usedId = <int>{};
          for (final id in savedIds) {
            if (usedId.contains(id)) continue;
            final idx = songs.indexWhere((s) => s.id == id);
            if (idx != -1) {
              queue.add(songs[idx]);
              usedId.add(id);
            }
          }
          if (!usedId.contains(lastSongId)) {
            queue.insert(0, song);
          }
        } else {
          queue = [song];
        }

        await audioService.play(song, playlist: queue);
        final pos = Duration(milliseconds: settingsService.lastPositionMs);
        if (pos > Duration.zero) {
          await audioService.seek(pos);
        }
      });
    }

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
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Error de inicialización',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
