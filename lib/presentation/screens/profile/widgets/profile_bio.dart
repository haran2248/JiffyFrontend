import "package:flutter/material.dart";
import "package:jiffy/presentation/screens/profile/models/profile_data.dart";

/// Bio section widget
class ProfileBio extends StatelessWidget {
  final ProfileData profile;

  const ProfileBio({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Text(
      profile.bio,
      style: textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.8),
        height: 1.5,
      ),
    );
  }
}

