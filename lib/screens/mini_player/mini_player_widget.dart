import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/artwork_image.dart';
import '../../providers/audio_provider.dart';

class MiniPlayerWidget extends ConsumerWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final audioService = ref.read(audioPlayerServiceProvider);
    final theme = Theme.of(context);

    return currentSong.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (song) {
        if (song == null) {
          return const SizedBox.shrink();
        }

        final playing = isPlaying.valueOrNull ?? false;

        return Semantics(
          label: 'Reproduciendo ${song.title} de ${song.artist}',
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: theme.bottomNavigationBarTheme.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withAlpha(15),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/player'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      AnimatedScale(
                        scale: playing ? 1.0 : 0.92,
                        duration: const Duration(milliseconds: 300),
                        child: ArtworkImage(
                          imageUri: song.artworkUri,
                          albumId: song.albumId,
                          size: 44,
                          borderRadius: 8,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: playing ? 'Pausar' : 'Reproducir',
                        onPressed: () => audioService.togglePlayPause(),
                        icon: Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Siguiente',
                        onPressed: () => audioService.seekToNext(),
                        icon: Icon(
                          Icons.skip_next_rounded,
                          color: theme.textTheme.bodySmall?.color,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
