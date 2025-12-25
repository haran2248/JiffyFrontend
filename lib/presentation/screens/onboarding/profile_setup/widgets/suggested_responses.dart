import 'package:flutter/material.dart';

class SuggestedResponses extends StatelessWidget {
  final List<String> responses;
  final Function(String) onSelect;

  const SuggestedResponses({
    super.key,
    required this.responses,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (responses.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: responses.map((response) {
          return _SuggestedResponseChip(
            text: response,
            onTap: () => onSelect(response),
          );
        }).toList(),
      ),
    );
  }
}

class _SuggestedResponseChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestedResponseChip({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ),
      ),
    );
  }
}
