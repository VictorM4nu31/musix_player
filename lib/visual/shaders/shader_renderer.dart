import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/animation_preset.dart';
import '../models/visualizer_frame.dart';
import '../models/visualizer_type.dart';
import '../renderers/visualizer_renderer.dart';
import 'shader_painter.dart';
import 'shader_type.dart';

class ShaderRenderer extends VisualizerRenderer {
  const ShaderRenderer();

  @override
  VisualizerType get type => VisualizerType.shader;

  @override
  Widget build(BuildContext context, VisualizerFrame frame) {
    return _ShaderView(frame: frame);
  }
}

class _ShaderView extends StatefulWidget {
  const _ShaderView({required this.frame});

  final VisualizerFrame frame;

  @override
  State<_ShaderView> createState() => _ShaderViewState();
}

class _ShaderViewState extends State<_ShaderView>
    with SingleTickerProviderStateMixin {
  ShaderEffectType get _effect => switch (widget.frame.settings.preset) {
        AnimationPreset.performance => ShaderEffectType.aurora,
        AnimationPreset.minimal => ShaderEffectType.aurora,
        AnimationPreset.dynamic => ShaderEffectType.aurora,
        AnimationPreset.vinyl => ShaderEffectType.neon,
        AnimationPreset.retro => ShaderEffectType.ripple,
        AnimationPreset.cyber => ShaderEffectType.neon,
      };

  late final Ticker _ticker;
  Duration _startTime = Duration.zero;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _sync(widget.frame);
  }

  @override
  void didUpdateWidget(covariant _ShaderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(widget.frame);
  }

  void _sync(VisualizerFrame frame) {
    final run = frame.isPlaying && !frame.reduceMotion;
    if (run && !_ticker.isActive) {
      _lastTick = Duration.zero;
      _startTime = Duration.zero;
      _ticker.start();
    } else if (!run && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    if (_startTime == Duration.zero) {
      _startTime = elapsed;
    }
    _lastTick = elapsed;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = widget.frame;
    final primary =
        frame.primaryColor ?? Theme.of(context).colorScheme.primary;
    final artPad = frame.size * 0.12;
    final radius = frame.tokens?.artworkRadius ?? frame.size * 0.08;
    final time = _startTime == Duration.zero
        ? 0.0
        : (_lastTick - _startTime).inMicroseconds / 1000000.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(frame.size, frame.size),
          painter: ShaderPainter(
            effectType: _effect,
            features: frame.features,
            time: time,
            intensity: frame.intensity,
            isPlaying: frame.isPlaying,
            primaryColor: primary,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(artPad),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: frame.artwork,
          ),
        ),
      ],
    );
  }
}
