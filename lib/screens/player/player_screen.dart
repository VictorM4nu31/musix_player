import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import '../../app/theme/theme_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/animated_favorite_button.dart';
import '../../core/widgets/pixel_effects.dart';
import '../../core/widgets/themed_slider_thumb.dart';
import '../../data/models/song_model.dart';
import '../../providers/audio_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../services/audio/audio_player_service.dart';
import '../../visual/widgets/player_visual_shell.dart';

enum _PlayerLayout { compact, normal, wide }

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final position = ref.watch(positionProvider);
    final duration = ref.watch(durationProvider);
    final audioService = ref.read(audioPlayerServiceProvider);
    final shuffle = ref.watch(shuffleModeProvider).valueOrNull ?? false;
    final loopMode = ref.watch(loopModeProvider).valueOrNull ?? LoopMode.off;

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
            isShuffle: shuffle,
            loopMode: loopMode,
          );
        },
      ),
    );
  }
}

class _PlayerContent extends ConsumerWidget {
  const _PlayerContent({
    required this.song,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.audioService,
    required this.isShuffle,
    required this.loopMode,
  });

  final SongModel song;
  final bool isPlaying;
  final Duration position;
  final Duration? duration;
  final AudioPlayerService audioService;
  final bool isShuffle;
  final LoopMode loopMode;

  _PlayerLayout _layoutFor(BoxConstraints c) {
    if (c.maxWidth >= 600 && c.maxWidth > c.maxHeight) {
      return _PlayerLayout.wide;
    }
    if (c.maxHeight < 640 || c.maxWidth < 360) {
      return _PlayerLayout.compact;
    }
    return _PlayerLayout.normal;
  }

  double _artworkSide(BoxConstraints c, _PlayerLayout layout) {
    final shortest = c.biggest.shortestSide;
    return switch (layout) {
      _PlayerLayout.compact => (shortest * 0.52).clamp(140.0, 240.0),
      _PlayerLayout.normal => (shortest * 0.72).clamp(200.0, 360.0),
      _PlayerLayout.wide => (c.maxHeight * 0.62).clamp(180.0, 420.0),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(song.id));
    final theme = Theme.of(context);
    final tokens = context.musixThemeOrNull;
    final totalDuration = duration ?? song.duration;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            tokens?.playerGradientStart ??
                theme.colorScheme.primary.withAlpha(40),
            tokens?.playerGradientEnd ?? theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: ScanlineOverlay()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final layout = _layoutFor(constraints);
                final artSide = _artworkSide(constraints, layout);
                final hPad = layout == _PlayerLayout.compact ? 16.0 : 24.0;
                final playSize = tokens?.playButtonSize ??
                    (constraints.maxWidth * 0.18).clamp(56.0, 76.0);

                final appBar = _PlayerAppBar(
                  isFavorite: isFavorite,
                  onToggleFavorite: () {
                    ref.read(favoritesServiceProvider).toggleFavorite(song.id);
                  },
                );

                final artwork = PlayerVisualShell(
                  song: song,
                  isPlaying: isPlaying,
                  reduceMotion: reduceMotion,
                  side: artSide,
                );

                final info = _PlayerSongInfo(song: song, textScale: textScale);

                final progress = _PlayerProgress(
                  position: position,
                  totalDuration: totalDuration,
                  onSeek: (d) => audioService.seek(d),
                );

                final controls = _PlayerControls(
                  isPlaying: isPlaying,
                  isShuffle: isShuffle,
                  loopMode: loopMode,
                  playSize: playSize,
                  compact: layout == _PlayerLayout.compact,
                  onShuffle: audioService.toggleShuffle,
                  onPrevious: audioService.seekToPrevious,
                  onPlayPause: audioService.togglePlayPause,
                  onNext: audioService.seekToNext,
                  onLoop: audioService.cycleLoopMode,
                );

                if (layout == _PlayerLayout.wide) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
                    child: Column(
                      children: [
                        appBar,
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Center(child: artwork),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 4,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      info,
                                      const SizedBox(height: 20),
                                      progress,
                                      const SizedBox(height: 20),
                                      controls,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final body = Column(
                  children: [
                    appBar,
                    if (layout == _PlayerLayout.normal) const Spacer(flex: 1),
                    SizedBox(height: layout == _PlayerLayout.compact ? 8 : 12),
                    artwork,
                    SizedBox(height: layout == _PlayerLayout.compact ? 12 : 20),
                    info,
                    SizedBox(height: layout == _PlayerLayout.compact ? 12 : 20),
                    progress,
                    SizedBox(height: layout == _PlayerLayout.compact ? 12 : 20),
                    controls,
                    if (layout == _PlayerLayout.normal) const Spacer(flex: 1),
                    SizedBox(height: layout == _PlayerLayout.compact ? 8 : 12),
                  ],
                );

                if (layout == _PlayerLayout.compact || textScale > 1.15) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: body,
                    ),
                  );
                }

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: body,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerAppBar extends StatelessWidget {
  const _PlayerAppBar({
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Cerrar',
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
          AnimatedFavoriteButton(
            isFavorite: isFavorite,
            size: 28,
            onChanged: (_) => onToggleFavorite(),
          ),
          IconButton(
            tooltip: 'Cola',
            onPressed: () => context.push('/queue'),
            icon: const Icon(Icons.queue_music_rounded),
          ),
        ],
      ),
    );
  }
}

class _PlayerSongInfo extends StatelessWidget {
  const _PlayerSongInfo({required this.song, required this.textScale});

  final SongModel song;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = textScale > 1.2
        ? theme.textTheme.titleLarge
        : theme.textTheme.headlineMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: Text(
              song.title,
              key: ValueKey('title_${song.id}'),
              style: titleStyle,
              maxLines: textScale > 1.2 ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: Text(
              song.artist,
              key: ValueKey('artist_${song.id}'),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyMedium?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          if (song.album.isNotEmpty && song.album != 'Desconocido') ...[
            const SizedBox(height: 2),
            Text(
              song.album,
              key: ValueKey('album_${song.id}'),
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _PlayerProgress extends StatelessWidget {
  const _PlayerProgress({
    required this.position,
    required this.totalDuration,
    required this.onSeek,
  });

  final Duration position;
  final Duration totalDuration;
  final ValueChanged<Duration> onSeek;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.musixThemeOrNull;
    final maxMs = totalDuration.inMilliseconds <= 0
        ? 1.0
        : totalDuration.inMilliseconds.toDouble();
    final raw = position.inMilliseconds.toDouble();
    final value = raw < 0 ? 0.0 : (raw > maxMs ? maxMs : raw);
    final sliderTheme = tokens != null
        ? sliderThemeFromTokens(theme, tokens)
        : theme.sliderTheme;

    return Column(
      children: [
        SliderTheme(
          data: sliderTheme,
          child: Slider(
            value: value,
            max: maxMs,
            onChanged: (v) => onSeek(Duration(milliseconds: v.toInt())),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
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
        ),
      ],
    );
  }
}

class _PlayerControls extends StatelessWidget {
  const _PlayerControls({
    required this.isPlaying,
    required this.isShuffle,
    required this.loopMode,
    required this.playSize,
    required this.compact,
    required this.onShuffle,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
    required this.onLoop,
  });

  final bool isPlaying;
  final bool isShuffle;
  final LoopMode loopMode;
  final double playSize;
  final bool compact;
  final VoidCallback onShuffle;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onLoop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.musixThemeOrNull;
    final sideIcon = compact ? 26.0 : 28.0;
    final skipIcon = compact ? 32.0 : 36.0;
    final effectivePlaySize = tokens?.playButtonSize ?? playSize;
    final playRadius = tokens?.playButtonRadius ?? BorderRadius.circular(999);
    final isRoundPlay = playRadius.topLeft.x >= effectivePlaySize / 2 - 0.5;
    final shape = isRoundPlay
        ? const CircleBorder()
        : RoundedRectangleBorder(borderRadius: playRadius);
    final glow = tokens?.glowColor ?? theme.colorScheme.primary;

    Widget playButton = Material(
      color: theme.colorScheme.primary,
      shape: shape,
      elevation: tokens?.controlShadows.isNotEmpty == true ? 0 : 4,
      shadowColor: glow.withAlpha(80),
      child: InkWell(
        customBorder: shape,
        onTap: onPlayPause,
        child: SizedBox(
          width: effectivePlaySize,
          height: effectivePlaySize,
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: theme.colorScheme.onPrimary,
            size: effectivePlaySize * 0.55,
          ),
        ),
      ),
    );

    if (tokens?.glowColor != null) {
      playButton = GlowEffect(
        color: tokens!.glowColor,
        radius: 10,
        child: playButton,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          tooltip: 'Aleatorio',
          onPressed: onShuffle,
          icon: const Icon(Icons.shuffle_rounded),
          iconSize: sideIcon,
          color: isShuffle ? theme.colorScheme.primary : theme.iconTheme.color,
        ),
        IconButton(
          tooltip: 'Anterior',
          onPressed: onPrevious,
          icon: const Icon(Icons.skip_previous_rounded),
          iconSize: skipIcon,
        ),
        Semantics(
          button: true,
          label: isPlaying ? 'Pausar' : 'Reproducir',
          child: playButton,
        ),
        IconButton(
          tooltip: 'Siguiente',
          onPressed: onNext,
          icon: const Icon(Icons.skip_next_rounded),
          iconSize: skipIcon,
        ),
        IconButton(
          tooltip: 'Repetir',
          onPressed: onLoop,
          icon: Icon(
            loopMode == LoopMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
          ),
          iconSize: sideIcon,
          color: loopMode != LoopMode.off
              ? theme.colorScheme.primary
              : theme.iconTheme.color,
        ),
      ],
    );
  }
}
