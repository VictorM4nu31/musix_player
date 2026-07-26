import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../../data/models/song_model.dart';

class AudioPlayerService {
  AudioPlayerService() {
    _init();
  }

  final AudioPlayer _player = AudioPlayer();
  List<SongModel> _queue = [];
  int _currentIndex = -1;
  bool _isShuffleMode = false;
  LoopMode _loopMode = LoopMode.off;
  bool Function(int songId)? _isBlacklisted;
  bool _sourceLoaded = false;

  final _queueController = StreamController<List<SongModel>>.broadcast();
  final _currentSongController = StreamController<SongModel?>.broadcast();
  final _songStartedController = StreamController<SongModel>.broadcast();
  final _shuffleController = StreamController<bool>.broadcast();
  final _loopModeController = StreamController<LoopMode>.broadcast();
  final _currentIndexController = StreamController<int>.broadcast();

  StreamSubscription<int?>? _indexSubscription;
  StreamSubscription<ProcessingState>? _processingSubscription;
  int? _lastEmittedStartedId;

  AudioPlayer get player => _player;
  List<SongModel> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  bool get isShuffleMode => _isShuffleMode;
  LoopMode get loopMode => _loopMode;

  SongModel? get currentSong =>
      _currentIndex >= 0 && _currentIndex < _queue.length
          ? _queue[_currentIndex]
          : null;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;
  Stream<List<SongModel>> get queueStream => _queueController.stream;
  Stream<SongModel?> get currentSongStream => _currentSongController.stream;
  Stream<SongModel> get songStartedStream => _songStartedController.stream;
  Stream<bool> get shuffleModeStream => _shuffleController.stream;
  Stream<LoopMode> get loopModeStream => _loopModeController.stream;
  Stream<int> get currentIndexStream => _currentIndexController.stream;

  void setBlacklistChecker(bool Function(int songId) checker) {
    _isBlacklisted = checker;
  }

  void _init() {
    _indexSubscription = _player.currentIndexStream.listen((index) {
      if (index == null) return;
      if (index == _currentIndex && currentSong != null) {
        _emitStartedIfNeeded(currentSong!);
        return;
      }
      _setCurrentIndex(index, emitStarted: true);
    });

    _processingSubscription = _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _handleSongComplete();
      }
    });
  }

  void _emitQueue() {
    _queueController.add(queue);
  }

  void _setCurrentIndex(int index, {bool emitStarted = false}) {
    _currentIndex = index;
    _currentIndexController.add(_currentIndex);
    final song = currentSong;
    _currentSongController.add(song);
    if (emitStarted && song != null) {
      _emitStartedIfNeeded(song);
    }
  }

  void _emitStartedIfNeeded(SongModel song) {
    if (_lastEmittedStartedId == song.id) return;
    _lastEmittedStartedId = song.id;
    _songStartedController.add(song);
  }

  AudioSource _sourceFor(SongModel song) {
    return AudioSource.uri(
      song.playbackUri,
      tag: song.id.toString(),
    );
  }

  Future<void> _applyQueueToPlayer({
    int? initialIndex,
    bool autoPlay = false,
  }) async {
    if (_queue.isEmpty) {
      _sourceLoaded = false;
      await _player.stop();
      return;
    }

    final index = (initialIndex ?? _currentIndex).clamp(0, _queue.length - 1);
    final sources = _queue.map(_sourceFor).toList();
    final concatenating = ConcatenatingAudioSource(children: sources);

    await _player.setAudioSource(
      concatenating,
      initialIndex: index,
      initialPosition: Duration.zero,
    );
    _sourceLoaded = true;
    _setCurrentIndex(index, emitStarted: true);

    if (autoPlay) {
      await _player.play();
    }
  }

  Future<void> play(SongModel song, {List<SongModel>? playlist}) async {
    if (playlist != null) {
      if (_isBlacklisted != null) {
        final filtered = playlist.where((s) => !_isBlacklisted!(s.id)).toList();
        if (!filtered.any((s) => s.id == song.id)) {
          filtered.insert(0, song);
        }
        _queue = filtered;
      } else {
        _queue = List.from(playlist);
      }
      _currentIndex = _queue.indexWhere((s) => s.id == song.id);
      if (_currentIndex == -1) {
        _queue.insert(0, song);
        _currentIndex = 0;
      }
    } else if (!_queue.any((s) => s.id == song.id)) {
      _queue.add(song);
      _currentIndex = _queue.length - 1;
    } else {
      _currentIndex = _queue.indexWhere((s) => s.id == song.id);
    }

    _lastEmittedStartedId = null;
    _emitQueue();
    await _applyQueueToPlayer(initialIndex: _currentIndex, autoPlay: true);
  }

  Future<void> resume() async => _player.play();

  Future<void> pause() async => _player.pause();

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> stop() async => _player.stop();

  Future<void> seek(Duration position) async => _player.seek(position);

  Future<void> seekToNext() async {
    if (_isBlacklisted != null) {
      await _skipToNextNonBlacklisted();
      return;
    }
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  Future<void> seekToPrevious() async {
    if (_player.position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
    } else if (_player.hasPrevious) {
      await _player.seekToPrevious();
    }
  }

  Future<void> seekToIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;
    if (_sourceLoaded && index < (_player.sequence?.length ?? 0)) {
      await _player.seek(Duration.zero, index: index);
      _setCurrentIndex(index, emitStarted: true);
    } else {
      await _applyQueueToPlayer(initialIndex: index, autoPlay: true);
    }
  }

  void toggleShuffle() {
    setShuffleMode(!_isShuffleMode);
  }

  void setShuffleMode(bool enabled) {
    _isShuffleMode = enabled;
    _player.setShuffleModeEnabled(_isShuffleMode);
    _shuffleController.add(_isShuffleMode);
  }

  void cycleLoopMode() {
    switch (_loopMode) {
      case LoopMode.off:
        setLoopMode(LoopMode.all);
      case LoopMode.all:
        setLoopMode(LoopMode.one);
      case LoopMode.one:
        setLoopMode(LoopMode.off);
    }
  }

  void setLoopMode(LoopMode mode) {
    _loopMode = mode;
    _player.setLoopMode(_loopMode);
    _loopModeController.add(_loopMode);
  }

  void _handleSongComplete() {
    if (_loopMode == LoopMode.one) {
      _player.seek(Duration.zero);
      _player.play();
    } else if (_currentIndex < _queue.length - 1 ||
        _loopMode == LoopMode.all) {
      _skipToNextNonBlacklisted();
    }
  }

  Future<void> _skipToNextNonBlacklisted() async {
    if (_queue.isEmpty) return;

    if (_isBlacklisted == null) {
      if (_player.hasNext) {
        await _player.seekToNext();
      } else if (_loopMode == LoopMode.all && _queue.isNotEmpty) {
        await seekToIndex(0);
        await _player.play();
      }
      return;
    }

    int nextIndex = _currentIndex + 1;
    final startIndex = nextIndex;

    while (nextIndex < _queue.length) {
      if (!_isBlacklisted!(_queue[nextIndex].id)) {
        await seekToIndex(nextIndex);
        await _player.play();
        return;
      }
      nextIndex++;
    }

    if (_loopMode == LoopMode.all && startIndex > 0) {
      nextIndex = 0;
      while (nextIndex < startIndex) {
        if (!_isBlacklisted!(_queue[nextIndex].id)) {
          await seekToIndex(nextIndex);
          await _player.play();
          return;
        }
        nextIndex++;
      }
    }
  }

  Future<void> addToQueue(SongModel song) async {
    _queue.add(song);
    _emitQueue();
    if (!_sourceLoaded) {
      // Queue only; source is built on play()/seekToIndex().
      return;
    }
    final concatenating = _player.audioSource;
    if (concatenating is ConcatenatingAudioSource) {
      await concatenating.add(_sourceFor(song));
    } else {
      await _applyQueueToPlayer(initialIndex: _currentIndex, autoPlay: false);
    }
  }

  Future<void> addNext(SongModel song) async {
    final insertIndex = _currentIndex < 0
        ? _queue.length
        : (_currentIndex + 1).clamp(0, _queue.length);
    _queue.insert(insertIndex, song);
    _emitQueue();
    if (!_sourceLoaded) {
      return;
    }
    final concatenating = _player.audioSource;
    if (concatenating is ConcatenatingAudioSource) {
      await concatenating.insert(insertIndex, _sourceFor(song));
    } else {
      await _applyQueueToPlayer(initialIndex: _currentIndex, autoPlay: false);
    }
  }

  Future<void> removeFromQueue(int index) async {
    if (index < 0 || index >= _queue.length) return;

    final removingCurrent = index == _currentIndex;
    _queue.removeAt(index);

    if (_queue.isEmpty) {
      clearQueue();
      return;
    }

    if (index < _currentIndex) {
      _currentIndex--;
    } else if (removingCurrent) {
      _currentIndex = _currentIndex.clamp(0, _queue.length - 1);
    }

    _emitQueue();
    _currentIndexController.add(_currentIndex);
    _currentSongController.add(currentSong);

    if (!_sourceLoaded) return;

    final concatenating = _player.audioSource;
    if (concatenating is ConcatenatingAudioSource) {
      if (index < concatenating.length) {
        await concatenating.removeAt(index);
      }
      if (removingCurrent) {
        await seekToIndex(_currentIndex);
        await _player.play();
      }
    } else {
      await _applyQueueToPlayer(
        initialIndex: _currentIndex,
        autoPlay: removingCurrent,
      );
    }
  }

  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _queue.length) return;
    if (newIndex < 0 || newIndex >= _queue.length) return;
    if (oldIndex == newIndex) return;

    final song = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, song);

    if (oldIndex == _currentIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex++;
    }

    _emitQueue();
    _currentIndexController.add(_currentIndex);

    if (!_sourceLoaded) return;

    final wasPlaying = _player.playing;
    await _applyQueueToPlayer(
      initialIndex: _currentIndex,
      autoPlay: wasPlaying,
    );
  }

  void clearQueue() {
    _queue.clear();
    _currentIndex = -1;
    _sourceLoaded = false;
    _lastEmittedStartedId = null;
    _player.stop();
    _emitQueue();
    _currentIndexController.add(_currentIndex);
    _currentSongController.add(null);
  }

  Future<void> dispose() async {
    await _indexSubscription?.cancel();
    await _processingSubscription?.cancel();
    await _queueController.close();
    await _currentSongController.close();
    await _songStartedController.close();
    await _shuffleController.close();
    await _loopModeController.close();
    await _currentIndexController.close();
    await _player.dispose();
  }
}
