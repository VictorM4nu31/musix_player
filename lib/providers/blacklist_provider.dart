import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/seeded_stream.dart';
import '../data/models/song_model.dart';
import '../core/service_locator.dart' as locator;
import '../services/blacklist/blacklist_service.dart';
import 'songs_provider.dart';

final blacklistServiceProvider = Provider<BlacklistService>((ref) {
  return locator.blacklistService;
});

final blacklistIdsProvider = StreamProvider<Set<int>>((ref) {
  final service = ref.watch(blacklistServiceProvider);
  return seededStream(service.blacklistedIds, service.blacklistStream);
});

final blacklistedSongsProvider = Provider<AsyncValue<List<SongModel>>>((ref) {
  final blacklistIds = ref.watch(blacklistIdsProvider);
  // Rebuild when library finishes loading.
  ref.watch(songsProvider);
  final repo = ref.watch(songRepositoryProvider);

  return blacklistIds.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (ids) {
      final songs =
          repo.cachedSongs.where((s) => ids.contains(s.id)).toList();
      return AsyncValue.data(songs);
    },
  );
});

final isBlacklistedProvider = Provider.family<bool, int>((ref, songId) {
  final blacklistIds = ref.watch(blacklistIdsProvider);
  final ids = blacklistIds.valueOrNull ?? {};
  return ids.contains(songId);
});
