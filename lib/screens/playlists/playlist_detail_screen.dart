import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/song_tile.dart';
import '../../data/models/song_model.dart';
import '../../providers/audio_provider.dart';
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
                    // ignore: deprecated_member_use
                    onReorder: (oldIndex, newIndex) {
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
                  Icons.playlist_remove_rounded,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  'Eliminar de esta playlist',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  playlistService.removeSongFromPlaylist(playlistId, song.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${song.title} eliminada de la playlist'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
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
