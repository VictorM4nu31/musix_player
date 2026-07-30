import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/theme_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/themed_slider_thumb.dart';
import '../../data/models/song_model.dart';
import '../analysis/waveform_service.dart';
import '../models/progress_style.dart';
import '../models/visual_quality.dart';
import '../models/visual_settings.dart';
import '../providers/visual_providers.dart';

final waveformServiceProvider = Provider<WaveformService>((ref) {
  return WaveformService();
});

/// Progress control: classic slider or offline waveform seek bar.
class VisualProgressBar extends ConsumerWidget {
  const VisualProgressBar({
    super.key,
    required this.song,
    required this.position,
    required this.totalDuration,
    required this.onSeek,
  });

  final SongModel song;
  final Duration position;
  final Duration totalDuration;
  final ValueChanged<Duration> onSeek;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(visualSettingsProvider);
    final useWave = _shouldUseWaveform(settings);

    if (!useWave) {
      return _SliderProgress(
        position: position,
        totalDuration: totalDuration,
        onSeek: onSeek,
      );
    }

    return _WaveformProgress(
      song: song,
      position: position,
      totalDuration: totalDuration,
      onSeek: onSeek,
    );
  }

  bool _shouldUseWaveform(VisualSettings settings) {
    switch (settings.progressStyle) {
      case ProgressStyle.slider:
        return false;
      case ProgressStyle.waveform:
        return true;
      case ProgressStyle.auto:
        return settings.quality != VisualQuality.low &&
            settings.animationsEnabled;
    }
  }
}

class _SliderProgress extends StatelessWidget {
  const _SliderProgress({
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
        _TimeRow(position: position, totalDuration: totalDuration),
      ],
    );
  }
}

class _WaveformProgress extends ConsumerStatefulWidget {
  const _WaveformProgress({
    required this.song,
    required this.position,
    required this.totalDuration,
    required this.onSeek,
  });

  final SongModel song;
  final Duration position;
  final Duration totalDuration;
  final ValueChanged<Duration> onSeek;

  @override
  ConsumerState<_WaveformProgress> createState() => _WaveformProgressState();
}

class _WaveformProgressState extends ConsumerState<_WaveformProgress> {
  WaveformData? _data;
  bool _loading = true;
  int? _loadedSongId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _WaveformProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.song.id != widget.song.id) {
      _load();
    }
  }

  Future<void> _load() async {
    final id = widget.song.id;
    setState(() {
      _loading = true;
      _loadedSongId = id;
    });
    final data =
        await ref.read(waveformServiceProvider).getWaveform(widget.song);
    if (!mounted || _loadedSongId != id) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  void _seekFromLocalX(double localX, double width) {
    if (width <= 0) return;
    final t = (localX / width).clamp(0.0, 1.0);
    final total = widget.totalDuration.inMilliseconds <= 0
        ? 1
        : widget.totalDuration.inMilliseconds;
    widget.onSeek(Duration(milliseconds: (t * total).round()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.musixThemeOrNull;
    final active = tokens?.glowColor ?? theme.colorScheme.primary;
    final inactive = theme.colorScheme.onSurface.withAlpha(50);

    if (_loading && _data == null) {
      return _SliderProgress(
        position: widget.position,
        totalDuration: widget.totalDuration,
        onSeek: widget.onSeek,
      );
    }

    final samples = _data?.samples ?? const <double>[];
    if (samples.isEmpty) {
      return _SliderProgress(
        position: widget.position,
        totalDuration: widget.totalDuration,
        onSeek: widget.onSeek,
      );
    }

    final maxMs = widget.totalDuration.inMilliseconds <= 0
        ? 1.0
        : widget.totalDuration.inMilliseconds.toDouble();
    final progress =
        (widget.position.inMilliseconds / maxMs).clamp(0.0, 1.0);

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) =>
                    _seekFromLocalX(d.localPosition.dx, constraints.maxWidth),
                onHorizontalDragUpdate: (d) =>
                    _seekFromLocalX(d.localPosition.dx, constraints.maxWidth),
                child: CustomPaint(
                  size: Size(constraints.maxWidth, 48),
                  painter: _WaveformPainter(
                    samples: samples,
                    progress: progress,
                    activeColor: active,
                    inactiveColor: inactive,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        _TimeRow(
          position: widget.position,
          totalDuration: widget.totalDuration,
        ),
      ],
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.position,
    required this.totalDuration,
  });

  final Duration position;
  final Duration totalDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
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
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.samples,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  final List<double> samples;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;
    final midY = size.height / 2;
    final n = samples.length;
    final barW = size.width / n;
    final paint = Paint()..style = PaintingStyle.fill;
    final progressX = size.width * progress;

    for (var i = 0; i < n; i++) {
      final x = i * barW;
      final amp = samples[i].clamp(0.06, 1.0);
      final h = size.height * 0.85 * amp;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + barW * 0.5, midY),
          width: math.max(1.0, barW * 0.65),
          height: h,
        ),
        const Radius.circular(1.5),
      );
      paint.color = x + barW * 0.5 <= progressX ? activeColor : inactiveColor;
      canvas.drawRRect(rect, paint);
    }

    // Playhead
    final head = Paint()
      ..color = activeColor
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(progressX, 4),
      Offset(progressX, size.height - 4),
      head,
    );
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      samples != oldDelegate.samples ||
      activeColor != oldDelegate.activeColor ||
      inactiveColor != oldDelegate.inactiveColor;
}
