import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/artwork_image.dart';
import '../../providers/audio_provider.dart';
import '../../data/models/song_model.dart';
import '../models/visualizer_frame.dart';

class CoverFlowWidget extends ConsumerStatefulWidget {
  const CoverFlowWidget({super.key, required this.frame});

  final VisualizerFrame frame;

  @override
  ConsumerState<CoverFlowWidget> createState() => _CoverFlowWidgetState();
}

class _CoverFlowWidgetState extends ConsumerState<CoverFlowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  double _dragOffset = 0;
  double _animStart = 0;
  double _animTarget = 0;
  int _pendingDelta = 0;

  static const double _itemSpacingRatio = 0.32;
  static const int _visibleSides = 2;
  static const double _dragThreshold = 0.35;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animController.addListener(_onAnimTick);
    _animController.addStatusListener(_onAnimDone);
  }

  void _onAnimTick() {
    _dragOffset = _lerpDouble(_animStart, _animTarget, _animController.value);
    setState(() {});
  }

  void _onAnimDone(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (_pendingDelta == 0) return;
    final audio = ref.read(audioPlayerServiceProvider);
    if (_pendingDelta > 0) {
      audio.seekToNext();
    } else {
      audio.seekToPrevious();
    }
    _dragOffset = 0;
    _pendingDelta = 0;
    setState(() {});
  }

  double _lerpDouble(double a, double b, double t) =>
      a + (b - a) * Curves.easeOutCubic.transform(t);

  void _onDragStart(DragStartDetails _) {
    _animController.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final itemWidth = widget.frame.size * _itemSpacingRatio;
    _dragOffset -= details.primaryDelta! / itemWidth;
    _dragOffset = _dragOffset.clamp(-2.0, 2.0);
    setState(() {});
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final absOffset = _dragOffset.abs();

    if (absOffset > _dragThreshold || velocity.abs() > 250) {
      if ((_dragOffset > 0 && velocity >= -100) ||
          (velocity < -250 && _dragOffset > -0.1)) {
        _startSnap(1);
      } else if ((_dragOffset < 0 && velocity <= 100) ||
          (velocity > 250 && _dragOffset < 0.1)) {
        _startSnap(-1);
      } else {
        _startSnap(0);
      }
    } else {
      _startSnap(0);
    }
  }

  void _startSnap(int delta) {
    final target = delta.toDouble();
    _animStart = _dragOffset;
    _animTarget = target;
    _pendingDelta = delta;
    _animController.reset();
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = widget.frame;
    final queue = ref.watch(queueProvider).valueOrNull ?? [];
    final currentIndex = ref.watch(currentIndexProvider).valueOrNull ?? 0;
    final size = frame.size;
    final radius = frame.tokens?.artworkRadius ?? size * 0.06;

    if (queue.isEmpty) return frame.artwork;

    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: _buildItems(queue, currentIndex, size, radius),
        ),
      ),
    );
  }

  List<Widget> _buildItems(
    List<SongModel> queue,
    int currentIndex,
    double size,
    double radius,
  ) {
    final items = <Widget>[];

    for (var offset = -_visibleSides; offset <= _visibleSides; offset++) {
      final idx = currentIndex + offset;
      if (idx < 0 || idx >= queue.length) continue;

      final visualPos = offset - _dragOffset;
      final absPos = visualPos.abs();

      if (absPos > 2.5) continue;

      final item = _buildSingleItem(
        queue[idx],
        visualPos,
        size,
        radius,
      );
      if (item != null) items.add(item);
    }

    return items;
  }

  Widget? _buildSingleItem(
    SongModel song,
    double pos,
    double size,
    double radius,
  ) {
    final absPos = pos.abs();
    final scale = (1.0 - absPos * 0.18).clamp(0.35, 1.0);
    final opacity = (1.0 - absPos * 0.35).clamp(0.0, 1.0);
    final translateX = pos * size * _itemSpacingRatio;
    final rotationY = pos * 0.35;

    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateY(rotationY);
    transform.storage[0] *= scale;
    transform.storage[5] *= scale;
    transform.storage[10] *= scale;
    transform.storage[12] += translateX;

    final itemSize = size.clamp(0.0, double.infinity);
    final itemRadius = radius > 100 ? radius : radius.clamp(0.0, 24.0);

    return Positioned.fill(
      top: size * (1.0 - scale) * 0.5,
      bottom: size * (1.0 - scale) * 0.5,
      child: Opacity(
        opacity: opacity,
        child: Transform(
          alignment: Alignment.center,
          transform: transform,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size * 0.04,
            ),
            child: RepaintBoundary(
              child: ArtworkImage(
                imageUri: song.artworkUri,
                albumId: song.albumId,
                size: itemSize,
                borderRadius: itemRadius,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
