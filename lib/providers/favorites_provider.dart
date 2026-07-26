import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/seeded_stream.dart';
import '../data/models/song_model.dart';
import '../services/favorites/favorites_service.dart';
import '../core/service_locator.dart' as locator;
import 'songs_provider.dart';

final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  return locator.favoritesService;
});

final favoritesIdsProvider = StreamProvider<Set<int>>((ref) {
  final service = ref.watch(favoritesServiceProvider);
  return seededStream(service.favoriteIds, service.favoritesStream);
});

final isFavoriteProvider = Provider.family<bool, int>((ref, songId) {
  final favoritesAsync = ref.watch(favoritesIdsProvider);
  return favoritesAsync.when(
    data: (ids) => ids.contains(songId),
    loading: () => false,
    error: (_, _) => false,
  );
});

final favoriteSongsProvider = Provider<AsyncValue<List<SongModel>>>((ref) {
  final favoritesAsync = ref.watch(favoritesIdsProvider);
  final songsAsync = ref.watch(songsProvider);
  final repo = ref.watch(songRepositoryProvider);

  return favoritesAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (favoriteIds) {
      return songsAsync.when(
        loading: () {
          if (repo.cachedSongs.isEmpty) return const AsyncValue.loading();
          final favoriteSongs = repo.cachedSongs
              .where((song) => favoriteIds.contains(song.id))
              .toList();
          return AsyncValue.data(favoriteSongs);
        },
        error: (e, st) {
          if (repo.cachedSongs.isEmpty) return AsyncValue.error(e, st);
          final favoriteSongs = repo.cachedSongs
              .where((song) => favoriteIds.contains(song.id))
              .toList();
          return AsyncValue.data(favoriteSongs);
        },
        data: (_) {
          final all = repo.cachedSongs;
          final favoriteSongs =
              all.where((song) => favoriteIds.contains(song.id)).toList();
          return AsyncValue.data(favoriteSongs);
        },
      );
    },
  );
});
