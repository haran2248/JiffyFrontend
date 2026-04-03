import 'package:flutter/material.dart';

import '../../../../data/models/report_unmatch/reason_option.dart';

/// Reason tile following the exact selection pattern as chip.dart.
/// No inline text input — "Other" push is handled at the parent sheet level.
class ReasonSelectionTile extends StatelessWidget {
  final ReasonOption reason;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDestructive;

  const ReasonSelectionTile({
    super.key,
    required this.reason,
    required this.isSelected,
    required this.onTap,
    this.isDestructive = false,
  });

  IconData _getIcon(String iconString) {
    switch (iconString.toLowerCase()) {
      case 'heart':
        return Icons.favorite_border;
      case 'people':
        return Icons.people_outline;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'sparkles':
        return Icons.auto_awesome;
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'flag':
        return Icons.flag_outlined;
      case 'more':
      default:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDestructive
                    ? colorScheme.error.withValues(alpha: 0.1)
                    : colorScheme.secondary.withValues(alpha: 0.2))
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (isDestructive ? colorScheme.error : colorScheme.secondary)
                  : colorScheme.secondary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _getIcon(reason.icon),
                size: 18,
                color: isSelected
                    ? (isDestructive ? colorScheme.error : colorScheme.primary)
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  reason.label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? (isDestructive ? colorScheme.error : colorScheme.primary)
                        : colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: isDestructive ? colorScheme.error : colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
