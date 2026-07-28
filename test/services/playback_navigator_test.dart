import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musix_player/services/audio/playback_navigator.dart';

void main() {
  const linear = [0, 1, 2, 3, 4];
  const shuffled = [2, 0, 4, 1, 3];

  bool Function(int) playableExcept(Set<int> blocked) {
    return (int index) => !blocked.contains(index);
  }

  group('effectiveOrder', () {
    test('returns identity when shuffle off', () {
      expect(
        PlaybackNavigator.effectiveOrder(
          queueLength: 4,
          shuffleEnabled: false,
          shuffleIndices: [3, 2, 1, 0],
        ),
        [0, 1, 2, 3],
      );
    });

    test('returns shuffle indices when enabled and valid', () {
      expect(
        PlaybackNavigator.effectiveOrder(
          queueLength: 4,
          shuffleEnabled: true,
          shuffleIndices: [3, 2, 1, 0],
        ),
        [3, 2, 1, 0],
      );
    });

    test('falls back to identity when shuffle indices invalid', () {
      expect(
        PlaybackNavigator.effectiveOrder(
          queueLength: 4,
          shuffleEnabled: true,
          shuffleIndices: [0, 1],
        ),
        [0, 1, 2, 3],
      );
    });
  });

  group('resolveNext', () {
    test('1 shuffle off loop off next mid', () {
      expect(
        PlaybackNavigator.resolveNext(
          effectiveOrder: linear,
          currentIndex: 1,
          loopMode: LoopMode.off,
          reason: NavigationReason.user,
          isPlayable: playableExcept({}),
        ),
        2,
      );
    });

    test('2 shuffle off loop off next end', () {
      expect(
        PlaybackNavigator.resolveNext(
          effectiveOrder: linear,
          currentIndex: 4,
          loopMode: LoopMode.off,
          reason: NavigationReason.user,
          isPlayable: playableExcept({}),
        ),
        isNull,
      );
    });

    test('3 shuffle on next from 2 goes to 0 not 3', () {
      expect(
        PlaybackNavigator.resolveNext(
          effectiveOrder: shuffled,
          currentIndex: 2,
          loopMode: LoopMode.off,
          reason: NavigationReason.user,
          isPlayable: playableExcept({}),
        ),
        0,
      );
    });

    test('4 shuffle on complete same as user next', () {
      final user = PlaybackNavigator.resolveNext(
        effectiveOrder: shuffled,
        currentIndex: 2,
        loopMode: LoopMode.off,
        reason: NavigationReason.user,
        isPlayable: playableExcept({}),
      );
      final completed = PlaybackNavigator.resolveNext(
        effectiveOrder: shuffled,
        currentIndex: 2,
        loopMode: LoopMode.off,
        reason: NavigationReason.completed,
        isPlayable: playableExcept({}),
      );
      expect(user, 0);
      expect(completed, user);
    });

    test('5 loop one complete returns current', () {
      expect(
        PlaybackNavigator.resolveNext(
          effectiveOrder: shuffled,
          currentIndex: 4,
          loopMode: LoopMode.one,
          reason: NavigationReason.completed,
          isPlayable: playableExcept({}),
        ),
        4,
      );
    });

    test('6 loop one user next advances', () {
      expect(
        PlaybackNavigator.resolveNext(
          effectiveOrder: shuffled,
          currentIndex: 4,
          loopMode: LoopMode.one,
          reason: NavigationReason.user,
          isPlayable: playableExcept({}),
        ),
        1,
      );
    });

    test('7 loop all next on last effective wraps to first', () {
      expect(
        PlaybackNavigator.resolveNext(
          effectiveOrder: linear,
          currentIndex: 4,
          loopMode: LoopMode.all,
          reason: NavigationReason.user,
          isPlayable: playableExcept({}),
        ),
        0,
      );
    });

    test('8 loop all shuffle wrap uses shuffle order', () {
      // shuffled last is 3 → wrap to 2
      expect(
        PlaybackNavigator.resolveNext(
          effectiveOrder: shuffled,
          currentIndex: 3,
          loopMode: LoopMode.all,
          reason: NavigationReason.user,
          isPlayable: playableExcept({}),
        ),
        2,
      );
    });

    test('next skips blacklist in shuffle order', () {
      // from 4 next is 1 (blocked) → 3
      expect(
        PlaybackNavigator.resolveNext(
          effectiveOrder: shuffled,
          currentIndex: 4,
          loopMode: LoopMode.off,
          reason: NavigationReason.user,
          isPlayable: playableExcept({1}),
        ),
        3,
      );
    });

    test('12 all blacklisted except current → null when no wrap', () {
      expect(
        PlaybackNavigator.resolveNext(
          effectiveOrder: linear,
          currentIndex: 2,
          loopMode: LoopMode.off,
          reason: NavigationReason.user,
          isPlayable: playableExcept({0, 1, 3, 4}),
        ),
        isNull,
      );
    });

    test('13 single song loop all next returns same', () {
      expect(
        PlaybackNavigator.resolveNext(
          effectiveOrder: const [0],
          currentIndex: 0,
          loopMode: LoopMode.all,
          reason: NavigationReason.user,
          isPlayable: playableExcept({}),
        ),
        0,
      );
    });

    test('14 single song loop off next returns null', () {
      expect(
        PlaybackNavigator.resolveNext(
          effectiveOrder: const [0],
          currentIndex: 0,
          loopMode: LoopMode.off,
          reason: NavigationReason.user,
          isPlayable: playableExcept({}),
        ),
        isNull,
      );
    });

    test('complete loop off at end returns null', () {
      expect(
        PlaybackNavigator.resolveNext(
          effectiveOrder: linear,
          currentIndex: 4,
          loopMode: LoopMode.off,
          reason: NavigationReason.completed,
          isPlayable: playableExcept({}),
        ),
        isNull,
      );
    });
  });

  group('resolvePrevious', () {
    test('previous mid linear', () {
      expect(
        PlaybackNavigator.resolvePrevious(
          effectiveOrder: linear,
          currentIndex: 3,
          loopMode: LoopMode.off,
          isPlayable: playableExcept({}),
        ),
        2,
      );
    });

    test('9 previous skips blacklist', () {
      expect(
        PlaybackNavigator.resolvePrevious(
          effectiveOrder: linear,
          currentIndex: 3,
          loopMode: LoopMode.off,
          isPlayable: playableExcept({2}),
        ),
        1,
      );
    });

    test('10 previous at start loop off is null', () {
      expect(
        PlaybackNavigator.resolvePrevious(
          effectiveOrder: linear,
          currentIndex: 0,
          loopMode: LoopMode.off,
          isPlayable: playableExcept({}),
        ),
        isNull,
      );
    });

    test('11 previous at start loop all wraps to last playable', () {
      expect(
        PlaybackNavigator.resolvePrevious(
          effectiveOrder: linear,
          currentIndex: 0,
          loopMode: LoopMode.all,
          isPlayable: playableExcept({}),
        ),
        4,
      );
    });

    test('previous shuffle order', () {
      // shuffled: 2,0,4,1,3 — from 4 previous is 0
      expect(
        PlaybackNavigator.resolvePrevious(
          effectiveOrder: shuffled,
          currentIndex: 4,
          loopMode: LoopMode.off,
          isPlayable: playableExcept({}),
        ),
        0,
      );
    });

    test('15 previous skips blacklist gaps', () {
      expect(
        PlaybackNavigator.resolvePrevious(
          effectiveOrder: linear,
          currentIndex: 4,
          loopMode: LoopMode.off,
          isPlayable: playableExcept({3, 2}),
        ),
        1,
      );
    });

    test('loop all previous skips blacklist on wrap', () {
      expect(
        PlaybackNavigator.resolvePrevious(
          effectiveOrder: linear,
          currentIndex: 0,
          loopMode: LoopMode.all,
          isPlayable: playableExcept({4, 3}),
        ),
        2,
      );
    });

    test('loop all next skips blacklist on wrap', () {
      expect(
        PlaybackNavigator.resolveNext(
          effectiveOrder: linear,
          currentIndex: 4,
          loopMode: LoopMode.all,
          reason: NavigationReason.user,
          isPlayable: playableExcept({0, 1}),
        ),
        2,
      );
    });
  });
}
