import "package:flutter/material.dart";
import "package:jiffy/presentation/screens/profile/models/profile_data.dart";

/// Conversation Starter prompt widget
class ProfileConversationStarter extends StatelessWidget {
  final ProfileData profile;

  const ProfileConversationStarter({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Always show this section (use default text if not provided or empty/whitespace)
    final conversationStarterText =
        (profile.conversationStarter?.trim().isNotEmpty ?? false)
            ? profile.conversationStarter!
            : "Ask me about my most recent travel mishap!";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.2),
            colorScheme.secondary.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Conversation Starter",
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            conversationStarterText,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
