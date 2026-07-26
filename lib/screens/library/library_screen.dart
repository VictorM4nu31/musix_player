import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/bottom_sheet_drag_handle.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/song_context_menu.dart';
import '../../core/widgets/song_tile.dart';
import '../../data/models/song_model.dart';
import '../../providers/audio_provider.dart';
import '../../providers/blacklist_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/songs_provider.dart';
import '../../services/playlist/playlist_service.dart';
import '../../services/settings/settings_service.dart';
import 'widgets/library_search_bar.dart';
import 'widgets/library_sort_menu.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSongContextMenu(
    BuildContext context,
    WidgetRef ref,
    SongModel song,
  ) {
    final favoritesService = ref.read(favoritesServiceProvider);
    final isFavorite = favoritesService.isFavorite(song.id);
    final blacklistService = ref.read(blacklistServiceProvider);
    final isBlacklisted = blacklistService.isBlacklisted(song.id);
    final playlistService = ref.read(playlistServiceProvider);

    SongContextMenu.show(
      context: context,
      song: song,
      isFavorite: isFavorite,
      isBlacklisted: isBlacklisted,
      onToggleFavorite: () => favoritesService.toggleFavorite(song.id),
      onToggleBlacklist: () => blacklistService.toggleBlacklist(song.id),
      onAddToQueue: () => ref.read(audioPlayerServiceProvider).addToQueue(song),
      onPlayNext: () => ref.read(audioPlayerServiceProvider).addNext(song),
      onAddToPlaylist: () => _showPlaylistPicker(context, song, playlistService),
    );
  }

  void _showPlaylistPicker(
    BuildContext context,
    SongModel song,
    PlaylistService playlistService,
  ) {
    final playlists = playlistService.playlists;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BottomSheetDragHandle(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Agregar a playlist',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (playlists.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No hay playlists creadas'),
                )
              else
                ...playlists.map(
                  (playlist) => ListTile(
                    leading: const Icon(Icons.queue_music_rounded),
                    title: Text(playlist.name),
                    subtitle: Text('${playlist.songIds.length} canciones'),
                    onTap: () {
                      Navigator.pop(context);
                      playlistService.addSongToPlaylist(playlist.id, song.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Agregado a ${playlist.name}')),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handlePermissionAction() async {
    final repo = ref.read(songRepositoryProvider);
    final granted = await repo.hasPermission();
    if (!granted) {
      await repo.openSettings();
    }
    await ref.read(songsProvider.notifier).loadSongs(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final songsState = ref.watch(songsProvider);
    final songsNotifier = ref.read(songsProvider.notifier);

    ref.listen(sortPreferenceProvider, (prev, next) {
      next.whenData((pref) {
        songsNotifier.setSortOption(sortOptionFromPreference(pref));
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca'),
        actions: [
          LibrarySortMenu(
            currentOption: songsNotifier.sortOption,
            onChanged: (option) {
              songsNotifier.setSortOption(option);
              final pref = switch (option) {
                SongSortOption.title => SortPreference.title,
                SongSortOption.artist => SortPreference.artist,
                SongSortOption.album => SortPreference.album,
                SongSortOption.duration => SortPreference.duration,
              };
              ref.read(settingsServiceProvider).setSortPreference(pref);
            },
          ),
          IconButton(
            onPressed: () => songsNotifier.loadSongs(forceRefresh: true),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar biblioteca',
          ),
        ],
      ),
      body: Column(
        children: [
          LibrarySearchBar(
            controller: _searchController,
            onChanged: songsNotifier.setSearchQuery,
          ),
          Expanded(
            child: songsState.when(
              loading: () => const LoadingIndicator(
                message: 'Escaneando biblioteca...',
              ),
              error: (error, stack) {
                final message = error.toString();
                if (message.contains('Permiso')) {
                  return EmptyState(
                    icon: Icons.lock_outline_rounded,
                    title: 'Permiso requerido',
                    subtitle:
                        'Necesitamos acceso a tu música. Si lo denegaste, ábrelo en Ajustes del sistema.',
                    actionLabel: 'Conceder / Abrir ajustes',
                    onAction: _handlePermissionAction,
                  );
                }
                return ErrorView(
                  message: message,
                  onRetry: () => songsNotifier.loadSongs(forceRefresh: true),
                );
              },
              data: (songs) {
                if (songs.isEmpty) {
                  if (_searchController.text.isNotEmpty) {
                    return const EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Sin resultados',
                      subtitle:
                          'No se encontraron canciones con ese término',
                    );
                  }
                  return EmptyState(
                    icon: Icons.library_music_rounded,
                    title: 'Sin canciones',
                    subtitle:
                        'No se encontraron archivos de música en tu dispositivo',
                    actionLabel: 'Actualizar',
                    onAction: () =>
                        songsNotifier.loadSongs(forceRefresh: true),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      child: Text(
                        '${songs.length} canciones',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () =>
                            songsNotifier.loadSongs(forceRefresh: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: songs.length,
                          itemBuilder: (context, index) {
                            final song = songs[index];
                            return SongTile(
                              title: song.title,
                              artist: song.artist,
                              album: song.album,
                              duration: song.duration,
                              artworkUri: song.artworkUri,
                              albumId: song.albumId,
                              onTap: () {
                                final audioService =
                                    ref.read(audioPlayerServiceProvider);
                                audioService.play(song, playlist: songs);
                                context.push('/player');
                              },
                              onMorePressed: () {
                                _showSongContextMenu(context, ref, song);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
