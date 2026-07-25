import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'app/app.dart';
import 'services/audio/audio_player_service.dart';
import 'services/audio/audio_handler.dart';

late AudioPlayerService audioService;
late MusixAudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  audioService = AudioPlayerService();

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

  runApp(const MusixPlayerApp());
}
