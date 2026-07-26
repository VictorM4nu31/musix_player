import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/seeded_stream.dart';
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
  return seededStream(service.playlists, service.playlistsStream);
});

final playlistDetailProvider =
    Provider.family<PlaylistModel?, String>((ref, playlistId) {
  final playlistsAsync = ref.watch(playlistsProvider);
  return playlistsAsync.when(
    data: (playlists) {
      for (final p in playlists) {
        if (p.id == playlistId) return p;
      }
      return null;
    },
    loading: () => null,
    error: (_, _) => null,
  );
});

final playlistSongsProvider =
    Provider.family<List<SongModel>, String>((ref, playlistId) {
  final playlist = ref.watch(playlistDetailProvider(playlistId));
  ref.watch(songsProvider);
  final repo = ref.watch(songRepositoryProvider);

  if (playlist == null) return [];

  final byId = {for (final s in repo.cachedSongs) s.id: s};

  return playlist.songIds
      .map((id) => byId[id])
      .whereType<SongModel>()
      .toList();
});
