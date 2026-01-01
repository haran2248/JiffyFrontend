import "package:flutter/material.dart" hide Chip;
import "package:jiffy/presentation/widgets/chip.dart";
import "curated_section_card.dart";

/// Interests section widget for the curated profile screen.
///
/// Displays interest chips in a responsive wrap layout.
/// Uses secondary/neutral chip style per design.
class CuratedInterestsSection extends StatelessWidget {
  final List<String> interests;
  final VoidCallback? onEdit;

  const CuratedInterestsSection({
    super.key,
    required this.interests,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return CuratedSectionCard(
      title: "Interests",
      onEdit: onEdit,
      child: interests.isEmpty
          ? Text(
              "No interests added yet",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: interests
                  .map(
                    (interest) => Chip(
                      label: interest,
                      isSelected: false,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
