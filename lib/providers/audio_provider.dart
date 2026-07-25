import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/song_model.dart';
import '../services/audio/audio_player_service.dart';
import '../services/audio/audio_handler.dart';
import '../core/service_locator.dart' as locator;

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  return locator.audioService;
});

final audioHandlerProvider = Provider<MusixAudioHandler>((ref) {
  return locator.audioHandler;
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
