import 'package:flutter/material.dart';

class VibeCheckProgressDots extends StatelessWidget {
  final int filledCount;

  const VibeCheckProgressDots({required this.filledCount, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < filledCount;
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? colorScheme.primary : Colors.transparent,
            border: Border.all(
              color: filled ? colorScheme.primary : colorScheme.outline,
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }
}
