import "package:flutter/material.dart";
import "profile_self_section_card.dart";

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

    return ProfileSelfSectionCard(
      title: "Conversation Style",
      onEdit: onEdit,
      ctaText: "Review My Prompt Answers",
      onCtaTap: onReviewPromptAnswers,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
