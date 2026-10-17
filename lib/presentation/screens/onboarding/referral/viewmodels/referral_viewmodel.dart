import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jiffy/core/services/service_providers.dart';

part 'referral_viewmodel.g.dart';

class ReferralState {
  final String code;
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final bool isAlreadyApplied;

  const ReferralState({
    this.code = '',
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.isAlreadyApplied = false,
  });

  ReferralState copyWith({
    String? code,
    bool? isLoading,
    String? Function()? error,
    String? Function()? successMessage,
    bool? isAlreadyApplied,
  }) {
    return ReferralState(
      code: code ?? this.code,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      successMessage:
          successMessage != null ? successMessage() : this.successMessage,
      isAlreadyApplied: isAlreadyApplied ?? this.isAlreadyApplied,
    );
  }
}

@riverpod
class ReferralViewModel extends _$ReferralViewModel {
  @override
  ReferralState build() {
    _checkInitialStatus();
    return const ReferralState();
  }

  void _checkInitialStatus() async {
    try {
      final acquisitionService = ref.read(acquisitionServiceProvider);
      final isSet = await acquisitionService.hasInviteCodeSet();
      if (isSet && ref.mounted) {
        state = state.copyWith(isAlreadyApplied: true);
      }
    } catch (_) {}
  }

  void updateCode(String code) {
    state = state.copyWith(
      code: code.toUpperCase().trim(),
      error: () => null,
      successMessage: () => null,
    );
  }

  Future<bool> submitCode() async {
    if (state.isLoading || state.isAlreadyApplied) return false;

    final trimmed = state.code.trim().toUpperCase();
    if (trimmed.isEmpty) {
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      error: () => null,
      successMessage: () => null,
    );

    try {
      final acquisitionService = ref.read(acquisitionServiceProvider);
      final result = await acquisitionService.submitInviteCode(trimmed);

      if (!ref.mounted) return false;

      if (result.success) {
        state = state.copyWith(
          isLoading: false,
          successMessage: () => result.message,
          isAlreadyApplied: true,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: () => result.message,
        );
        return false;
      }
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: () => "That code doesn't look right",
      );
      return false;
    }
  }
}

