import 'package:flutter/material.dart';
import 'package:jiffy/presentation/widgets/avatar.dart';
import 'package:jiffy/presentation/screens/home/models/home_data.dart';

/// Widget for displaying a story item in the stories row
class StoryItemWidget extends StatelessWidget {
  final StoryItem story;
  final VoidCallback? onTap;

  const StoryItemWidget({
    super.key,
    required this.story,
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
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 70,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: story.isUserStory
                          ? null
                          : (story.storyType == StoryType.dating)
                              ? null
                              : LinearGradient(
                                  colors: [
                                    colorScheme.secondary,
                                    colorScheme.primary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                      color: story.isUserStory
                          ? colorScheme.surfaceContainerHighest
                          : (story.storyType == StoryType.dating)
                              ? colorScheme.secondary
                              : null,
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  // Show heart icon for dating story, avatar otherwise
                  if (story.storyType == StoryType.dating)
                    Icon(
                      Icons.favorite,
                      color: colorScheme.onSurface,
                      size: 24,
                    )
                  else
                    Avatar(
                      radius: 24,
                      imageUrl: story.imageUrl,
                      onTap:
                          null, // Let InkWell handle taps to avoid double invocation
                    ),
                  if (story.isUserStory)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 12,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                story.name ?? '',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
