import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/theme_tokens.dart';
import '../../core/widgets/artwork_image.dart';
import '../../data/models/song_model.dart';
import '../../providers/audio_provider.dart';
import '../analysis/audio_feature_bus.dart';
import '../controllers/visual_lifecycle.dart';
import '../models/audio_features.dart';
import '../models/visual_settings.dart';
import '../models/visualizer_frame.dart';
import '../models/visualizer_type.dart';
import '../providers/visual_providers.dart';
import '../renderers/visualizer_registry.dart';

/// Artwork + selected visualizer. Owns lifecycle + pseudo audio bus for the
/// full player route only.
class PlayerVisualShell extends ConsumerStatefulWidget {
  const PlayerVisualShell({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.side,
    this.reduceMotion = false,
  });

  final SongModel song;
  final bool isPlaying;
  final double side;
  final bool reduceMotion;

  @override
  ConsumerState<PlayerVisualShell> createState() => _PlayerVisualShellState();
}

class _PlayerVisualShellState extends ConsumerState<PlayerVisualShell>
    with TickerProviderStateMixin {
  late final AudioFeatureBus _bus;
  late final VisualLifecycle _lifecycle;
  StreamSubscription<Duration>? _positionSub;
  ProviderSubscription<VisualSettings>? _settingsSub;

  @override
  void initState() {
    super.initState();
    _bus = AudioFeatureBus();
    _lifecycle = VisualLifecycle()..setPlayerVisible(true);
    _bus.attachTicker(this);
    _lifecycle.addListener(_onLifecycle);
    _bus.addListener(_onBus);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _settingsSub = ref.listenManual<VisualSettings>(
        visualSettingsProvider,
        (previous, next) => _pushBusSettings(),
        fireImmediately: true,
      );
      final audio = ref.read(audioPlayerServiceProvider);
      _positionSub = audio.positionStream.listen((position) {
        _bus.updatePlayback(
          isPlaying: widget.isPlaying,
          songId: widget.song.id,
          position: position,
        );
      });
      _syncPlayback();
      _pushBusSettings();
    });
  }

  void _onLifecycle() {
    _pushBusSettings();
    if (mounted) setState(() {});
  }

  void _onBus() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant PlayerVisualShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.song.id != widget.song.id ||
        oldWidget.isPlaying != widget.isPlaying) {
      _syncPlayback();
    }
    if (oldWidget.reduceMotion != widget.reduceMotion) {
      _pushBusSettings();
    }
  }

  void _syncPlayback() {
    final position =
        ref.read(positionProvider).valueOrNull ?? Duration.zero;
    _bus.updatePlayback(
      isPlaying: widget.isPlaying,
      songId: widget.song.id,
      position: position,
    );
  }

  void _pushBusSettings() {
    if (!mounted) return;
    VisualSettings settings;
    try {
      settings = ref.read(visualSettingsProvider);
    } catch (_) {
      return;
    }
    final allow = _lifecycle.allowHeavyVisuals &&
        settings.animationsEnabled &&
        !widget.reduceMotion;
    _bus.updateSettings(
      enabled: allow,
      visible: _lifecycle.playerVisible,
      audioReactive: settings.audioReactive,
      intensity: settings.clampedIntensity,
    );
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _settingsSub?.close();
    _lifecycle.removeListener(_onLifecycle);
    _bus.removeListener(_onBus);
    _lifecycle.setPlayerVisible(false);
    _lifecycle.dispose();
    _bus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(visualSettingsProvider);
    final tokens = context.musixThemeOrNull;
    final theme = Theme.of(context);
    final reduceMotion =
        widget.reduceMotion || MediaQuery.disableAnimationsOf(context);

    final effectiveType = reduceMotion || !settings.animationsEnabled
        ? VisualizerType.none
        : settings.effectiveType;

    final radius = effectiveType == VisualizerType.vinyl && !reduceMotion
        ? 999.0
        : (tokens?.artworkRadius ?? 24.0);
    final duration = tokens?.mediumAnim ?? const Duration(milliseconds: 350);

    Widget art = ArtworkImage(
      key: ValueKey(widget.song.id),
      imageUri: widget.song.artworkUri,
      albumId: widget.song.albumId,
      size: double.infinity,
      borderRadius: radius,
    );

    if (tokens?.glowColor != null && widget.isPlaying) {
      art = _SoftGlow(
        color: tokens!.glowColor!,
        child: art,
      );
    }

    art = AnimatedSwitcher(
      duration: duration,
      switchInCurve: tokens?.defaultCurve ?? Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: tokens?.defaultCurve ?? Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        );
      },
      child: art,
    );

    final features = (_lifecycle.allowHeavyVisuals && settings.audioReactive)
        ? _bus.features
        : AudioFeatures(
            isPlaying: widget.isPlaying,
            intensity: settings.clampedIntensity,
            energy: widget.isPlaying ? 0.25 * settings.clampedIntensity : 0,
          );

    final frame = VisualizerFrame(
      features: features,
      settings: settings,
      tokens: tokens,
      artwork: art,
      size: widget.side,
      isPlaying: widget.isPlaying,
      reduceMotion: reduceMotion,
      primaryColor: tokens?.glowColor ?? theme.colorScheme.primary,
    );

    final renderer = VisualizerRegistry.resolve(effectiveType);

    return SizedBox(
      width: widget.side,
      height: widget.side,
      child: renderer.build(context, frame),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  const _SoftGlow({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(48),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}
