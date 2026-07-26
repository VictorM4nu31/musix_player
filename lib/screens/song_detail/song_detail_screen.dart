import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/artwork_image.dart';
import '../../data/models/song_model.dart';
import '../../providers/songs_provider.dart';

class SongDetailScreen extends ConsumerWidget {
  const SongDetailScreen({super.key, required this.songId});

  final int songId;

  SongModel? _findSong(WidgetRef ref) {
    final repo = ref.watch(songRepositoryProvider);
    for (final s in repo.cachedSongs) {
      if (s.id == songId) return s;
    }
    final visible = ref.watch(songsProvider).valueOrNull ?? [];
    for (final s in visible) {
      if (s.id == songId) return s;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsProvider);
    final theme = Theme.of(context);
    final song = _findSong(ref);

    if (song != null) {
      return _buildDetail(context, theme, song);
    }

    return songsAsync.when(
      loading: () => _buildScaffold(
        context,
        theme,
        title: 'Información',
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => _buildScaffold(
        context,
        theme,
        title: 'Información',
        body: Center(child: Text('Error: $e')),
      ),
      data: (_) => _buildScaffold(
        context,
        theme,
        title: 'Información',
        body: const Center(child: Text('Canción no encontrada')),
      ),
    );
  }

  Scaffold _buildScaffold(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required Widget body,
  }) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body,
    );
  }

  Scaffold _buildDetail(BuildContext context, ThemeData theme, SongModel song) {
    final path = song.filePath.isNotEmpty ? song.filePath : (song.contentUri ?? '');
    final format = path.contains('.')
        ? path.split('.').last
        : 'audio';

    return Scaffold(
      appBar: AppBar(title: const Text('Información')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ArtworkImage(
              imageUri: song.artworkUri,
              albumId: song.albumId,
              size: 200,
              borderRadius: 20,
            ),
          ),
          const SizedBox(height: 24),
          _InfoRow(
            icon: Icons.music_note_rounded,
            label: 'Título',
            value: song.title,
          ),
          _InfoRow(
            icon: Icons.person_rounded,
            label: 'Artista',
            value: song.artist,
          ),
          _InfoRow(
            icon: Icons.album_rounded,
            label: 'Álbum',
            value: song.album,
          ),
          if (song.genre != null && song.genre!.isNotEmpty)
            _InfoRow(
              icon: Icons.category_rounded,
              label: 'Género',
              value: song.genre!,
            ),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Año',
            value: song.year > 0 ? song.year.toString() : 'Desconocido',
          ),
          _InfoRow(
            icon: Icons.timer_rounded,
            label: 'Duración',
            value: Formatters.formatDuration(song.duration),
          ),
          _InfoRow(
            icon: Icons.confirmation_number_rounded,
            label: 'Número de pista',
            value: song.track > 0 ? song.track.toString() : 'Desconocido',
          ),
          _InfoRow(
            icon: Icons.storage_rounded,
            label: 'Tamaño',
            value: Formatters.formatFileSize(song.size),
          ),
          _InfoRow(
            icon: Icons.insert_drive_file_rounded,
            label: 'Formato',
            value: format.toUpperCase(),
          ),
          if (path.isNotEmpty)
            _InfoRow(
              icon: Icons.folder_rounded,
              label: 'Ubicación',
              value: path,
              isLongText: true,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLongText = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLongText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 14),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge,
              maxLines: isLongText ? 3 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
