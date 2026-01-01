import "package:flutter/material.dart" hide Chip;
import "package:jiffy/presentation/widgets/chip.dart";
import "profile_self_section_card.dart";

/// Interests section widget for profile self screen.
///
/// Displays interest chips in a responsive wrap layout.
class ProfileSelfInterests extends StatelessWidget {
  final List<String> interests;
  final VoidCallback? onEdit;

  const ProfileSelfInterests({
    super.key,
    required this.interests,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileSelfSectionCard(
      title: "Interests",
      onEdit: onEdit,
      child: Wrap(
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
