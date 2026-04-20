import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/core/navigation/app_routes.dart';
import 'package:jiffy/core/network/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_chip_row_widget.g.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class HomeChipData {
  final List<String> allChips;
  final Set<String> probedChips;

  const HomeChipData({required this.allChips, required this.probedChips});
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

// All probe chips come from ChipConfigs (stable seed — 9 chips total).
// chipSelections stores old onboarding answers, not probe chip IDs.
const _allProbeChips = [
  'flirty',
  'fun_chill',
  'wholesome',
  'deep_thinker',
  'funny',
  'serious_dating',
  'just_exploring',
  'sporty',
  'creative',
];

@riverpod
Future<HomeChipData> homeChipData(Ref ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return const HomeChipData(allChips: [], probedChips: {});

  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get(
      '/api/users/getUser',
      queryParameters: {'uid': userId},
    );
    final data = response.data as Map<String, dynamic>? ?? {};

    // chipScores: Map<String, dynamic> — keys are probed chip IDs (score 0 is valid)
    final scores = data['chipScores'] as Map<String, dynamic>? ?? {};
    final probedChips = scores.keys.toSet();

    return HomeChipData(allChips: _allProbeChips, probedChips: probedChips);
  } on DioException catch (e) {
    debugPrint('HomeChipData: fetch error: $e');
    return const HomeChipData(allChips: [], probedChips: {});
  }
}

// ---------------------------------------------------------------------------
// Chip label helper (shared between row and banner)
// ---------------------------------------------------------------------------

String chipLabel(String chipId) {
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

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class HomeChipRowWidget extends ConsumerWidget {
  const HomeChipRowWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chipDataAsync = ref.watch(homeChipDataProvider);

    return chipDataAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (chipData) {
        if (chipData.allChips.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: chipData.allChips.length,
            itemBuilder: (context, index) {
              final id = chipData.allChips[index];
              final isUnprobed = !chipData.probedChips.contains(id);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _ChipPill(
                  chipId: id,
                  isUnprobed: isUnprobed,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ChipPill extends StatelessWidget {
  final String chipId;
  final bool isUnprobed;

  const _ChipPill({required this.chipId, required this.isUnprobed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isUnprobed
                ? () => context.push('${AppRoutes.vibeCheckBase}/$chipId')
                : null,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isUnprobed
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isUnprobed
                      ? colorScheme.outline
                      : colorScheme.primary,
                  width: 1,
                ),
              ),
              child: Text(
                chipLabel(chipId),
                style: textTheme.labelMedium?.copyWith(
                  color: isUnprobed
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.primary,
                  fontWeight: isUnprobed ? FontWeight.normal : FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        if (isUnprobed)
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary,
                border: Border.all(color: colorScheme.surface, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
