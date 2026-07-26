import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/song_model.dart';
import '../services/favorites/favorites_service.dart';
import '../core/service_locator.dart' as locator;
import 'songs_provider.dart';

final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  return locator.favoritesService;
});

final favoritesIdsProvider = StreamProvider<Set<int>>((ref) {
  final service = ref.watch(favoritesServiceProvider);
  return _seededStream(service.favoriteIds, service.favoritesStream);
});

/// Emits the current value immediately, then forwards all stream events.
/// This prevents widgets from being stuck in loading state when subscribing
/// after the service has already emitted its initial value.
Stream<Set<int>> _seededStream(
  Set<int> currentValue,
  Stream<Set<int>> stream,
) async* {
  yield currentValue;
  yield* stream;
}

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
