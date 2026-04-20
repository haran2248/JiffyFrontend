import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/core/navigation/app_routes.dart';
import 'package:jiffy/presentation/screens/home/widgets/home_chip_row_widget.dart';

class VibeCheckBannerWidget extends ConsumerWidget {
  const VibeCheckBannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chipDataAsync = ref.watch(homeChipDataProvider);

    return chipDataAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (chipData) {
        final unprobed = chipData.allChips
            .where((id) => !chipData.probedChips.contains(id))
            .toList();

        if (unprobed.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _BannerCard(
            firstUnprobedChipId: unprobed.first,
            unprobedCount: unprobed.length,
          ),
        );
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  final String firstUnprobedChipId;
  final int unprobedCount;

  const _BannerCard({
    required this.firstUnprobedChipId,
    required this.unprobedCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: colorScheme.primary, width: 4),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prove your vibe',
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$unprobedCount chip${unprobedCount > 1 ? 's' : ''} waiting',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => context
                .push('${AppRoutes.vibeCheckBase}/$firstUnprobedChipId'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}
