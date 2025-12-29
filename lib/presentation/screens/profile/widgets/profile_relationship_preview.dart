import "package:flutter/material.dart";
import "package:jiffy/presentation/screens/profile/models/profile_data.dart";
import "package:jiffy/presentation/widgets/card.dart";

/// Relationship preview section with comparative insight tags
class ProfileRelationshipPreview extends StatelessWidget {
  final ProfileData profile;

  const ProfileRelationshipPreview({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (profile.relationshipPreview == null) {
      return const SizedBox.shrink();
    }

    return SystemCard(
      padding: const EdgeInsets.all(16),
      isGlass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                "Relationship Preview",
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Full relationship preview text (no truncation)
          Text(
            profile.relationshipPreview!,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          // Comparison insights tags with different colors using colorScheme
          if (profile.comparisonInsights.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.comparisonInsights.asMap().entries.map((entry) {
                final index = entry.key;
                final insight = entry.value;

                // Use colorScheme colors with variations for tag diversity
                // Cycle through primary, secondary, tertiary, and error colors
                final baseColors = [
                  colorScheme.primary,
                  colorScheme.secondary,
                  colorScheme.tertiary,
                  colorScheme.error,
                ];

                final baseColor = baseColors[index % baseColors.length];

                // Create gradient colors with opacity
                final gradientColors = [
                  baseColor.withValues(alpha: 0.2),
                  baseColor.withValues(alpha: 0.15),
                ];

                // Border and text colors based on base color
                final borderColor = baseColor.withValues(alpha: 0.3);
                final textColor = baseColor.withValues(alpha: 0.9);

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    insight.label,
                    style: textTheme.labelSmall?.copyWith(
                      color: textColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
