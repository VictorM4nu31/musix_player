import 'package:flutter/material.dart';

enum SongContextAction {
  addToQueue,
  playNext,
  addToPlaylist,
  removeFromQueue,
}

class SongContextMenuItem {
  const SongContextMenuItem({
    required this.action,
    required this.label,
    required this.icon,
  });

  final SongContextAction action;
  final String label;
  final IconData icon;
}

List<SongContextMenuItem> getSongContextMenuItems({
  bool isInQueue = false,
}) {
  final items = <SongContextMenuItem>[
    const SongContextMenuItem(
      action: SongContextAction.addToQueue,
      label: 'Agregar a la cola',
      icon: Icons.playlist_play_rounded,
    ),
    const SongContextMenuItem(
      action: SongContextAction.playNext,
      label: 'Reproducir siguiente',
      icon: Icons.skip_next_rounded,
    ),
  ];

  if (isInQueue) {
    items.add(
      const SongContextMenuItem(
        action: SongContextAction.removeFromQueue,
        label: 'Eliminar de la cola',
        icon: Icons.remove_circle_outline_rounded,
      ),
    );
  }

  return items;
}
