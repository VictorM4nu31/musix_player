import 'package:just_audio/just_audio.dart';

enum NavigationReason { user, completed }

/// Pure playback navigation (next/previous) independent of the audio engine.
///
/// [effectiveOrder] is a permutation of queue indices (identity or shuffle).
class PlaybackNavigator {
  const PlaybackNavigator._();

  /// Resolves the next playable queue index, or null if none.
  ///
  /// When [reason] is [NavigationReason.completed] and [loopMode] is
  /// [LoopMode.one], returns [currentIndex] so the caller can restart.
  /// User-initiated next always advances (ignores loop-one).
  static int? resolveNext({
    required List<int> effectiveOrder,
    required int currentIndex,
    required LoopMode loopMode,
    required NavigationReason reason,
    required bool Function(int queueIndex) isPlayable,
  }) {
    if (effectiveOrder.isEmpty || currentIndex < 0) return null;

    if (reason == NavigationReason.completed && loopMode == LoopMode.one) {
      return isPlayable(currentIndex) ? currentIndex : null;
    }

    final pos = effectiveOrder.indexOf(currentIndex);
    if (pos < 0) return null;

    final allowWrap = loopMode == LoopMode.all;
    final n = effectiveOrder.length;

    for (var step = 1; step <= n; step++) {
      var nextPos = pos + step;
      if (nextPos >= n) {
        if (!allowWrap) return null;
        nextPos %= n;
      }
      final idx = effectiveOrder[nextPos];
      if (isPlayable(idx)) {
        if (idx == currentIndex && !allowWrap) return null;
        return idx;
      }
      if (!allowWrap && pos + step >= n) return null;
    }

    return null;
  }

  /// Resolves the previous playable queue index, or null if none.
  ///
  /// Does not handle the "restart if position > 3s" rule; the caller does.
  static int? resolvePrevious({
    required List<int> effectiveOrder,
    required int currentIndex,
    required LoopMode loopMode,
    required bool Function(int queueIndex) isPlayable,
  }) {
    if (effectiveOrder.isEmpty || currentIndex < 0) return null;

    final pos = effectiveOrder.indexOf(currentIndex);
    if (pos < 0) return null;

    final allowWrap = loopMode == LoopMode.all;
    final n = effectiveOrder.length;

    for (var step = 1; step <= n; step++) {
      var prevPos = pos - step;
      if (prevPos < 0) {
        if (!allowWrap) return null;
        prevPos = (prevPos % n + n) % n;
      }
      final idx = effectiveOrder[prevPos];
      if (isPlayable(idx)) {
        if (idx == currentIndex && !allowWrap) return null;
        return idx;
      }
      if (!allowWrap && pos - step < 0) return null;
    }

    return null;
  }

  /// Builds identity order `0..length-1`, or [shuffleIndices] when valid.
  static List<int> effectiveOrder({
    required int queueLength,
    required bool shuffleEnabled,
    List<int>? shuffleIndices,
  }) {
    if (queueLength <= 0) return const [];
    if (shuffleEnabled &&
        shuffleIndices != null &&
        shuffleIndices.length == queueLength) {
      return List<int>.from(shuffleIndices);
    }
    return List<int>.generate(queueLength, (i) => i);
  }
}
