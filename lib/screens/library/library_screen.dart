import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/song_tile.dart';
import '../../providers/audio_provider.dart';
import '../../providers/songs_provider.dart';
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
    dynamic song,
    List<dynamic> songs,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  song.title,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.playlist_play_rounded),
                title: const Text('Agregar a la cola'),
                onTap: () {
                  Navigator.pop(context);
                  ref
                      .read(audioPlayerServiceProvider)
                      .addToQueue(song);
                },
              ),
              ListTile(
                leading: const Icon(Icons.skip_next_rounded),
                title: const Text('Reproducir siguiente'),
                onTap: () {
                  Navigator.pop(context);
                  ref
                      .read(audioPlayerServiceProvider)
                      .addNext(song);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final songsState = ref.watch(songsProvider);
    final songsNotifier = ref.read(songsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca'),
        actions: [
          LibrarySortMenu(
            currentOption: songsNotifier.sortOption,
            onChanged: songsNotifier.setSortOption,
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
                        'Necesitamos acceso a tu música para mostrar tu biblioteca',
                    actionLabel: 'Conceder permiso',
                    onAction: () => songsNotifier.loadSongs(forceRefresh: true),
                  );
                }
                return ErrorView(
                  message: message,
                  onRetry: () =>
                      songsNotifier.loadSongs(forceRefresh: true),
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
                              onTap: () {
                                final audioService =
                                    ref.read(audioPlayerServiceProvider);
                                audioService.play(
                                  song,
                                  playlist: songs,
                                );
                                context.push('/player');
                              },
                              onMorePressed: () {
                                _showSongContextMenu(
                                  context,
                                  ref,
                                  song,
                                  songs,
                                );
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
