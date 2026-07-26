import 'package:flutter_test/flutter_test.dart';
import 'package:musix_player/data/models/song_model.dart';

void main() {
  group('SongModel', () {
    test('fromMap supports legacy maps without contentUri', () {
      final song = SongModel.fromMap({
        'id': 1,
        'title': 'Track',
        'artist': 'Artist',
        'album': 'Album',
        'duration': 120000,
        'filePath': '/sdcard/Music/a.mp3',
        'albumId': 9,
        'size': 1024,
        'year': 2020,
        'track': 1,
      });

      expect(song.id, 1);
      expect(song.contentUri, isNull);
      expect(song.playbackUri, Uri.file('/sdcard/Music/a.mp3'));
    });

    test('playbackUri prefers contentUri', () {
      const song = SongModel(
        id: 2,
        title: 'T',
        artist: 'A',
        album: 'Al',
        duration: Duration(seconds: 10),
        filePath: '/path/x.mp3',
        contentUri: 'content://media/external/audio/media/2',
        albumId: 1,
        size: 1,
        year: 0,
        track: 0,
      );

      expect(
        song.playbackUri.toString(),
        'content://media/external/audio/media/2',
      );
    });

    test('toMap/fromMap roundtrip keeps contentUri', () {
      const original = SongModel(
        id: 3,
        title: 'Hello',
        artist: 'World',
        album: 'LP',
        duration: Duration(milliseconds: 5000),
        filePath: '',
        contentUri: 'content://media/external/audio/media/3',
        albumId: 4,
        size: 99,
        year: 1999,
        track: 2,
        genre: 'Rock',
        artworkUri: 'content://media/external/audio/albumart/4',
      );

      final restored = SongModel.fromMap(original.toMap());
      expect(restored.id, original.id);
      expect(restored.contentUri, original.contentUri);
      expect(restored.artworkUri, original.artworkUri);
      expect(restored.genre, 'Rock');
    });
  });
}
