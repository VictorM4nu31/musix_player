import 'package:flutter/material.dart';

class ArtworkImage extends StatelessWidget {
  const ArtworkImage({
    super.key,
    this.imageUri,
    this.size = 48,
    this.borderRadius = 8,
  });

  final String? imageUri;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: theme.colorScheme.primary.withAlpha(30),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUri != null && imageUri!.isNotEmpty
          ? Image.network(
              imageUri!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(
                theme,
              ),
            )
          : _buildPlaceholder(theme),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withAlpha(30),
      child: Icon(
        Icons.music_note_rounded,
        size: size * 0.5,
        color: theme.colorScheme.primary.withAlpha(150),
      ),
    );
  }
}
