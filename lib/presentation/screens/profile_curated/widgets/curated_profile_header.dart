import "package:flutter/material.dart";

/// Profile header widget for the curated profile screen.
///
/// Displays circular avatar placeholder with camera icon, name + age,
/// and subtitle text. All content is center-aligned.
class CuratedProfileHeader extends StatelessWidget {
  final String name;
  final int age;
  final String subtitle;
  final String? avatarUrl;

  const CuratedProfileHeader({
    super.key,
    required this.name,
    required this.age,
    required this.subtitle,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Circular avatar placeholder
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: avatarUrl != null
              ? ClipOval(
                  child: Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholder(colorScheme),
                  ),
                )
              : _buildPlaceholder(colorScheme),
        ),
        const SizedBox(height: 20),
        // Name + Age
        Text(
          "$name, $age",
          style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Center(
      child: Icon(
        Icons.camera_alt_outlined,
        size: 40,
        color: colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }
}
