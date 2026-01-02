import "package:flutter/material.dart" hide Chip;
import "package:jiffy/presentation/widgets/chip.dart";
import "curated_section_card.dart";

/// Personality traits section widget for the curated profile screen.
///
/// Displays personality trait chips in a responsive wrap layout.
/// Uses primary/accent chip style per design.
class CuratedTraitsSection extends StatelessWidget {
  final List<String> traits;
  final VoidCallback? onEdit;

  const CuratedTraitsSection({
    super.key,
    required this.traits,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return CuratedSectionCard(
      title: "Personality Traits",
      onEdit: onEdit,
      child: traits.isEmpty
          ? Text(
              "No personality traits added yet",
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
              children: traits
                  .map(
                    (trait) => Chip(
                      label: trait,
                      isSelected: true,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
