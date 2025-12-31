import "package:flutter/material.dart";

/// Header section with title and close button
class ConversationStarterHeader extends StatelessWidget {
  final String profileName;
  final VoidCallback onClose;

  const ConversationStarterHeader({
    super.key,
    required this.profileName,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Start a conversation with $profileName",
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Material(
            color: colorScheme.surface.withValues(alpha: 0),
            child: InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: colorScheme.onSurface,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

