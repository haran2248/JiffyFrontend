import 'package:flutter/material.dart';
import 'package:jiffy/presentation/widgets/card.dart';
import 'package:jiffy/presentation/widgets/button.dart';
import 'package:jiffy/presentation/screens/home/models/home_data.dart';

/// Card widget for match prompts
class MatchPromptCardWidget extends StatelessWidget {
  final MatchPrompt prompt;
  final VoidCallback? onAnswerTap;

  const MatchPromptCardWidget({
    super.key,
    required this.prompt,
    this.onAnswerTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SystemCard(
      padding: const EdgeInsets.all(20),
      onTap: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // New badge
          if (prompt.isNew)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'New Prompt',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (prompt.isNew) const SizedBox(height: 12),
          // Prompt text
          Text(
            prompt.promptText,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          // Answer button - only show if callback is provided
          if (onAnswerTap != null)
            SizedBox(
              width: double.infinity,
              child: Button(
                text: 'Answer Now',
                onTap: onAnswerTap!,
                type: ButtonType.primary,
              ),
            ),
        ],
      ),
    );
  }
}
