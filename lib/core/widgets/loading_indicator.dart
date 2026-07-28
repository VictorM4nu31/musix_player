import 'package:flutter/material.dart';
import '../../app/theme/theme_tokens.dart';

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key, this.message});

  final String? message;

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.musixThemeOrNull;
    final sharp = (tokens?.radiusMd ?? 16) <= 2;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: sharp ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: sharp ? BorderRadius.circular(tokens!.radiusMd) : null,
                color: theme.colorScheme.primary.withAlpha(20),
                border: tokens?.borderColor != null
                    ? Border.all(
                        color: tokens!.borderColor!.withAlpha(100),
                        width: tokens.borderWidth > 0 ? tokens.borderWidth : 1,
                      )
                    : null,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 24),
            Text(
              widget.message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
