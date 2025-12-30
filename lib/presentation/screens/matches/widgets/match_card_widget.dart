import 'package:flutter/material.dart';
import '../models/match_item.dart';

/// Widget displaying a single match card/row in the matches list.
///
/// Handles both regular match cards and the Jiffy AI assistant card
/// with distinct styling based on [MatchItem.isJiffyAi].
class MatchCardWidget extends StatelessWidget {
  final MatchItem match;
  final VoidCallback? onTap;

  const MatchCardWidget({
    super.key,
    required this.match,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with gradient border
              _buildAvatar(colorScheme),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name, age, and time row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            match.age != null
                                ? '${match.name}, ${match.age}'
                                : match.name,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: match.isJiffyAi
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (match.timeAgo.isNotEmpty)
                          Text(
                            match.timeAgo,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Message preview or bio
                    if (match.lastMessage != null || match.bio != null)
                      Text(
                        match.lastMessage ?? match.bio ?? '',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    // Tags
                    if (match.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildTags(colorScheme, textTheme),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme) {
    final size = 56.0;
    final borderWidth = 2.5;

    // Purple gradient for Jiffy AI, subtle border for others
    final gradientColors = match.isJiffyAi
        ? [
            colorScheme.primary,
            colorScheme.tertiary,
          ]
        : [
            colorScheme.outline.withValues(alpha: 0.3),
            colorScheme.outline.withValues(alpha: 0.3)
          ];

    return Container(
      width: size + borderWidth * 2,
      height: size + borderWidth * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(borderWidth),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surface,
        ),
        child: ClipOval(
          child: match.isJiffyAi
              ? Container(
                  color: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.auto_awesome,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                )
              : match.imageUrl != null
                  ? Image.network(
                      match.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderAvatar(colorScheme),
                    )
                  : _buildPlaceholderAvatar(colorScheme),
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.person,
        color: colorScheme.onSurfaceVariant,
        size: 28,
      ),
    );
  }

  Widget _buildTags(ColorScheme colorScheme, TextTheme textTheme) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: match.tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            tag,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}
