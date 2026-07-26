import "package:flutter/material.dart";

/// Conversation Style section widget for profile self screen.
///
/// Displays conversation style title, description, and review CTA.
class ProfileSelfConversationStyle extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onEdit;
  final VoidCallback? onReviewPromptAnswers;

  const ProfileSelfConversationStyle({
    super.key,
    required this.title,
    required this.description,
    this.onEdit,
    this.onReviewPromptAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "YOUR TONE",
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"$description"',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Georgia', // Serif font for quotes
                ),
              ),
              if (onEdit != null) ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: onEdit,
                  child: Text(
                    "this feels off — update it",
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
