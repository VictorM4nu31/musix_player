import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/song_model.dart';
import '../services/favorites/favorites_service.dart';
import 'songs_provider.dart';

final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  final service = FavoritesService();
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
});

final favoritesIdsProvider = StreamProvider<Set<int>>((ref) {
  final service = ref.watch(favoritesServiceProvider);
  return service.favoritesStream;
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

  return favoritesAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (favoriteIds) {
      return songsAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
        data: (songs) {
          final favoriteSongs = songs
              .where((song) => favoriteIds.contains(song.id))
              .toList();
          return AsyncValue.data(favoriteSongs);
        },
      );
    },
  );
});
