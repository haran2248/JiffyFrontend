import "package:flutter/material.dart";
import "package:jiffy/presentation/screens/profile/models/profile_data.dart";
import "package:jiffy/presentation/widgets/card.dart";

/// Personality & Values section widget
class ProfilePersonalitySection extends StatelessWidget {
  final ProfileData profile;

  const ProfilePersonalitySection({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final traitsText =
        profile.traits.isNotEmpty ? "${profile.traits.join(", ")}. " : "";
    const valuesText = "Values Authenticity, Growth and Community.";

    // Always show this section (even if no traits)
    return SystemCard(
      padding: const EdgeInsets.all(20),
      isGlass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                size: 20,
                color: colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(
                "Personality & Values",
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            traitsText.isEmpty ? valuesText : "$traitsText$valuesText",
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

