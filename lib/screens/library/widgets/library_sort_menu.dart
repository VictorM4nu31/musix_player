import 'package:flutter/material.dart';
import '../../../providers/songs_provider.dart';

class LibrarySortMenu extends StatelessWidget {
  const LibrarySortMenu({
    super.key,
    required this.currentOption,
    required this.onChanged,
  });

  final SongSortOption currentOption;
  final ValueChanged<SongSortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SongSortOption>(
      icon: const Icon(Icons.sort_rounded),
      tooltip: 'Ordenar por',
      onSelected: onChanged,
      itemBuilder: (context) => [
        _buildMenuItem(
          context,
          value: SongSortOption.title,
          label: 'Título',
          icon: Icons.title,
        ),
        _buildMenuItem(
          context,
          value: SongSortOption.artist,
          label: 'Artista',
          icon: Icons.person_outline,
        ),
        _buildMenuItem(
          context,
          value: SongSortOption.album,
          label: 'Álbum',
          icon: Icons.album_outlined,
        ),
        _buildMenuItem(
          context,
          value: SongSortOption.duration,
          label: 'Duración',
          icon: Icons.timer_outlined,
        ),
      ],
    );
  }

  PopupMenuItem<SongSortOption> _buildMenuItem(
    BuildContext context, {
    required SongSortOption value,
    required String label,
    required IconData icon,
  }) {
    final isSelected = value == currentOption;
    final theme = Theme.of(context);

    return PopupMenuItem<SongSortOption>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? theme.colorScheme.primary : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? theme.colorScheme.primary : null,
              fontWeight: isSelected ? FontWeight.w600 : null,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            Icon(
              Icons.check_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ],
        ],
      ),
    );
  }
}
