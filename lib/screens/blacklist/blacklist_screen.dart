import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/song_tile.dart';
import '../../providers/audio_provider.dart';
import '../../providers/blacklist_provider.dart';

class BlacklistScreen extends ConsumerWidget {
  const BlacklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blacklistedAsync = ref.watch(blacklistedSongsProvider);
    final audioService = ref.read(audioPlayerServiceProvider);
    final blacklistService = ref.read(blacklistServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista negra'),
        actions: [
          blacklistedAsync.when(
            data: (songs) {
              if (songs.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => _showClearDialog(context, ref, blacklistService),
                icon: const Icon(Icons.delete_sweep_rounded),
                tooltip: 'Vaciar lista negra',
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: blacklistedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (songs) {
          if (songs.isEmpty) {
            return const EmptyState(
              icon: Icons.block_rounded,
              title: 'Sin canciones bloqueadas',
              subtitle:
                  'Las canciones en la lista negra no se reproducirán automáticamente',
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
                  '${songs.length} bloqueadas',
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
                        audioService.play(song);
                        context.push('/player');
                      },
                      onMorePressed: () {
                        _showSongContextMenu(
                          context,
                          ref,
                          song,
                          blacklistService,
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
    dynamic blacklistService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar lista negra'),
        content: const Text(
          '¿Estás seguro de que quieres quitar todas las canciones de la lista negra?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              blacklistService.clearBlacklist();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }

  void _showSongContextMenu(
    BuildContext context,
    WidgetRef ref,
    dynamic song,
    dynamic blacklistService,
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
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Quitar de lista negra'),
                onTap: () {
                  Navigator.pop(context);
                  blacklistService.removeFromBlacklist(song.id);
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
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
