import "package:flutter/material.dart" hide Chip;
import "package:jiffy/presentation/widgets/chip.dart";
import "profile_self_section_card.dart";

/// Interests section widget for profile self screen.
///
/// Displays interest chips in a responsive wrap layout.
/// Can be reused for personality traits by passing a custom title.
class ProfileSelfInterests extends StatelessWidget {
  final List<String> interests;
  final VoidCallback? onEdit;
  final String title;

  const ProfileSelfInterests({
    super.key,
    required this.interests,
    this.onEdit,
    this.title = "Interests",
  });

  @override
  Widget build(BuildContext context) {
    return ProfileSelfSectionCard(
      title: title,
      onEdit: onEdit,
      child: interests.isEmpty
          ? Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  "No interests added yet",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: interests
                  .map(
                    (interest) => Chip(
                      label: interest,
                      isSelected: true,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
