import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/core/navigation/app_routes.dart';
import 'package:jiffy/presentation/screens/home/widgets/home_chip_row_widget.dart' show homeChipRowProvider;

class VibeCheckScoreSheet extends ConsumerWidget {
  final int score;
  final String story;
  final String chipId;

  const VibeCheckScoreSheet({
    required this.score,
    required this.story,
    required this.chipId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final scoreColor = _scoreColor(score, colorScheme);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),

            // Chip label
            Text(
              '${_chipLabel(chipId)} Score',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Score
            Text(
              '$score / 10',
              style: textTheme.displayLarge?.copyWith(
                color: scoreColor,
                fontWeight: FontWeight.bold,
                fontSize: 52,
              ),
            ),
            const SizedBox(height: 20),

            // Story
            if (story.isNotEmpty)
              Text(
                '"$story"',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),

            const SizedBox(height: 32),

            // See your matches CTA
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ref.invalidate(homeChipRowProvider);
                  Navigator.of(context).pop();
                  context.go(AppRoutes.home);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text('See your matches →'),
              ),
            ),
            const SizedBox(height: 12),

            // Continue exploring
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  ref.invalidate(homeChipRowProvider);
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Continue exploring'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(int score, ColorScheme cs) {
    if (score >= 7) return cs.primary;
    if (score >= 4) return cs.onSurface;
    return cs.onSurface.withValues(alpha: 0.5);
  }

  String _chipLabel(String chipId) {
    const labels = {
      'flirty': 'Flirty',
      'fun_chill': 'Fun & Chill',
      'wholesome': 'Wholesome',
      'deep_thinker': 'Deep Thinker',
      'funny': 'Funny',
      'serious_dating': 'Serious Dating',
      'just_exploring': 'Just Exploring',
      'sporty': 'Sporty',
      'creative': 'Creative',
    };
    return labels[chipId] ?? chipId;
  }
}
