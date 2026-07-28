import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/theme_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/song_model.dart';
import '../../providers/audio_provider.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(queueProvider);
    final currentIndex = ref.watch(currentIndexProvider).valueOrNull ?? -1;
    final audioService = ref.read(audioPlayerServiceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cola de reproducción'),
        actions: [
          if (queueAsync.hasValue && queueAsync.value!.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, audioService),
              child: Text(
                'Vaciar',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
        ],
      ),
      body: queueAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
        data: (queue) {
          if (queue.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.queue_music_rounded,
                    size: 64,
                    color: theme.colorScheme.primary.withAlpha(80),
                  ),
                  const SizedBox(height: 16),
                  Text('Cola vacía', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega canciones desde la biblioteca',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: queue.length,
            onReorderItem: (oldIndex, newIndex) {
              audioService.reorderQueue(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final song = queue[index];
              final isCurrentSong = index == currentIndex;

              return _QueueTile(
                key: ValueKey('queue_${song.id}_$index'),
                song: song,
                index: index,
                isCurrentSong: isCurrentSong,
                onTap: () => audioService.seekToIndex(index),
                onRemove: () => audioService.removeFromQueue(index),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmClear(BuildContext context, dynamic audioService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar cola'),
        content: const Text(
          '¿Quieres eliminar todas las canciones de la cola?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              audioService.clearQueue();
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
}

class _QueueTile extends StatelessWidget {
  const _QueueTile({
    super.key,
    required this.song,
    required this.index,
    required this.isCurrentSong,
    required this.onTap,
    required this.onRemove,
  });

  final SongModel song;
  final int index;
  final bool isCurrentSong;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: key!,
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(
            theme.extension<MusixThemeTokens>()?.radiusMd ?? 12,
          ),
        ),
        child: Icon(
          Icons.delete_rounded,
          color: theme.colorScheme.onError,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            theme.extension<MusixThemeTokens>()?.radiusMd ?? 12,
          ),
          color: isCurrentSong
              ? theme.colorScheme.primary.withAlpha(25)
              : Colors.transparent,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCurrentSong)
                Icon(
                  Icons.equalizer_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                )
              else
                SizedBox(
                  width: 24,
                  child: Text(
                    '${index + 1}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: isCurrentSong ? FontWeight.w600 : FontWeight.w400,
              color: isCurrentSong ? theme.colorScheme.primary : null,
            ),
          ),
          subtitle: Text(
            '${song.artist} · ${Formatters.formatDurationShort(song.duration)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          trailing: ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle_rounded),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
