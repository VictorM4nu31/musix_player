import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/pixel_art_theme.dart';

class ArtworkImage extends StatefulWidget {
  const ArtworkImage({
    super.key,
    this.imageUri,
    this.albumId,
    this.size = 48,
    this.borderRadius = 8,
  });

  final String? imageUri;
  final int? albumId;
  final double size;
  final double borderRadius;

  @override
  State<ArtworkImage> createState() => _ArtworkImageState();
}

class _ArtworkImageState extends State<ArtworkImage> {
  static const int _maxCacheSize = 50;
  static final LinkedHashMap<int, Uint8List> _cache = LinkedHashMap();

  Uint8List? _bytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(ArtworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUri != widget.imageUri ||
        oldWidget.albumId != widget.albumId) {
      _bytes = null;
      _isLoading = true;
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.imageUri == null || widget.imageUri!.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    final uri = widget.imageUri!;
    if (uri.startsWith('http://') || uri.startsWith('https://')) {
      setState(() => _isLoading = false);
      return;
    }

    if (uri.startsWith('content://') && widget.albumId != null && widget.albumId! > 0) {
      final albumId = widget.albumId!;

      final cached = _cache[albumId];
      if (cached != null) {
        if (mounted) {
          setState(() {
            _bytes = cached;
            _isLoading = false;
          });
        }
        return;
      }

      try {
        const channel = MethodChannel('com.musix_player/music_scanner');
        final result = await channel.invokeMethod<List<int>>(
          'getArtworkBytes',
          {'albumId': albumId},
        );
        if (result != null && result.isNotEmpty && mounted) {
          final bytes = Uint8List.fromList(result);
          _cache[albumId] = bytes;
          if (_cache.length > _maxCacheSize) {
            _cache.remove(_cache.keys.first);
          }
          setState(() {
            _bytes = bytes;
            _isLoading = false;
          });
        } else if (mounted) {
          setState(() => _isLoading = false);
        }
      } on PlatformException {
        if (mounted) setState(() => _isLoading = false);
      } catch (_) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPixelArt = theme.brightness == Brightness.dark &&
        theme.scaffoldBackgroundColor == PixelArtColors.background;

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: isPixelArt
            ? PixelArtColors.card
            : theme.colorScheme.primary.withAlpha(30),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildContent(theme, isPixelArt),
    );
  }

  Widget _buildContent(ThemeData theme, bool isPixelArt) {
    if (_isLoading) {
      return Center(
        child: SizedBox(
          width: widget.size * 0.3,
          height: widget.size * 0.3,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: isPixelArt
                ? PixelArtColors.primary
                : theme.colorScheme.primary,
          ),
        ),
      );
    }

    if (_bytes != null && _bytes!.isNotEmpty) {
      try {
        return Image.memory(
          _bytes!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildPlaceholder(theme, isPixelArt),
        );
      } catch (_) {
        return _buildPlaceholder(theme, isPixelArt);
      }
    }

    final uri = widget.imageUri;
    if (uri != null && uri.isNotEmpty) {
      if (uri.startsWith('http://') || uri.startsWith('https://')) {
        return Image.network(
          uri,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: widget.size * 0.3,
                height: widget.size * 0.3,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (_, _, _) => _buildPlaceholder(theme, isPixelArt),
        );
      }
    }

    return _buildPlaceholder(theme, isPixelArt);
  }

  Widget _buildPlaceholder(ThemeData theme, bool isPixelArt) {
    if (isPixelArt) {
      return Container(
        color: PixelArtColors.card,
        child: CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _PixelArtNotePainter(
            color: PixelArtColors.primary.withAlpha(120),
            size: widget.size,
          ),
        ),
      );
    }

    return Container(
      color: theme.colorScheme.primary.withAlpha(30),
      child: Icon(
        Icons.music_note_rounded,
        size: widget.size * 0.5,
        color: theme.colorScheme.primary.withAlpha(150),
      ),
    );
  }
}

class _PixelArtNotePainter extends CustomPainter {
  _PixelArtNotePainter({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final pixelSize = size / 16;
    final cx = 8.0;
    final cy = 8.0;

    final notePixels = [
      // Note head (angled oval made of pixels)
      [cx - 3, cy - 1], [cx - 2, cy - 2], [cx - 1, cy - 2],
      [cx, cy - 2], [cx + 1, cy - 2], [cx + 2, cy - 2], [cx + 3, cy - 1],
      [cx - 4, cy], [cx - 3, cy], [cx + 3, cy], [cx + 4, cy],
      [cx - 4, cy + 1], [cx - 3, cy + 1], [cx + 3, cy + 1], [cx + 4, cy + 1],
      [cx - 3, cy + 2], [cx + 3, cy + 2],
      [cx - 2, cy + 3], [cx + 2, cy + 3],
      [cx - 1, cy + 3], [cx + 1, cy + 3],
      [cx, cy + 3],
      // Stem
      [cx + 4, cy - 3], [cx + 4, cy - 4], [cx + 4, cy - 5],
      [cx + 4, cy - 6],
      // Flag
      [cx + 5, cy - 6], [cx + 6, cy - 5], [cx + 6, cy - 4],
      [cx + 5, cy - 4],
    ];

    for (final p in notePixels) {
      final x = (p[0] - 4) * pixelSize + pixelSize;
      final y = (p[1] - 2) * pixelSize + pixelSize;
      canvas.drawRect(
        Rect.fromLTWH(x, y, pixelSize, pixelSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PixelArtNotePainter oldDelegate) =>
      color != oldDelegate.color || size != oldDelegate.size;
}
