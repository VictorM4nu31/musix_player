import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../data/models/song_model.dart';
import '../../services/audio/audio_player_service.dart';
import '../../services/audio/audio_handler.dart';

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

final audioHandlerProvider = FutureProvider<MusixAudioHandler>((ref) async {
  final audioService = ref.read(audioPlayerServiceProvider);

  final handler = await AudioService.init(
    builder: () => MusixAudioHandler(audioService),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.musix_player.channel.audio',
      androidNotificationChannelName: 'Musix Player',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  ref.onDispose(() => handler.stop());
  return handler;
});

final currentSongProvider = StreamProvider<SongModel?>((ref) {
  final audioService = ref.watch(audioPlayerServiceProvider);
  return audioService.currentSongStream;
});

final isPlayingProvider = StreamProvider<bool>((ref) {
  final audioService = ref.watch(audioPlayerServiceProvider);
  return audioService.playingStream;
});

final positionProvider = StreamProvider<Duration>((ref) {
  final audioService = ref.watch(audioPlayerServiceProvider);
  return audioService.positionStream;
});

final durationProvider = StreamProvider<Duration?>((ref) {
  final audioService = ref.watch(audioPlayerServiceProvider);
  return audioService.durationStream;
});

final queueProvider = StreamProvider<List<SongModel>>((ref) {
  final audioService = ref.watch(audioPlayerServiceProvider);
  return audioService.queueStream;
});

final currentIndexProvider = Provider<int>((ref) {
  final audioService = ref.watch(audioPlayerServiceProvider);
  return audioService.currentIndex;
});
