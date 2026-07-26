import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/playlist_model.dart';
import '../data/models/song_model.dart';
import '../services/playlist/playlist_service.dart';
import '../core/service_locator.dart' as locator;
import 'songs_provider.dart';

final playlistServiceProvider = Provider<PlaylistService>((ref) {
  return locator.playlistService;
});

final playlistsProvider = StreamProvider<List<PlaylistModel>>((ref) {
  final service = ref.watch(playlistServiceProvider);
  return _seededStream(service.playlists, service.playlistsStream);
});

/// Emits the current value immediately, then forwards all stream events.
Stream<List<PlaylistModel>> _seededStream(
  List<PlaylistModel> currentValue,
  Stream<List<PlaylistModel>> stream,
) async* {
  yield currentValue;
  yield* stream;
}

final playlistDetailProvider =
    Provider.family<PlaylistModel?, String>((ref, playlistId) {
  final playlistsAsync = ref.watch(playlistsProvider);
  return playlistsAsync.when(
    data: (playlists) {
      try {
        return playlists.firstWhere((p) => p.id == playlistId);
      } catch (_) {
        return null;
      }
    },
    loading: () => null,
    error: (_, _) => null,
  );
});

final playlistSongsProvider =
    Provider.family<List<SongModel>, String>((ref, playlistId) {
  final playlist = ref.watch(playlistDetailProvider(playlistId));
  final songsAsync = ref.watch(songsProvider);

  if (playlist == null) return [];

  return songsAsync.when(
    data: (songs) {
      return playlist.songIds
          .where((id) => songs.any((s) => s.id == id))
          .map((id) => songs.firstWhere((s) => s.id == id))
          .toList();
    },
    loading: () => [],
    error: (_, _) => [],
  );
});
