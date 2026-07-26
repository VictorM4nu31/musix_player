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
import '../../services/playlist/playlist_service.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  const PlaylistDetailScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlist = ref.watch(playlistDetailProvider(playlistId));
    final songs = ref.watch(playlistSongsProvider(playlistId));
    final audioService = ref.read(audioPlayerServiceProvider);
    final playlistService = ref.read(playlistServiceProvider);

    if (playlist == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Playlist')),
        body: const Center(child: Text('Playlist no encontrada')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name),
        actions: [
          if (songs.isNotEmpty)
            IconButton(
              onPressed: () {
                audioService.play(songs.first, playlist: songs);
                context.push('/player');
              },
              icon: const Icon(Icons.play_circle_filled_rounded),
              tooltip: 'Reproducir playlist',
            ),
        ],
      ),
      body: songs.isEmpty
          ? const EmptyState(
              icon: Icons.music_note_rounded,
              title: 'Playlist vacía',
              subtitle: 'Agrega canciones desde la biblioteca',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Text(
                    '${songs.length} canciones',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: songs.length,
                    onReorderItem: (oldIndex, newIndex) {
                      playlistService.reorderPlaylistSongs(
                        playlistId,
                        oldIndex,
                        newIndex,
                      );
                    },
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return SongTile(
                        key: ValueKey('pl_${playlistId}_${song.id}'),
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
                            playlistService,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _showSongContextMenu(
    BuildContext context,
    WidgetRef ref,
    SongModel song,
    List<SongModel> songs,
    PlaylistService playlistService,
  ) {
    final favoritesService = ref.read(favoritesServiceProvider);
    final isFavorite = favoritesService.isFavorite(song.id);
    final blacklistService = ref.read(blacklistServiceProvider);
    final isBlacklisted = blacklistService.isBlacklisted(song.id);

    SongContextMenu.show(
      context: context,
      song: song,
      isFavorite: isFavorite,
      isBlacklisted: isBlacklisted,
      onToggleFavorite: () => favoritesService.toggleFavorite(song.id),
      onToggleBlacklist: () => blacklistService.toggleBlacklist(song.id),
      onAddToQueue: () => ref.read(audioPlayerServiceProvider).addToQueue(song),
      onPlayNext: () => ref.read(audioPlayerServiceProvider).addNext(song),
      showRemoveFromPlaylist: true,
      onRemoveFromPlaylist: () {
        playlistService.removeSongFromPlaylist(playlistId, song.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${song.title} eliminada de la playlist'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}
