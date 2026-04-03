import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/result.dart';
import '../../../../data/models/report_unmatch/action_requests.dart';
import '../../../../data/repositories/report_unmatch_repository.dart';
import '../models/report_unmatch_state.dart';

part 'report_unmatch_viewmodel.g.dart';

@riverpod
class ReportUnmatchViewModel extends _$ReportUnmatchViewModel {
  @override
  ReportUnmatchState build() {
    // Watch the repository so the viewmodel is tied to the active instance
    final repository = ref.watch(reportUnmatchRepositoryProvider);
    ref.onDispose(repository.cancelPendingRequests);
    return const ReportUnmatchState();
  }

  void selectReason(String reasonKey) {
    state = state.copyWith(
      selectedReasonKey: reasonKey,
      clearError: true,
      isSuccess: false,
    );
  }

  void clearSelection() {
    state = state.copyWith(clearSelectedReasonKey: true, clearError: true, isSuccess: false);
  }

  Future<void> fetchReasons({required bool forReport}) async {
    final type = forReport ? 'report' : 'unmatch';
    
    // Skip fetching if already loaded
    if (forReport && state.reportReasons.isNotEmpty) return;
    if (!forReport && state.unmatchReasons.isNotEmpty) return;

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(reportUnmatchRepositoryProvider).fetchReasons(type);
    if (!ref.mounted) return;

    switch (result) {
      case Success(:final data):
        state = state.copyWith(
          isLoading: false,
          reportReasons: forReport ? data : state.reportReasons,
          unmatchReasons: forReport ? state.unmatchReasons : data,
        );
      case Failure(:final error):
        state = state.copyWith(isLoading: false, error: error);
    }
  }

  Future<void> submitUnmatch({
    required String currentUserId,
    required String matchedUserId,
    String? details,
  }) async {
    if (!state.isFormValid) return;

    state = state.copyWith(isLoading: true, clearError: true);

    final request = UnmatchRequest(
      userId: currentUserId,
      matchedUserId: matchedUserId,
      reasonKey: state.selectedReasonKey!,
      details: details,
    );

    final result = await ref.read(reportUnmatchRepositoryProvider).unmatch(request);
    if (!ref.mounted) return;

    switch (result) {
      case Success():
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          clearSelectedReasonKey: true,
        );
      case Failure(:final error):
        state = state.copyWith(isLoading: false, error: error);
    }
  }

  Future<void> submitReportAndUnmatch({
    required String currentUserId,
    required String reportedUserId,
    String? details,
  }) async {
    if (!state.isFormValid) return;

    state = state.copyWith(isLoading: true, clearError: true);

    final request = ReportRequest(
      reporterUserId: currentUserId,
      reportedUserId: reportedUserId,
      reasonKey: state.selectedReasonKey!,
      details: details,
    );

    final result = await ref.read(reportUnmatchRepositoryProvider).reportAndUnmatch(request);
    if (!ref.mounted) return;

    switch (result) {
      case Success():
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          clearSelectedReasonKey: true,
        );
      case Failure(:final error):
        state = state.copyWith(isLoading: false, error: error);
    }
  }
}
