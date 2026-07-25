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
}

class MusicScannerException implements Exception {
  final String message;
  const MusicScannerException(this.message);

  @override
  String toString() => message;
}
