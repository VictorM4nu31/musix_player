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

  final _queueController = StreamController<List<SongModel>>.broadcast();
  final _currentSongController = StreamController<SongModel?>.broadcast();
  final _songStartedController = StreamController<SongModel>.broadcast();

  StreamSubscription<int?>? _indexSubscription;
  StreamSubscription<ProcessingState>? _processingSubscription;

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

  void _init() {
    _indexSubscription = _player.currentIndexStream.listen((index) {
      if (index != null) {
        _currentIndex = index;
        final song = currentSong;
        _currentSongController.add(song);
        if (song != null) {
          _songStartedController.add(song);
        }
      }
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

  Future<void> play(SongModel song, {List<SongModel>? playlist}) async {
    if (playlist != null) {
      _queue = List.from(playlist);
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

    _emitQueue();
    _currentSongController.add(currentSong);
    await _loadCurrentSong();
    await _player.play();
  }

  Future<void> _loadCurrentSong() async {
    if (currentSong == null) return;

    final sources = _queue.map((song) {
      return AudioSource.uri(
        Uri.file(song.filePath),
        tag: song.id.toString(),
      );
    }).toList();

    final concatenating = ConcatenatingAudioSource(children: sources);

    await _player.setAudioSource(
      concatenating,
      initialIndex: _currentIndex,
      initialPosition: Duration.zero,
    );
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

  void toggleShuffle() {
    _isShuffleMode = !_isShuffleMode;
    _player.setShuffleModeEnabled(_isShuffleMode);
  }

  void cycleLoopMode() {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
      case LoopMode.all:
        _loopMode = LoopMode.one;
      case LoopMode.one:
        _loopMode = LoopMode.off;
    }
    _player.setLoopMode(_loopMode);
  }

  void _handleSongComplete() {
    if (_loopMode == LoopMode.one) {
      _player.seek(Duration.zero);
      _player.play();
    } else if (_currentIndex < _queue.length - 1 ||
        _loopMode == LoopMode.all) {
      seekToNext();
    }
  }

  Future<void> addToQueue(SongModel song) async {
    _queue.add(song);
    _emitQueue();
  }

  Future<void> addNext(SongModel song) async {
    final insertIndex = _currentIndex + 1;
    _queue.insert(insertIndex, song);
    _emitQueue();
  }

  Future<void> removeFromQueue(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _queue.removeAt(index);
    if (index < _currentIndex) {
      _currentIndex--;
    } else if (index == _currentIndex && _currentIndex >= _queue.length) {
      _currentIndex = _queue.length - 1;
    }
    _emitQueue();
  }

  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _queue.length) return;
    if (newIndex < 0 || newIndex >= _queue.length) return;

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
  }

  void clearQueue() {
    _queue.clear();
    _currentIndex = -1;
    _player.stop();
    _emitQueue();
    _currentSongController.add(null);
  }

  Future<void> dispose() async {
    await _indexSubscription?.cancel();
    await _processingSubscription?.cancel();
    await _queueController.close();
    await _currentSongController.close();
    await _songStartedController.close();
    await _player.dispose();
  }
}
