import 'package:flutter/material.dart';
import 'package:jiffy/presentation/widgets/avatar.dart';
import 'package:jiffy/presentation/screens/home/models/home_data.dart';

/// Widget for displaying a story item in the stories row.
/// Styled after Instagram: thick gradient ring, white gap, avatar inside.
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

    // Pure red gradient for story rings
    const storyGradient = LinearGradient(
      colors: [
        Color(0xFFB71C1C), // deep crimson
        Color(0xFFE53935), // bright red
        Color(0xFFFF5252), // vivid red
        Color(0xFFFF1744), // electric red
      ],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    );

    // Seen/grey gradient for own story ring or seen stories
    final seenGradient = LinearGradient(
      colors: [
        colorScheme.outline.withValues(alpha: 0.4),
        colorScheme.outline.withValues(alpha: 0.4),
      ],
    );

    final isOwn = story.isUserStory;
    final isDating = story.storyType == StoryType.dating;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // ── Gradient ring ──────────────────────────────
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: (isOwn && story.hasActiveStory != true)
                        ? seenGradient
                        : storyGradient,
                  ),
                ),

                // ── White gap between ring and avatar ──────────
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surface,
                  ),
                ),

                // ── Avatar / icon ──────────────────────────────
                if (isDating)
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFDD2A7B), Color(0xFF8134AF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 26,
                    ),
                  )
                else
                  ClipOval(
                    child: SizedBox(
                      width: 54,
                      height: 54,
                      child: Avatar(
                        radius: 27,
                        imageUrl: story.imageUrl,
                        onTap: null,
                      ),
                    ),
                  ),

                // ── "+" badge for own story ────────────────────
                if (isOwn)
                  Positioned(
                    bottom: 0,
                    right: 2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF58529), Color(0xFFDD2A7B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 5),

            // ── Label ──────────────────────────────────────────
            SizedBox(
              width: 68,
              child: _buildLabel(
                context,
                isOwn: isOwn,
                hasActiveStory: story.hasActiveStory == true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(
    BuildContext context, {
    required bool isOwn,
    required bool hasActiveStory,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final text = Text(
      story.name ?? '',
      style: textTheme.bodySmall?.copyWith(
        fontSize: isOwn ? 10 : 11,
        fontWeight: isOwn ? FontWeight.w600 : FontWeight.w400,
        // White so ShaderMask blends through; plain colour otherwise
        color: (isOwn && hasActiveStory) ? Colors.white : colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (isOwn && hasActiveStory) {
      return ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => const LinearGradient(
          colors: [
            Color(0xFFB71C1C), // deep crimson
            Color(0xFFE53935), // bright red
            Color(0xFFFF5252), // vivid red
            Color(0xFFFF1744), // electric red
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(bounds),
        child: text,
      );
    }

    return text;
  }
}
