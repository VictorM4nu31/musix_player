import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/song_model.dart';
import 'bottom_sheet_drag_handle.dart';

class SongContextMenu {
  static void show({
    required BuildContext context,
    required SongModel song,
    required bool isFavorite,
    required bool isBlacklisted,
    required VoidCallback onToggleFavorite,
    required VoidCallback onToggleBlacklist,
    required VoidCallback onAddToQueue,
    required VoidCallback onPlayNext,
    VoidCallback? onAddToPlaylist,
    bool showRemoveFromHistory = false,
    VoidCallback? onRemoveFromHistory,
    bool showRemoveFromPlaylist = false,
    VoidCallback? onRemoveFromPlaylist,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final sheetTheme = Theme.of(context);
        final maxH = MediaQuery.of(context).size.height * 0.65;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BottomSheetDragHandle(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    song.title,
                    style: sheetTheme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showRemoveFromPlaylist &&
                            onRemoveFromPlaylist != null)
                          ListTile(
                            leading: Icon(
                              Icons.playlist_remove_rounded,
                              color: sheetTheme.colorScheme.error,
                            ),
                            title: Text(
                              'Eliminar de esta playlist',
                              style:
                                  TextStyle(color: sheetTheme.colorScheme.error),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              onRemoveFromPlaylist();
                            },
                          ),
                        if (showRemoveFromHistory &&
                            onRemoveFromHistory != null)
                          ListTile(
                            leading: Icon(
                              Icons.delete_outline_rounded,
                              color: sheetTheme.colorScheme.error,
                            ),
                            title: Text(
                              'Eliminar del historial',
                              style:
                                  TextStyle(color: sheetTheme.colorScheme.error),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              onRemoveFromHistory();
                            },
                          ),
                        ListTile(
                          leading: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color:
                                isFavorite ? sheetTheme.colorScheme.error : null,
                          ),
                          title: Text(
                            isFavorite
                                ? 'Quitar de favoritos'
                                : 'Agregar a favoritos',
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            onToggleFavorite();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.playlist_play_rounded),
                          title: const Text('Agregar a la cola'),
                          onTap: () {
                            Navigator.pop(context);
                            onAddToQueue();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.skip_next_rounded),
                          title: const Text('Reproducir siguiente'),
                          onTap: () {
                            Navigator.pop(context);
                            onPlayNext();
                          },
                        ),
                        if (onAddToPlaylist != null)
                          ListTile(
                            leading: const Icon(Icons.playlist_add_rounded),
                            title: const Text('Agregar a playlist'),
                            onTap: () {
                              Navigator.pop(context);
                              onAddToPlaylist();
                            },
                          ),
                        ListTile(
                          leading: Icon(
                            isBlacklisted
                                ? Icons.check_circle_rounded
                                : Icons.block_rounded,
                            color: isBlacklisted
                                ? sheetTheme.colorScheme.error
                                : null,
                          ),
                          title: Text(
                            isBlacklisted
                                ? 'Quitar de lista negra'
                                : 'Agregar a lista negra',
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            onToggleBlacklist();
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
