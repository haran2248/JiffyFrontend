import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jiffy/core/services/service_providers.dart';
import 'package:jiffy/presentation/screens/home/models/home_data.dart';

part 'home_viewmodel.g.dart';

/// ViewModel state for home screen
class HomeState {
  final HomeData? data;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    HomeData? data,
    bool? isLoading,
    String? Function()? error,
  }) {
    return HomeState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }
}

/// ViewModel for home screen
@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeState build() {
    // Load data on initialization after build completes
    Future.microtask(() => loadHomeData());
    return const HomeState(isLoading: true);
  }

  /// Load home screen data from service
  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, error: () => null);

    try {
      final homeService = ref.read(homeServiceProvider);
      final data = await homeService.fetchHomeData();
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.toString(),
      );
    }
  }

  /// Refresh home data
  Future<void> refresh() async {
    await loadHomeData();
  }

  /// Load more suggestions (pagination)
  Future<void> loadMoreSuggestions() async {
    // TODO: Implement pagination
    // This can be extended to append more suggestions to existing data
  }
}

