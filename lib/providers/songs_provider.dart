import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/song_model.dart';
import '../data/repositories/song_repository.dart';
import '../services/settings/settings_service.dart';
import 'blacklist_provider.dart';
import 'repository_providers.dart';
import 'settings_provider.dart';

export 'repository_providers.dart' show songRepositoryProvider;

enum SongSortOption { title, artist, album, duration }

SongSortOption sortOptionFromPreference(SortPreference preference) {
  switch (preference) {
    case SortPreference.title:
      return SongSortOption.title;
    case SortPreference.artist:
      return SongSortOption.artist;
    case SortPreference.album:
      return SongSortOption.album;
    case SortPreference.duration:
      return SongSortOption.duration;
  }
}

final songsProvider =
    StateNotifierProvider<SongsNotifier, AsyncValue<List<SongModel>>>((ref) {
  final notifier = SongsNotifier(
    ref.read(songRepositoryProvider),
    initialSort: sortOptionFromPreference(
      ref.read(settingsServiceProvider).sortPreference,
    ),
  );

  ref.listen(blacklistIdsProvider, (previous, next) {
    next.whenData(notifier.updateBlacklist);
  });

  // Apply current blacklist immediately if already loaded.
  final current = ref.read(blacklistIdsProvider).valueOrNull;
  if (current != null) {
    notifier.updateBlacklist(current);
  }

  return notifier;
});

class SongsNotifier extends StateNotifier<AsyncValue<List<SongModel>>> {
  SongsNotifier(
    this._repository, {
    SongSortOption initialSort = SongSortOption.title,
  })  : _sortOption = initialSort,
        super(const AsyncValue.loading()) {
    loadSongs();
  }

  final SongRepository _repository;
  SongSortOption _sortOption;
  String _searchQuery = '';
  Set<int> _blacklistIds = {};
  List<SongModel> _allSongs = [];

  SongSortOption get sortOption => _sortOption;
  String get searchQuery => _searchQuery;

  void updateBlacklist(Set<int> ids) {
    _blacklistIds = Set<int>.from(ids);
    reapplyFilters();
  }

  void reapplyFilters() {
    if (state is AsyncLoading && _allSongs.isEmpty) return;
    if (_allSongs.isEmpty && state.hasError) return;
    if (_allSongs.isEmpty && !state.hasValue) return;
    state = AsyncValue.data(_applyFilters(_allSongs));
  }

  Future<void> loadSongs({bool forceRefresh = false}) async {
    state = const AsyncValue.loading();
    try {
      final songs = await _repository.loadSongs(forceRefresh: forceRefresh);
      _allSongs = songs;
      state = AsyncValue.data(_applyFilters(songs));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void setSortOption(SongSortOption option) {
    _sortOption = option;
    reapplyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    reapplyFilters();
  }

  List<SongModel> _applyFilters(List<SongModel> songs) {
    var filtered = songs.where((s) => !_blacklistIds.contains(s.id)).toList();
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((song) {
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
        sorted.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case SongSortOption.artist:
        sorted.sort(
          (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
        );
      case SongSortOption.album:
        sorted.sort(
          (a, b) => a.album.toLowerCase().compareTo(b.album.toLowerCase()),
        );
      case SongSortOption.duration:
        sorted.sort((a, b) => a.duration.compareTo(b.duration));
    }
    return sorted;
  }
}
