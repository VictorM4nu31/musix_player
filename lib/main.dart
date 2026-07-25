import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'services/audio/audio_player_service.dart';
import 'services/audio/audio_handler.dart';
import 'services/history/history_service.dart';

late AudioPlayerService audioService;
late MusixAudioHandler audioHandler;
late HistoryService historyService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(
    const ProviderScope(
      child: MusixPlayerApp(),
    ),
  );
}
