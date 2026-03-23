import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jiffy/core/network/dio_provider.dart';
import 'package:jiffy/core/auth/auth_repository.dart';
import 'package:jiffy/presentation/screens/onboarding/pulse_check/models/chip_category.dart';

part 'pulse_check_viewmodel.g.dart';

class PulseCheckState {
  final List<ChipCategory> categories;
  final Set<String> selectedOptionIds;
  final bool isLoadingCategories;
  final bool isSaving;
  final String? error;

  const PulseCheckState({
    this.categories = const [],
    this.selectedOptionIds = const {},
    this.isLoadingCategories = false,
    this.isSaving = false,
    this.error,
  });

  bool get canProceed =>
      categories.isNotEmpty &&
      categories.every(
        (cat) => cat.options.any((o) => selectedOptionIds.contains(o.id)),
      );

  PulseCheckState copyWith({
    List<ChipCategory>? categories,
    Set<String>? selectedOptionIds,
    bool? isLoadingCategories,
    bool? isSaving,
    String? Function()? error,
  }) {
    return PulseCheckState(
      categories: categories ?? this.categories,
      selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      isSaving: isSaving ?? this.isSaving,
      error: error != null ? error() : this.error,
    );
  }
}

@riverpod
class PulseCheckViewModel extends _$PulseCheckViewModel {
  @override
  PulseCheckState build() {
    // Kick off the chip fetch on creation
    Future.microtask(() => fetchCategories());
    return const PulseCheckState(isLoadingCategories: true);
  }

  Future<void> fetchCategories() async {
    state = state.copyWith(isLoadingCategories: true, error: () => null);
    try {
      final dio = ref.read(dioProvider);
      // Chips API is public — no auth header needed, use absolute URL
      final response = await dio.get(
        'https://limitless-sea-53782-2c45e56f3e92.herokuapp.com/api/chips',
      );
      final List<dynamic> data = response.data as List<dynamic>;
      final categories = data
          .map((e) => ChipCategory.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(
        categories: categories,
        isLoadingCategories: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingCategories: false,
        error: () => 'Could not load options. Please try again.',
      );
    }
  }

  void toggleOption(String optionId) {
    final updated = Set<String>.from(state.selectedOptionIds);
    if (updated.contains(optionId)) {
      updated.remove(optionId);
    } else {
      updated.add(optionId);
    }
    state = state.copyWith(selectedOptionIds: updated, error: () => null);
  }

  Future<bool> saveSelections() async {
    if (!state.canProceed || state.isSaving) return false;

    state = state.copyWith(isSaving: true, error: () => null);
    try {
      final dio = ref.read(dioProvider);
      final authRepo = ref.read(authRepositoryProvider);
      final user = authRepo.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Build the payload: list of selected option ids grouped by category
      final Map<String, List<String>> chipsByCategory = {};
      for (final category in state.categories) {
        final selected = category.options
            .where((o) => state.selectedOptionIds.contains(o.id))
            .map((o) => o.id)
            .toList();
        if (selected.isNotEmpty) {
          chipsByCategory[category.id] = selected;
        }
      }

      await dio.post(
        '/api/users/chips',
        data: {'chips': chipsByCategory},
        queryParameters: {'uid': user.uid},
      );

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      // Non-fatal: navigate forward even if save fails
      state = state.copyWith(isSaving: false);
      return true;
    }
  }
}
