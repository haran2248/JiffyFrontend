import "package:flutter/material.dart";
import "curated_section_card.dart";

/// Conversation style section widget for the curated profile screen.
///
/// Displays a multi-line descriptive text explaining the user's
/// conversation style derived from their onboarding chat.
class CuratedConversationStyleSection extends StatelessWidget {
  final String description;
  final VoidCallback? onEdit;

  const CuratedConversationStyleSection({
    super.key,
    required this.description,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CuratedSectionCard(
      title: "Conversation Style",
      onEdit: onEdit,
      child: Text(
        description,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.85),
          height: 1.5,
        ),
      ),
    );
  }
}
