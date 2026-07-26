import 'package:flutter/services.dart';
import '../../data/models/song_model.dart';

class MusicScannerService {
  static const _channel = MethodChannel('com.musix_player/music_scanner');

  Future<List<SongModel>> scanForSongs() async {
    try {
      final result = await _channel.invokeMethod<List>('getAllSongs');
      if (result == null) return [];

      return result
          .map((e) => SongModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on PlatformException catch (e) {
      throw MusicScannerException(
        'Error al escanear música: ${e.message}',
      );
    }
  }

  Future<String?> getArtworkUri(int albumId) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'getSongArtwork',
        {'albumId': albumId},
      );
      return result;
    } on PlatformException {
      return null;
    }
  }

  Future<Uint8List?> getArtworkBytes(int albumId) async {
    try {
      final result = await _channel.invokeMethod<List<int>>(
        'getArtworkBytes',
        {'albumId': albumId},
      );
      if (result == null) return null;
      return Uint8List.fromList(result);
    } on PlatformException {
      return null;
    }
  }

  Future<bool> updateSongMetadata({
    required int songId,
    String? title,
    String? artist,
    String? album,
    int? year,
    int? track,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'updateSongMetadata',
        {
          'songId': songId,
          'title': ?title,
          'artist': ?artist,
          'album': ?album,
          'year': ?year,
          'track': ?track,
        },
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}

class MusicScannerException implements Exception {
  final String message;
  const MusicScannerException(this.message);

  @override
  String toString() => message;
}
