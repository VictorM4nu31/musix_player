import 'package:flutter/material.dart';
import '../../core/widgets/empty_state.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Playlists'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Create playlist
            },
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: const EmptyState(
        icon: Icons.queue_music_rounded,
        title: 'Sin playlists',
        subtitle: 'Crea tu primera playlist para organizar tus canciones',
        actionLabel: 'Crear playlist',
      ),
    );
  }
}
