import "package:flutter/material.dart";
import "package:jiffy/presentation/screens/profile/models/profile_data.dart";

/// Profile information section with avatar and status
class ConversationStarterProfileInfo extends StatelessWidget {
  final ProfileData profile;

  const ConversationStarterProfileInfo({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Profile picture
          CircleAvatar(
            radius: 24,
            backgroundImage: profile.photos.isNotEmpty
                ? NetworkImage(profile.photos[0].url)
                : null,
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: profile.photos.isEmpty
                ? Icon(
                    Icons.person,
                    color: colorScheme.onSurfaceVariant,
                    size: 24,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // Name and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Online now",
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

