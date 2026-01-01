import "package:flutter/material.dart";
import "profile_self_section_card.dart";

/// About Me section widget for profile self screen.
///
/// Displays AI-generated bio text with edit option and beginner-friendly CTA.
class ProfileSelfAboutMe extends StatelessWidget {
  final String aboutMeText;
  final VoidCallback? onEdit;
  final VoidCallback? onBeginnerEdit;

  const ProfileSelfAboutMe({
    super.key,
    required this.aboutMeText,
    this.onEdit,
    this.onBeginnerEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ProfileSelfSectionCard(
      title: "About Me",
      onEdit: onEdit,
      ctaText: "Beginner-friendly edit",
      onCtaTap: onBeginnerEdit ?? onEdit,
      child: Text(
        aboutMeText,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.8),
          height: 1.6,
        ),
      ),
    );
  }
}
