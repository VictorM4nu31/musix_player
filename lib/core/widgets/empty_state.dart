import 'package:flutter/material.dart';
import '../../app/theme/theme_tokens.dart';
import '../constants/app_constants.dart';

class EmptyState extends StatefulWidget {
  const EmptyState({
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
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
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
    // Style empty states from tokens (borders/radii), not color heuristics.
    final isPixelArt = tokens?.isPixelArt == true ||
        (tokens != null && tokens.borderWidth >= 2 && tokens.radiusMd <= 4);

    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                isPixelArt
                    ? _buildPixelIcon(theme, tokens!)
                    : _buildStandardIcon(theme),
                const SizedBox(height: 24),
                Text(
                  widget.title,
                  style: (isPixelArt
                          ? theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            )
                          : theme.textTheme.titleLarge)
                      ?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (widget.actionLabel != null && widget.onAction != null) ...[
                  const SizedBox(height: 24),
                  isPixelArt
                      ? _buildPixelActionButton(theme, tokens!)
                      : FilledButton.tonalIcon(
                          onPressed: widget.onAction,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(widget.actionLabel!),
                        ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardIcon(ThemeData theme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary.withAlpha(20),
      ),
      child: Icon(
        widget.icon,
        size: 64,
        color: theme.colorScheme.primary.withAlpha(150),
      ),
    );
  }

  Widget _buildPixelIcon(ThemeData theme, MusixThemeTokens tokens) {
    final border = tokens.borderColor ?? theme.colorScheme.primary;
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(
          color: border.withAlpha(80),
          width: tokens.borderWidth > 0 ? tokens.borderWidth : 2,
        ),
        color: theme.colorScheme.surface,
      ),
      child: Icon(
        widget.icon,
        size: 56,
        color: theme.colorScheme.primary.withAlpha(150),
      ),
    );
  }

  Widget _buildPixelActionButton(ThemeData theme, MusixThemeTokens tokens) {
    return GestureDetector(
      onTap: widget.onAction,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(
            color: theme.colorScheme.primary.withAlpha(150),
            width: 2,
          ),
        ),
        child: Text(
          widget.actionLabel!,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
