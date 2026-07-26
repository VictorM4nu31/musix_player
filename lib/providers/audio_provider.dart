import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../core/utils/seeded_stream.dart';
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
  return seededStream(audioService.currentSong, audioService.currentSongStream);
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
  return seededStream(audioService.queue, audioService.queueStream);
});

final currentIndexProvider = StreamProvider<int>((ref) {
  final audioService = ref.watch(audioPlayerServiceProvider);
  return seededStream(
    audioService.currentIndex,
    audioService.currentIndexStream,
  );
});

final shuffleModeProvider = StreamProvider<bool>((ref) {
  final audioService = ref.watch(audioPlayerServiceProvider);
  return seededStream(
    audioService.isShuffleMode,
    audioService.shuffleModeStream,
  );
});

final loopModeProvider = StreamProvider<LoopMode>((ref) {
  final audioService = ref.watch(audioPlayerServiceProvider);
  return seededStream(audioService.loopMode, audioService.loopModeStream);
});
