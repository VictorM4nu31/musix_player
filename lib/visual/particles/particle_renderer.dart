import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/visualizer_frame.dart';
import '../models/visualizer_type.dart';
import '../renderers/visualizer_renderer.dart';
import 'particle_system.dart';
import 'particle_painter.dart';

class ParticleRenderer extends VisualizerRenderer {
  const ParticleRenderer();

  @override
  VisualizerType get type => VisualizerType.particle;

  @override
  Widget build(BuildContext context, VisualizerFrame frame) {
    return _ParticleView(frame: frame);
  }
}

class _ParticleView extends StatefulWidget {
  const _ParticleView({required this.frame});

  final VisualizerFrame frame;

  @override
  State<_ParticleView> createState() => _ParticleViewState();
}

class _ParticleViewState extends State<_ParticleView>
    with SingleTickerProviderStateMixin {
  late final ParticleSystem _system;
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _system = ParticleSystem(quality: widget.frame.settings.quality);
    _ticker = createTicker(_onTick);
    _sync(widget.frame);
  }

  @override
  void didUpdateWidget(covariant _ParticleView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _system.updateQuality(widget.frame.settings.quality);
    _sync(widget.frame);
  }

  void _sync(VisualizerFrame frame) {
    final run = frame.isPlaying && !frame.reduceMotion;
    if (run && !_ticker.isActive) {
      _lastTick = Duration.zero;
      _ticker.start();
    } else if (!run && _ticker.isActive) {
      _ticker.stop();
      _system.reset();
    }
  }

  void _onTick(Duration elapsed) {
    final dt = _lastTick == Duration.zero
        ? 0.016
        : (elapsed - _lastTick).inMicroseconds / 1000000.0;
    _lastTick = elapsed;
    _system.update(dt, widget.frame.features);
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

    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(frame.size, frame.size),
          painter: ParticlePainter(
            particles: _system.particles,
            color: primary,
            intensity: frame.intensity,
            isPlaying: frame.isPlaying,
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
