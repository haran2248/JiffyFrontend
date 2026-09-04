import "package:flutter/material.dart";
import "package:jiffy/core/theme/app_typography.dart";

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
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2), // Neon Pink Border
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"$description"',
                style: AppTypography.serifQuote.copyWith(
                  color: colorScheme.onSurface,
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
