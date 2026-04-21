import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/core/navigation/app_routes.dart';
import 'package:jiffy/core/network/dio_provider.dart';
import 'package:jiffy/core/theme/app_colors.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_chip_row_widget.g.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

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

const _chipCategories = {
  'flirty': 'vibe',
  'fun_chill': 'vibe',
  'wholesome': 'vibe',
  'deep_thinker': 'personality',
  'funny': 'personality',
  'serious_dating': 'intent',
  'just_exploring': 'intent',
  'sporty': 'lifestyle',
  'creative': 'lifestyle',
};

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class HomeChipData {
  final List<String> allChips;
  final Set<String> selectedChips; // user's active chip selections (max 2)
  final Set<String> probedChips;   // chips with a score in chipScores

  const HomeChipData({
    required this.allChips,
    required this.selectedChips,
    required this.probedChips,
  });

  bool isSelected(String id) => selectedChips.contains(id);
  bool isProbed(String id) => probedChips.contains(id);
  bool get canSelectMore => selectedChips.length < 2;

  List<String> get unprobedSelected =>
      selectedChips.where((id) => !probedChips.contains(id)).toList();
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

@riverpod
class HomeChipRow extends _$HomeChipRow {
  @override
  Future<HomeChipData> build() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const HomeChipData(
          allChips: _allProbeChips, selectedChips: {}, probedChips: {});
    }

    final dio = ref.watch(dioProvider);
    try {
      final response = await dio.get(
        '/api/users/getUser',
        queryParameters: {'uid': userId},
      );
      final data = response.data as Map<String, dynamic>? ?? {};

      final selections = data['chipSelections'] as Map<String, dynamic>? ?? {};
      final selectedChips = selections.values
          .expand((v) => (v as List<dynamic>).map((e) => e.toString()))
          .toSet();

      final scores = data['chipScores'] as Map<String, dynamic>? ?? {};
      final probedChips = scores.keys.toSet();

      return HomeChipData(
        allChips: _allProbeChips,
        selectedChips: selectedChips,
        probedChips: probedChips,
      );
    } on DioException catch (e) {
      debugPrint('HomeChipRow: fetch error: $e');
      return const HomeChipData(
          allChips: _allProbeChips, selectedChips: {}, probedChips: {});
    }
  }

  Future<void> selectChip(String chipId) async {
    final current = state.value;
    if (current == null) return;
    if (current.isSelected(chipId) || !current.canSelectMore) return;

    final newSelected = {...current.selectedChips, chipId};

    // Optimistic update
    state = AsyncData(HomeChipData(
      allChips: current.allChips,
      selectedChips: newSelected,
      probedChips: current.probedChips,
    ));

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final payload = <String, List<String>>{};
      for (final id in newSelected) {
        final cat = _chipCategories[id] ?? 'other';
        payload.putIfAbsent(cat, () => []).add(id);
      }

      final dio = ref.read(dioProvider);
      await dio.post(
        '/api/users/chipSelections',
        data: payload,
        queryParameters: {'uid': userId},
      );
    } catch (e) {
      debugPrint('HomeChipRow: selectChip error: $e');
      ref.invalidateSelf();
    }
  }

  Future<void> deselectChip(String chipId) async {
    final current = state.value;
    if (current == null || !current.isSelected(chipId)) return;

    final newSelected = {...current.selectedChips}..remove(chipId);

    // Optimistic update
    state = AsyncData(HomeChipData(
      allChips: current.allChips,
      selectedChips: newSelected,
      probedChips: current.probedChips,
    ));

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final payload = <String, List<String>>{};
      for (final id in newSelected) {
        final cat = _chipCategories[id] ?? 'other';
        payload.putIfAbsent(cat, () => []).add(id);
      }

      final dio = ref.read(dioProvider);
      await dio.post(
        '/api/users/chipSelections',
        data: payload,
        queryParameters: {'uid': userId},
      );
    } catch (e) {
      debugPrint('HomeChipRow: deselectChip error: $e');
      ref.invalidateSelf();
    }
  }
}

// ---------------------------------------------------------------------------
// Chip label helper
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
    final chipAsync = ref.watch(homeChipRowProvider);

    return chipAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) => SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          itemCount: data.allChips.length,
          itemBuilder: (context, index) {
            final id = data.allChips[index];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _ChipPill(chipId: id, data: data),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chip pill — three visual states
// ---------------------------------------------------------------------------

class _ChipPill extends ConsumerWidget {
  final String chipId;
  final HomeChipData data;

  const _ChipPill({required this.chipId, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = data.isSelected(chipId);
    final isProbed = data.isProbed(chipId);

    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final FontWeight fontWeight;
    final List<BoxShadow>? shadows;

    if (!isProbed) {
      // Unprobed — always shows badge, always opens probe chat
      bgColor = AppColors.surfacePlum;
      borderColor = AppColors.surfacePlumLight;
      textColor = AppColors.textPrimary;
      fontWeight = FontWeight.w400;
      shadows = null;
    } else if (!isSelected) {
      // Probed, not selected — available to pick
      bgColor = AppColors.noir;
      borderColor = AppColors.surfacePlum;
      textColor = AppColors.textSecondary;
      fontWeight = FontWeight.w400;
      shadows = null;
    } else {
      // Probed + selected — active filter
      bgColor = AppColors.primaryRaspberry;
      borderColor = AppColors.primaryRaspberry;
      textColor = AppColors.textPrimary;
      fontWeight = FontWeight.w600;
      shadows = [
        BoxShadow(
          color: AppColors.primaryRaspberry.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            if (!isProbed) {
              // Unprobed → always open probe chat
              context.push('${AppRoutes.vibeCheckBase}/$chipId');
            } else if (isSelected) {
              // Probed + selected → deselect
              ref.read(homeChipRowProvider.notifier).deselectChip(chipId);
            } else {
              // Probed, not selected → select if room
              if (!data.canSelectMore) {
                HapticFeedback.heavyImpact();
                return;
              }
              ref.read(homeChipRowProvider.notifier).selectChip(chipId);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: shadows,
            ),
            child: Text(
              chipLabel(chipId),
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ),
        // Dot badge — on all unprobed chips
        if (!isProbed)
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryRaspberry,
                border: Border.all(color: AppColors.midnightPlum, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
