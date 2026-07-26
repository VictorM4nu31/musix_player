import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/song_context_menu.dart';
import '../../core/widgets/song_tile.dart';
import '../../data/models/song_model.dart';
import '../../providers/audio_provider.dart';
import '../../providers/blacklist_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../services/favorites/favorites_service.dart';
import '../../core/widgets/bottom_sheet_drag_handle.dart';

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
                      albumId: song.albumId,
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
      onAddToPlaylist: () {
        final playlists = playlistService.playlists;
        showModalBottomSheet(
          context: context,
          builder: (ctx) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BottomSheetDragHandle(),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Agregar a playlist'),
                  ),
                  if (playlists.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No hay playlists creadas'),
                    )
                  else
                    ...playlists.map(
                      (p) => ListTile(
                        leading: const Icon(Icons.queue_music_rounded),
                        title: Text(p.name),
                        onTap: () {
                          Navigator.pop(ctx);
                          playlistService.addSongToPlaylist(p.id, song.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Agregado a ${p.name}')),
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
      },
    );
  }
}
