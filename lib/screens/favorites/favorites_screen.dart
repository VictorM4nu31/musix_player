import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/song_tile.dart';
import '../../data/models/song_model.dart';
import '../../providers/audio_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../services/favorites/favorites_service.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteSongsProvider);
    final audioService = ref.read(audioPlayerServiceProvider);
    final favoritesService = ref.read(favoritesServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: favoritesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
        data: (songs) {
          if (songs.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'Sin favoritos',
              subtitle: 'Marca tus canciones favoritas y aparecerán aquí',
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  '${songs.length} favoritos',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(
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
                          favoritesService,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSongContextMenu(
    BuildContext context,
    WidgetRef ref,
    SongModel song,
    List<SongModel> songs,
    FavoritesService favoritesService,
  ) {
    final isFavorite = favoritesService.isFavorite(song.id);

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
                leading: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? theme.colorScheme.error : null,
                ),
                title: Text(
                  isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
                ),
                onTap: () {
                  Navigator.pop(context);
                  favoritesService.toggleFavorite(song.id);
                },
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
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('Información'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/songs/${song.id}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Editar información'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/songs/${song.id}/edit');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
