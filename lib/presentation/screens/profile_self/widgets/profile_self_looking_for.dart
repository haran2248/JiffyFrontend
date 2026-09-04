import "package:flutter/material.dart";

/// "What You're Looking For" section widget for profile self screen.
class ProfileSelfLookingFor extends StatelessWidget {
  final String? relationshipGoals;
  final VoidCallback? onEdit;

  const ProfileSelfLookingFor({
    super.key,
    this.relationshipGoals,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (relationshipGoals == null || relationshipGoals!.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // Split by comma in case we want to support multiple tags easily, 
    // though currently it's likely a single string.
    final goals = relationshipGoals!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "WHAT YOU'RE LOOKING FOR",
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: goals.map((goal) {
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
                goal,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        if (onEdit != null)
          InkWell(
            onTap: onEdit,
            child: Text(
              "this feels off — update it",
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }
}
