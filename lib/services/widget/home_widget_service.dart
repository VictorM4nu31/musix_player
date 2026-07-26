import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/song_model.dart';
import '../audio/audio_player_service.dart';

/// Keeps Android home-screen widgets in sync with playback state.
class HomeWidgetService {
  HomeWidgetService(this._audio);

  static const _providers = [
    'MusixPlayerWidgetProvider',
    'MusixPlayerWidgetSmallProvider',
    'MusixPlayerWidgetLargeProvider',
  ];

  static const _channel = MethodChannel('com.musix_player/music_scanner');

  final AudioPlayerService _audio;
  StreamSubscription<SongModel?>? _songSub;
  StreamSubscription<bool>? _playingSub;
  int? _lastArtAlbumId;
  String? _cachedArtPath;

  Future<void> start() async {
    if (kIsWeb || !Platform.isAndroid) return;

    await _pushState(
      song: _audio.currentSong,
      playing: _audio.player.playing,
    );

    _songSub = _audio.currentSongStream.listen((song) async {
      await _pushState(song: song, playing: _audio.player.playing);
    });

    _playingSub = _audio.playingStream.listen((playing) async {
      await _pushState(song: _audio.currentSong, playing: playing);
    });
  }

  Future<void> _pushState({
    required SongModel? song,
    required bool playing,
  }) async {
    try {
      if (song == null) {
        await HomeWidget.saveWidgetData<String>('title', 'Nada en reproducción');
        await HomeWidget.saveWidgetData<String>('artist', 'Musix Player');
        await HomeWidget.saveWidgetData<String>('album', '');
        await HomeWidget.saveWidgetData<bool>('playing', false);
        await HomeWidget.saveWidgetData<String>('artPath', '');
      } else {
        await HomeWidget.saveWidgetData<String>('title', song.title);
        await HomeWidget.saveWidgetData<String>('artist', song.artist);
        await HomeWidget.saveWidgetData<String>('album', song.album);
        await HomeWidget.saveWidgetData<bool>('playing', playing);

        final artPath = await _resolveArtPath(song);
        await HomeWidget.saveWidgetData<String>('artPath', artPath ?? '');
      }

      for (final name in _providers) {
        await HomeWidget.updateWidget(androidName: name);
      }
    } catch (e) {
      debugPrint('HomeWidgetService: $e');
    }
  }

  Future<String?> _resolveArtPath(SongModel song) async {
    if (_lastArtAlbumId == song.albumId &&
        _cachedArtPath != null &&
        song.albumId > 0) {
      if (await File(_cachedArtPath!).exists()) return _cachedArtPath;
    }

    try {
      if (song.albumId > 0) {
        final bytes = await _channel.invokeMethod<List<int>>(
          'getArtworkBytes',
          {'albumId': song.albumId},
        );
        if (bytes != null && bytes.isNotEmpty) {
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/widget_art_${song.albumId}.jpg');
          await file.writeAsBytes(Uint8List.fromList(bytes), flush: true);
          _lastArtAlbumId = song.albumId;
          _cachedArtPath = file.path;
          return file.path;
        }
      }
    } catch (_) {}

    _lastArtAlbumId = song.albumId;
    _cachedArtPath = null;
    return null;
  }

  Future<void> dispose() async {
    await _songSub?.cancel();
    await _playingSub?.cancel();
  }
}
