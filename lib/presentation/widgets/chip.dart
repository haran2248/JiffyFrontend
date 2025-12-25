import 'package:flutter/material.dart' hide Chip;

class Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const Chip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
        ),
      ),
    );
  }

  // Correction: isMe was copied from ChatBubble, changing to FontWeight.w500 for selected
  // Redoing the text style below in the next edit or file write?
  // Wait, I can't edit inside the write_to_file content string dynamically once verified.
  // I will correct the code content before sending.
}
