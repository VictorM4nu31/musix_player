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
import '../../providers/history_provider.dart';
import '../../services/history/history_service.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    final audioService = ref.read(audioPlayerServiceProvider);
    final historyService = ref.read(historyServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          historyAsync.when(
            data: (entries) {
              if (entries.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => _showClearDialog(context, ref, historyService),
                icon: const Icon(Icons.delete_sweep_rounded),
                tooltip: 'Limpiar historial',
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (entries) {
          if (entries.isEmpty) {
            return const EmptyState(
              icon: Icons.history_rounded,
              title: 'Sin historial',
              subtitle: 'Las canciones que reproduzcas aparecerán aquí',
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
                  '${entries.length} reproducciones',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final song = entry.song;

                    return SongTile(
                      title: song.title,
                      artist: song.artist,
                      album: song.album,
                      duration: song.duration,
                      artworkUri: song.artworkUri,
                      albumId: song.albumId,
                      onTap: () {
                        final songs = entries.map((e) => e.song).toList();
                        audioService.play(song, playlist: songs);
                        context.push('/player');
                      },
                      onMorePressed: () {
                        _showSongContextMenu(
                          context,
                          ref,
                          song,
                          historyService,
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

  void _showClearDialog(
    BuildContext context,
    WidgetRef ref,
    HistoryService historyService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar historial'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todo el historial de reproducción?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              historyService.clearHistory();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showSongContextMenu(
    BuildContext context,
    WidgetRef ref,
    SongModel song,
    HistoryService historyService,
  ) {
    final blacklistService = ref.read(blacklistServiceProvider);
    final isBlacklisted = blacklistService.isBlacklisted(song.id);
    final favoritesService = ref.read(favoritesServiceProvider);
    final isFavorite = favoritesService.isFavorite(song.id);

    SongContextMenu.show(
      context: context,
      song: song,
      isFavorite: isFavorite,
      isBlacklisted: isBlacklisted,
      onToggleFavorite: () => favoritesService.toggleFavorite(song.id),
      onToggleBlacklist: () => blacklistService.toggleBlacklist(song.id),
      onAddToQueue: () => ref.read(audioPlayerServiceProvider).addToQueue(song),
      onPlayNext: () => ref.read(audioPlayerServiceProvider).addNext(song),
      showRemoveFromHistory: true,
      onRemoveFromHistory: () => historyService.removeEntry(song.id),
    );
  }
}
