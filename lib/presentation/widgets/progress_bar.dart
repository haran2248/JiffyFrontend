import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isCompleted = index < currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < totalSteps - 1 ? 4 : 0),
              decoration: BoxDecoration(
                gradient: isCompleted ? AppColors.primaryGradient : null,
                color:
                    isCompleted ? null : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
