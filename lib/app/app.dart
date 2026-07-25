import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import '../core/service_locator.dart';
import '../providers/settings_provider.dart';
import '../services/audio/audio_player_service.dart';
import '../services/audio/audio_handler.dart';
import '../services/history/history_service.dart';
import '../screens/splash/splash_screen.dart';

class MusixPlayerApp extends StatefulWidget {
  const MusixPlayerApp({super.key});

  @override
  State<MusixPlayerApp> createState() => _MusixPlayerAppState();
}

class _MusixPlayerAppState extends State<MusixPlayerApp> {
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    try {
      historyService = HistoryService();
      await historyService.init();

      audioService = AudioPlayerService();

      audioService.songStartedStream.listen((song) {
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

class _AppWithTheme extends ConsumerWidget {
  const _AppWithTheme();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Musix Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
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
