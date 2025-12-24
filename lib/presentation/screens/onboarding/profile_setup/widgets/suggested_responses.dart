import 'package:flutter/material.dart';
import 'package:jiffy/core/theme/app_colors.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfacePlum,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryViolet.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
        ),
      ),
    );
  }
}

