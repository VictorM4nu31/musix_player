import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musix_player/data/models/song_model.dart';
import 'package:musix_player/services/audio/audio_player_service.dart';

SongModel _song(int id) => SongModel(
      id: id,
      title: 'Song $id',
      artist: 'Artist',
      album: 'Album',
      duration: const Duration(seconds: 60),
      filePath: '/tmp/song_$id.mp3',
      contentUri: null,
      albumId: id,
      size: 1000,
      year: 2020,
      track: id,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioPlayerService queue state (no platform load)', () {
    late AudioPlayerService service;

    setUp(() {
      service = AudioPlayerService();
    });

    tearDown(() async {
      await service.dispose();
    });

    test('addToQueue and addNext update in-memory queue order', () async {
      await service.addToQueue(_song(1));
      await service.addToQueue(_song(2));
      expect(service.queue.map((s) => s.id), [1, 2]);

      await service.addNext(_song(3));
      // currentIndex is -1 before play → insert at end
      expect(service.queue.map((s) => s.id), [1, 2, 3]);
    });

    test('setShuffleMode and setLoopMode update getters and streams', () async {
      expect(service.isShuffleMode, isFalse);
      expect(service.loopMode, LoopMode.off);

      final shuffleEvents = <bool>[];
      final loopEvents = <LoopMode>[];
      final shuffleSub = service.shuffleModeStream.listen(shuffleEvents.add);
      final loopSub = service.loopModeStream.listen(loopEvents.add);

      service.setShuffleMode(true);
      service.setLoopMode(LoopMode.one);
      await Future<void>.delayed(Duration.zero);

      expect(service.isShuffleMode, isTrue);
      expect(service.loopMode, LoopMode.one);
      expect(shuffleEvents, contains(true));
      expect(loopEvents, contains(LoopMode.one));

      service.cycleLoopMode();
      expect(service.loopMode, LoopMode.off);

      await shuffleSub.cancel();
      await loopSub.cancel();
    });

    test('clearQueue empties state', () async {
      await service.addToQueue(_song(5));
      service.clearQueue();
      expect(service.queue, isEmpty);
      expect(service.currentIndex, -1);
      expect(service.currentSong, isNull);
    });

    test('reorderQueue updates list indices without loading source', () async {
      await service.addToQueue(_song(1));
      await service.addToQueue(_song(2));
      await service.addToQueue(_song(3));

      await service.reorderQueue(0, 2);
      expect(service.queue.map((s) => s.id), [2, 3, 1]);
    });

    test('removeFromQueue updates list', () async {
      await service.addToQueue(_song(1));
      await service.addToQueue(_song(2));
      await service.removeFromQueue(0);
      expect(service.queue.map((s) => s.id), [2]);
    });
  });
}
