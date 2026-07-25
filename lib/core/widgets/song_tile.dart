import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/formatters.dart';
import 'artwork_image.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.title,
    this.artist,
    this.album,
    this.duration,
    this.artworkUri,
    this.isSelected = false,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.onMorePressed,
  });

  final String title;
  final String? artist;
  final String? album;
  final Duration? duration;
  final String? artworkUri;
  final bool isSelected;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          color: isSelected
              ? theme.colorScheme.primary.withAlpha(25)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            ArtworkImage(
              imageUri: artworkUri,
              size: 52,
              borderRadius: AppConstants.artworkBorderRadius,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : null,
                    ),
                  ),
                  if (artist != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      artist!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (duration != null)
              Text(
                Formatters.formatDurationShort(duration!),
                style: theme.textTheme.bodySmall,
              ),
            if (trailing != null) ...[
              const SizedBox(width: 4),
              trailing!,
            ] else ...[
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: theme.textTheme.bodySmall?.color,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onMorePressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
