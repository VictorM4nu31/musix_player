import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musix_player/data/models/song_model.dart';
import 'package:musix_player/services/audio/audio_player_service.dart';
import 'package:musix_player/services/audio/playback_navigator.dart';

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

  group('AudioPlayerService navigation peeks (Phase B)', () {
    late AudioPlayerService service;

    setUp(() {
      service = AudioPlayerService();
      service.seedQueueForTest(
        [_song(10), _song(20), _song(30), _song(40), _song(50)],
        currentIndex: 2,
      );
    });

    tearDown(() async {
      await service.dispose();
    });

    test('loop off next mid advances; next at end is null', () {
      expect(service.peekNextIndex(), 3);
      service.seedQueueForTest(
        [_song(10), _song(20), _song(30), _song(40), _song(50)],
        currentIndex: 4,
      );
      expect(service.peekNextIndex(), isNull);
    });

    test('user next and completed next match when loop off', () {
      expect(
        service.peekNextIndex(reason: NavigationReason.user),
        service.peekNextIndex(reason: NavigationReason.completed),
      );
    });

    test('loop one: completed stays; user next advances', () {
      service.setLoopMode(LoopMode.one);
      expect(
        service.peekNextIndex(reason: NavigationReason.completed),
        2,
      );
      expect(
        service.peekNextIndex(reason: NavigationReason.user),
        3,
      );
    });

    test('loop all wraps next and previous', () {
      service.setLoopMode(LoopMode.all);
      service.seedQueueForTest(
        [_song(10), _song(20), _song(30)],
        currentIndex: 2,
      );
      expect(service.peekNextIndex(), 0);
      service.seedQueueForTest(
        [_song(10), _song(20), _song(30)],
        currentIndex: 0,
      );
      expect(service.peekPreviousIndex(), 2);
    });

    test('previous mid and at start', () {
      expect(service.peekPreviousIndex(), 1);
      service.seedQueueForTest(
        [_song(10), _song(20), _song(30)],
        currentIndex: 0,
      );
      service.setLoopMode(LoopMode.off);
      expect(service.peekPreviousIndex(), isNull);
    });

    test('blacklist is skipped on next and previous', () {
      service.setBlacklistChecker((id) => id == 40 || id == 20);
      // queue ids: 10,20,30,40,50 at index 2 (30)
      expect(service.peekNextIndex(), 4); // skip 40
      expect(service.peekPreviousIndex(), 0); // skip 20
    });

    test('single song loop all peeks same index; loop off peeks null', () {
      service.seedQueueForTest([_song(1)], currentIndex: 0);
      service.setLoopMode(LoopMode.all);
      expect(service.peekNextIndex(), 0);
      service.setLoopMode(LoopMode.off);
      expect(service.peekNextIndex(), isNull);
    });

    test('empty queue peeks null', () {
      service.seedQueueForTest([]);
      expect(service.peekNextIndex(), isNull);
      expect(service.peekPreviousIndex(), isNull);
    });
  });

  group('AudioPlayerService playback mode persistence hooks (Phase D)', () {
    late AudioPlayerService service;

    setUp(() {
      service = AudioPlayerService();
    });

    tearDown(() async {
      await service.dispose();
    });

    test('setShuffleMode and setLoopMode notify callback', () {
      final events = <(bool, LoopMode)>[];
      service.onPlaybackModesChanged = (s, l) => events.add((s, l));

      service.setShuffleMode(true);
      service.setLoopMode(LoopMode.all);

      expect(events, [(true, LoopMode.off), (true, LoopMode.all)]);
    });

    test('restorePlaybackModes does not notify callback', () {
      final events = <(bool, LoopMode)>[];
      service.onPlaybackModesChanged = (s, l) => events.add((s, l));

      service.restorePlaybackModes(shuffle: true, loopMode: LoopMode.one);

      expect(service.isShuffleMode, isTrue);
      expect(service.loopMode, LoopMode.one);
      expect(events, isEmpty);
    });

    test('cycleLoopMode order off → all → one → off', () {
      expect(service.loopMode, LoopMode.off);
      service.cycleLoopMode();
      expect(service.loopMode, LoopMode.all);
      service.cycleLoopMode();
      expect(service.loopMode, LoopMode.one);
      service.cycleLoopMode();
      expect(service.loopMode, LoopMode.off);
    });
  });
}
