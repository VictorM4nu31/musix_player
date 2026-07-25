import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/song_model.dart';
import '../data/repositories/song_repository.dart';

enum SongSortOption { title, artist, album, duration }

final songRepositoryProvider = Provider<SongRepository>((ref) {
  return SongRepository();
});

final songsProvider =
    StateNotifierProvider<SongsNotifier, AsyncValue<List<SongModel>>>((ref) {
  return SongsNotifier(ref.read(songRepositoryProvider));
});

class SongsNotifier extends StateNotifier<AsyncValue<List<SongModel>>> {
  SongsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSongs();
  }

  final SongRepository _repository;
  SongSortOption _sortOption = SongSortOption.title;
  String _searchQuery = '';

  SongSortOption get sortOption => _sortOption;
  String get searchQuery => _searchQuery;

  Future<void> loadSongs({bool forceRefresh = false}) async {
    state = const AsyncValue.loading();
    try {
      final songs = await _repository.loadSongs(forceRefresh: forceRefresh);
      state = AsyncValue.data(_applyFilters(songs));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void setSortOption(SongSortOption option) {
    _sortOption = option;
    final currentSongs = state.valueOrNull ?? [];
    state = AsyncValue.data(_applySorting(currentSongs));
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    final allSongs = _repository.cachedSongs;
    state = AsyncValue.data(_applyFilters(allSongs));
  }

  List<SongModel> _applyFilters(List<SongModel> songs) {
    var filtered = songs;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = songs.where((song) {
        return song.title.toLowerCase().contains(query) ||
            song.artist.toLowerCase().contains(query) ||
            song.album.toLowerCase().contains(query);
      }).toList();
    }
    return _applySorting(filtered);
  }

  List<SongModel> _applySorting(List<SongModel> songs) {
    final sorted = List<SongModel>.from(songs);
    switch (_sortOption) {
      case SongSortOption.title:
        sorted.sort((a, b) => a.title.compareTo(b.title));
      case SongSortOption.artist:
        sorted.sort((a, b) => a.artist.compareTo(b.artist));
      case SongSortOption.album:
        sorted.sort((a, b) => a.album.compareTo(b.album));
      case SongSortOption.duration:
        sorted.sort((a, b) => a.duration.compareTo(b.duration));
    }
    return sorted;
  }
}
