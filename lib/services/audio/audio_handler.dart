import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/song_model.dart';
import 'audio_player_service.dart';

class MusixAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  MusixAudioHandler(this._audioService) {
    _init();
  }

  final AudioPlayerService _audioService;
  AudioPlayer get _player => _audioService.player;
  StreamSubscription<List<SongModel>>? _queueSubscription;
  StreamSubscription<SongModel?>? _songSubscription;
  StreamSubscription<PlaybackEvent>? _playbackEventSubscription;
  StreamSubscription<Duration>? _positionSubscription;

  void _init() {
    _playbackEventSubscription =
        _player.playbackEventStream.listen(_onPlaybackEvent);

    _songSubscription = _audioService.currentSongStream.listen((song) {
      if (song != null) {
        mediaItem.add(_toMediaItem(song));
      }
    });

    _queueSubscription = _audioService.queueStream.listen((queue) {
      final items = queue.map(_toMediaItem).toList();
      this.queue.add(items);
    });

    _positionSubscription = _audioService.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(updatePosition: position));
    });
  }

  void _onPlaybackEvent(PlaybackEvent event) {
    playbackState.add(playbackState.value.copyWith(
      controls: _buildControls(),
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _mapProcessingState(_player.processingState),
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _audioService.currentIndex >= 0
          ? _audioService.currentIndex
          : _player.currentIndex,
      shuffleMode: _audioService.isShuffleMode
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
      repeatMode: _mapRepeatMode(_audioService.loopMode),
    ));
  }

  AudioServiceRepeatMode _mapRepeatMode(LoopMode mode) {
    switch (mode) {
      case LoopMode.off:
        return AudioServiceRepeatMode.none;
      case LoopMode.one:
        return AudioServiceRepeatMode.one;
      case LoopMode.all:
        return AudioServiceRepeatMode.all;
    }
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  List<MediaControl> _buildControls() {
    return [
      MediaControl.skipToPrevious,
      if (_player.playing) MediaControl.pause else MediaControl.play,
      MediaControl.skipToNext,
    ];
  }

  MediaItem _toMediaItem(SongModel song) {
    final id = song.contentUri?.isNotEmpty == true
        ? song.contentUri!
        : (song.filePath.isNotEmpty ? song.filePath : song.id.toString());
    return MediaItem(
      id: id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: song.duration,
      artUri: song.artworkUri != null ? Uri.tryParse(song.artworkUri!) : null,
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _audioService.seekToNext();

  @override
  Future<void> skipToPrevious() => _audioService.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) async {
    await _audioService.seekToIndex(index);
    await _player.play();
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode != AudioServiceShuffleMode.none;
    _audioService.setShuffleMode(enabled);
    await super.setShuffleMode(
      enabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
    );
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    final loopMode = switch (repeatMode) {
      AudioServiceRepeatMode.none ||
      AudioServiceRepeatMode.group =>
        LoopMode.off,
      AudioServiceRepeatMode.one => LoopMode.one,
      AudioServiceRepeatMode.all => LoopMode.all,
    };
    _audioService.setLoopMode(loopMode);
    await super.setRepeatMode(repeatMode);
  }

  Future<void> setQueue(List<SongModel> songs, {SongModel? initialSong}) async {
    final items = songs.map(_toMediaItem).toList();
    queue.add(items);
    if (initialSong != null) {
      mediaItem.add(_toMediaItem(initialSong));
    }
  }

  Future<void> dispose() async {
    await _playbackEventSubscription?.cancel();
    await _songSubscription?.cancel();
    await _queueSubscription?.cancel();
    await _positionSubscription?.cancel();
  }
}
