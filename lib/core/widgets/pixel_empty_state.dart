import 'package:flutter/material.dart';
import '../../app/theme/pixel_art_theme.dart';

class PixelEmptyState extends StatefulWidget {
  const PixelEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  State<PixelEmptyState> createState() => _PixelEmptyStateState();
}

class _PixelEmptyStateState extends State<PixelEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _floatAnim = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPixelArt = theme.brightness == Brightness.dark &&
        theme.scaffoldBackgroundColor == PixelArtColors.background;

    if (!isPixelArt) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: Offset(0, _floatAnim.value),
                  child: Opacity(
                    opacity: _fadeAnim.value.clamp(0.4, 1.0),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: PixelArtColors.border.withAlpha(80),
                          width: 2,
                        ),
                        color: PixelArtColors.card,
                      ),
                      child: CustomPaint(
                        painter: _PixelIconPainter(
                          icon: widget.icon,
                          color: PixelArtColors.primary.withAlpha(150),
                          size: 120,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: PixelArtColors.primary,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: PixelArtColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (widget.actionLabel != null && widget.onAction != null) ...[
                  const SizedBox(height: 24),
                  _PixelActionButton(
                    label: widget.actionLabel!,
                    onTap: widget.onAction!,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PixelActionButton extends StatelessWidget {
  const _PixelActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: PixelArtColors.primary,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: PixelArtColors.primary.withAlpha(150),
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: PixelArtColors.background,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _PixelIconPainter extends CustomPainter {
  _PixelIconPainter({
    required this.icon,
    required this.color,
    required this.size,
  });

  final IconData icon;
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

    final pixels = icon == Icons.music_note_rounded
        ? _musicNotePixels(cx, cy)
        : icon == Icons.favorite_border_rounded
            ? _heartPixels(cx, cy)
            : _defaultPixels(cx, cy);

    for (final p in pixels) {
      final x = p[0] * pixelSize;
      final y = p[1] * pixelSize;
      canvas.drawRect(
        Rect.fromLTWH(x, y, pixelSize, pixelSize),
        paint,
      );
    }
  }

  List<List<double>> _musicNotePixels(double cx, double cy) {
    return [
      [cx - 2, cy - 3], [cx - 1, cy - 3], [cx, cy - 3], [cx + 1, cy - 3], [cx + 2, cy - 3],
      [cx - 3, cy - 2], [cx - 2, cy - 2], [cx + 2, cy - 2], [cx + 3, cy - 2],
      [cx - 3, cy - 1], [cx + 2, cy - 1], [cx + 3, cy - 1],
      [cx - 3, cy], [cx + 2, cy], [cx + 3, cy],
      [cx - 2, cy + 1], [cx + 1, cy + 1], [cx + 2, cy + 1], [cx + 3, cy + 1],
      [cx - 2, cy + 2], [cx - 1, cy + 2], [cx + 1, cy + 2], [cx + 2, cy + 2], [cx + 3, cy + 2],
      [cx - 2, cy + 3], [cx + 2, cy + 3],
      [cx + 1, cy + 3],
      // Stem
      [cx + 4, cy - 4], [cx + 4, cy - 5], [cx + 4, cy - 6], [cx + 4, cy - 7],
      // Flag
      [cx + 5, cy - 7], [cx + 6, cy - 6], [cx + 6, cy - 5], [cx + 5, cy - 5],
    ];
  }

  List<List<double>> _heartPixels(double cx, double cy) {
    return [
      [cx - 1, cy - 4], [cx, cy - 4], [cx + 1, cy - 4],
      [cx - 2, cy - 3], [cx - 1, cy - 3], [cx, cy - 3], [cx + 1, cy - 3], [cx + 2, cy - 3],
      [cx - 3, cy - 2], [cx - 2, cy - 2], [cx - 1, cy - 2], [cx, cy - 2], [cx + 1, cy - 2], [cx + 2, cy - 2], [cx + 3, cy - 2],
      [cx - 3, cy - 1], [cx - 2, cy - 1], [cx - 1, cy - 1], [cx, cy - 1], [cx + 1, cy - 1], [cx + 2, cy - 1], [cx + 3, cy - 1],
      [cx - 2, cy], [cx - 1, cy], [cx, cy], [cx + 1, cy], [cx + 2, cy],
      [cx - 1, cy + 1], [cx, cy + 1], [cx + 1, cy + 1],
      [cx, cy + 2],
    ];
  }

  List<List<double>> _defaultPixels(double cx, double cy) {
    return [
      [cx - 2, cy - 3], [cx - 1, cy - 3], [cx, cy - 3], [cx + 1, cy - 3],
      [cx - 3, cy - 2], [cx - 2, cy - 2], [cx - 1, cy - 2], [cx, cy - 2], [cx + 1, cy - 2], [cx + 2, cy - 2],
      [cx - 3, cy - 1], [cx + 2, cy - 1],
      [cx - 3, cy], [cx - 1, cy], [cx, cy], [cx + 1, cy], [cx + 2, cy],
      [cx - 3, cy + 1], [cx + 2, cy + 1],
      [cx - 3, cy + 2], [cx + 2, cy + 2],
      [cx - 3, cy + 3], [cx + 2, cy + 3],
    ];
  }

  @override
  bool shouldRepaint(_PixelIconPainter oldDelegate) =>
      icon != oldDelegate.icon || color != oldDelegate.color;
}
