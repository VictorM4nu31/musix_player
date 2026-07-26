import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/song_model.dart';
import '../core/service_locator.dart' as locator;
import '../services/blacklist/blacklist_service.dart';
import 'songs_provider.dart';

final blacklistServiceProvider = Provider<BlacklistService>((ref) {
  return locator.blacklistService;
});

final blacklistIdsProvider = StreamProvider<Set<int>>((ref) {
  final service = ref.watch(blacklistServiceProvider);
  return _seededBlacklistStream(service.blacklistedIds, service.blacklistStream);
});

/// Emits the current value immediately, then forwards all stream events.
Stream<Set<int>> _seededBlacklistStream(
  Set<int> currentValue,
  Stream<Set<int>> stream,
) async* {
  yield currentValue;
  yield* stream;
}

final blacklistedSongsProvider = Provider<AsyncValue<List<SongModel>>>((ref) {
  final songsAsync = ref.watch(songsProvider);
  final blacklistIds = ref.watch(blacklistIdsProvider);

  return songsAsync.whenData((songs) {
    final ids = blacklistIds.valueOrNull ?? {};
    return songs.where((s) => ids.contains(s.id)).toList();
  });
});

final isBlacklistedProvider = Provider.family<bool, int>((ref, songId) {
  final blacklistIds = ref.watch(blacklistIdsProvider);
  final ids = blacklistIds.valueOrNull ?? {};
  return ids.contains(songId);
});
