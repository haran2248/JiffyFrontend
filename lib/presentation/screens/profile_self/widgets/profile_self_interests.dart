import "package:flutter/material.dart" hide Chip;

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
    this.title = "INTERESTS",
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        interests.isEmpty
            ? Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "No items added yet",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interests.map((interest) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      interest,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }
}
