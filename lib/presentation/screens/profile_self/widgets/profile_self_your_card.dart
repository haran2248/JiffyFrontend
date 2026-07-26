import "package:flutter/material.dart";

/// "Your Card" widget showing the AI generated bio for the profile.
class ProfileSelfYourCard extends StatelessWidget {
  final String aboutMeText;
  final VoidCallback? onRegenerate;

  const ProfileSelfYourCard({
    super.key,
    required this.aboutMeText,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "YOUR CARD",
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
                '"$aboutMeText"',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Georgia', // Serif font for quotes
                ),
              ),
              const SizedBox(height: 20),
              // Regenerate button
              InkWell(
                onTap: onRegenerate,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Regenerate",
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Generated from your onboarding — edit by redoing the conversation.",
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
