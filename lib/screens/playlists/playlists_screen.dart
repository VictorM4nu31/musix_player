import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/playlist_provider.dart';

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        actions: [
          IconButton(
            onPressed: () => _showCreateDialog(context, ref),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Crear playlist',
          ),
        ],
      ),
      body: playlistsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (playlists) {
          if (playlists.isEmpty) {
            return const EmptyState(
              icon: Icons.queue_music_rounded,
              title: 'Sin playlists',
              subtitle: 'Crea tu primera playlist para organizar tu música',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return _PlaylistTile(
                playlist: playlist,
                onTap: () {
                  context.push('/playlists/${playlist.id}');
                },
                onLongPress: () {
                  _showPlaylistOptions(context, ref, playlist);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Nombre de la playlist',
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) {
                if (controller.text.trim().isNotEmpty) {
                  ref.read(playlistServiceProvider).createPlaylist(
                        controller.text.trim(),
                        description: descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                      );
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: 'Descripción (opcional)',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(playlistServiceProvider).createPlaylist(
                      controller.text.trim(),
                      description: descriptionController.text.trim().isEmpty
                          ? null
                          : descriptionController.text.trim(),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showPlaylistOptions(
    BuildContext context,
    WidgetRef ref,
    dynamic playlist,
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
                  playlist.name,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Editar nombre'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(context, ref, playlist);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_rounded,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  'Eliminar playlist',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(playlistServiceProvider).deletePlaylist(playlist.id);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic playlist,
  ) {
    final controller = TextEditingController(text: playlist.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nombre de la playlist',
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) {
            if (controller.text.trim().isNotEmpty) {
              ref.read(playlistServiceProvider).updatePlaylist(
                    playlist.id,
                    name: controller.text.trim(),
                  );
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(playlistServiceProvider).updatePlaylist(
                      playlist.id,
                      name: controller.text.trim(),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  const _PlaylistTile({
    required this.playlist,
    required this.onTap,
    required this.onLongPress,
  });

  final dynamic playlist;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.queue_music_rounded,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        playlist.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${playlist.songIds.length} canciones',
        style: theme.textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
