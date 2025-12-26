import 'package:flutter/material.dart' hide Chip;
import 'package:jiffy/presentation/widgets/card.dart';
import 'package:jiffy/presentation/screens/home/models/home_data.dart';

/// Horizontal scrollable card for profile suggestions
class SuggestionCardWidget extends StatelessWidget {
  final SuggestionCard suggestion;
  final VoidCallback? onTap;

  const SuggestionCardWidget({
    super.key,
    required this.suggestion,
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
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: 320,
          height: 340,
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            child: SystemCard(
              padding: EdgeInsets.zero,
              onTap:
                  null, // Let InkWell handle taps to avoid duplicate gesture detection
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image section with name overlay
                  Stack(
                    children: [
                      // Base layer: Always show fallback icon
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          color: colorScheme.surfaceContainerHighest,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 64,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      // Overlay: Network image if URL is available
                      if (suggestion.imageUrl != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          child: Image.network(
                            suggestion.imageUrl!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Return transparent sized widget to maintain layout
                              // Base icon will show through from the layer below
                              return SizedBox(
                                width: double.infinity,
                                height: 200,
                              );
                            },
                          ),
                        ),
                      // Gradient overlay at bottom for name
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                          child: Text(
                            '${suggestion.name}, ${suggestion.age}',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black.withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Content section - Relationship Preview and Tags
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Relationship Preview - highlighted (core feature)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Relationship Preview',
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                suggestion.relationshipPreview,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  height: 1.3,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Tags
                          if (suggestion.tags.isNotEmpty)
                            Wrap(
                              spacing: 4,
                              runSpacing: 2,
                              children: suggestion.tags
                                  .take(2)
                                  .map(
                                    (tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: colorScheme.primary
                                              .withValues(alpha: 0.4),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        tag,
                                        style: textTheme.labelSmall?.copyWith(
                                          color: colorScheme.primary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
