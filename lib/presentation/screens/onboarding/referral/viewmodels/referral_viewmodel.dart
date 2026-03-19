import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jiffy/core/network/errors/api_error.dart';
import 'package:jiffy/presentation/screens/onboarding/referral/data/coupon_repository.dart';
import 'package:jiffy/core/auth/auth_viewmodel.dart';

part 'referral_viewmodel.g.dart';

class ReferralState {
  final String code;
  final bool isLoading;
  final String? error;

  const ReferralState({
    this.code = '',
    this.isLoading = false,
    this.error,
  });

  ReferralState copyWith({
    String? code,
    bool? isLoading,
    String? Function()? error,
  }) {
    return ReferralState(
      code: code ?? this.code,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }
}

@riverpod
class ReferralViewModel extends _$ReferralViewModel {
  @override
  ReferralState build() {
    return const ReferralState();
  }

  void updateCode(String code) {
    state = state.copyWith(code: code, error: () => null);
  }

  Future<bool> submitCode() async {
    if (state.isLoading) return false;
    
    if (state.code.trim().isEmpty) {
      state = state.copyWith(error: () => 'Referral code cannot be empty.');
      return false;
    }

    state = state.copyWith(isLoading: true, error: () => null);

    try {
      final repository = ref.read(couponRepositoryProvider);
      final authState = ref.read(authViewModelProvider);
      
      final userId = authState.userId;
      if (userId == null || userId.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: () => 'User not authenticated. Please restart the app.',
        );
        return false;
      }

      await repository.activateReferral(state.code.trim(), userId);
      
      if (!ref.mounted) return false;
      
      state = state.copyWith(isLoading: false);
      return true;
    } on ApiError catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: () => e.message,
      );
      return false;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: () => 'An unexpected error occurred. Please try again.',
      );
      return false;
    }
  }
}
