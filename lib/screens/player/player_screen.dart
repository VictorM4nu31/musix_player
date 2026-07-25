import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/artwork_image.dart';
import '../../data/models/song_model.dart';
import '../../providers/audio_provider.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final position = ref.watch(positionProvider);
    final duration = ref.watch(durationProvider);
    final audioService = ref.read(audioPlayerServiceProvider);

    return Scaffold(
      body: currentSong.when(
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
        data: (song) {
          if (song == null) return const SizedBox.shrink();
          return _PlayerContent(
            song: song,
            isPlaying: isPlaying.valueOrNull ?? false,
            position: position.valueOrNull ?? Duration.zero,
            duration: duration.valueOrNull,
            audioService: audioService,
          );
        },
      ),
    );
  }
}

class _PlayerContent extends StatelessWidget {
  const _PlayerContent({
    required this.song,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.audioService,
  });

  final SongModel song;
  final bool isPlaying;
  final Duration position;
  final Duration? duration;
  final dynamic audioService;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalDuration = duration ?? song.duration;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withAlpha(40),
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, theme),
            const Spacer(flex: 2),
            _buildArtwork(theme),
            const Spacer(flex: 2),
            _buildSongInfo(theme),
            const SizedBox(height: 24),
            _buildProgressBar(theme, totalDuration),
            const SizedBox(height: 8),
            _buildTimeLabels(theme, totalDuration),
            const SizedBox(height: 24),
            _buildControls(theme),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          ),
          Expanded(
            child: Text(
              'Reproduciendo',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Queue screen
            },
            icon: const Icon(Icons.queue_music_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: AspectRatio(
        aspectRatio: 1,
        child: ArtworkImage(
          imageUri: song.artworkUri,
          size: double.infinity,
          borderRadius: 24,
        ),
      ),
    );
  }

  Widget _buildSongInfo(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            song.title,
            style: theme.textTheme.headlineMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            song.artist,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyMedium?.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme, Duration totalDuration) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          activeTrackColor: theme.colorScheme.primary,
          inactiveTrackColor: theme.colorScheme.primary.withAlpha(40),
          thumbColor: theme.colorScheme.primary,
          overlayColor: theme.colorScheme.primary.withAlpha(30),
        ),
        child: Slider(
          value: position.inMilliseconds.toDouble().clamp(
                0,
                totalDuration.inMilliseconds.toDouble(),
              ),
          max: totalDuration.inMilliseconds.toDouble().clamp(
            1,
            double.infinity,
          ),
          onChanged: (value) {
            audioService.seek(Duration(milliseconds: value.toInt()));
          },
        ),
      ),
    );
  }

  Widget _buildTimeLabels(ThemeData theme, Duration totalDuration) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            Formatters.formatDurationShort(position),
            style: theme.textTheme.bodySmall,
          ),
          Text(
            Formatters.formatDurationShort(totalDuration),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildControls(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: Icons.shuffle_rounded,
            isActive: audioService.isShuffleMode,
            size: 28,
            onTap: () => audioService.toggleShuffle(),
          ),
          _ControlButton(
            icon: Icons.skip_previous_rounded,
            size: 36,
            onTap: () => audioService.seekToPrevious(),
          ),
          _PlayPauseButton(
            isPlaying: isPlaying,
            onTap: () => audioService.togglePlayPause(),
          ),
          _ControlButton(
            icon: Icons.skip_next_rounded,
            size: 36,
            onTap: () => audioService.seekToNext(),
          ),
          _ControlButton(
            icon: _getLoopIcon(audioService.loopMode),
            isActive: audioService.loopMode != LoopMode.off,
            size: 28,
            onTap: () => audioService.cycleLoopMode(),
          ),
        ],
      ),
    );
  }

  IconData _getLoopIcon(dynamic loopMode) {
    if (loopMode.toString().contains('one')) {
      return Icons.repeat_one_rounded;
    }
    return Icons.repeat_rounded;
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.isPlaying,
    required this.onTap,
  });

  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withAlpha(60),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.size = 24,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: onTap,
      icon: Icon(icon),
      iconSize: size,
      color: isActive ? theme.colorScheme.primary : theme.iconTheme.color,
    );
  }
}
