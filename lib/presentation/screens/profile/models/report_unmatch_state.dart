import '../../../../core/network/errors/api_error.dart';
import '../../../../data/models/report_unmatch/reason_option.dart';

class ReportUnmatchState {
  final bool isLoading;
  final ApiError? error;
  final List<ReasonOption> unmatchReasons;
  final List<ReasonOption> reportReasons;
  final String? selectedReasonKey;
  final bool isSuccess; // Indication for UI that the action succeeded

  const ReportUnmatchState({
    this.isLoading = false,
    this.error,
    this.unmatchReasons = const [],
    this.reportReasons = const [],
    this.selectedReasonKey,
    this.isSuccess = false,
  });

  bool get isFormValid => selectedReasonKey != null;

  ReportUnmatchState copyWith({
    bool? isLoading,
    ApiError? error,
    bool clearError = false,
    List<ReasonOption>? unmatchReasons,
    List<ReasonOption>? reportReasons,
    String? selectedReasonKey,
    bool clearSelectedReasonKey = false,
    bool? isSuccess,
  }) {
    return ReportUnmatchState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      unmatchReasons: unmatchReasons ?? this.unmatchReasons,
      reportReasons: reportReasons ?? this.reportReasons,
      selectedReasonKey: clearSelectedReasonKey
          ? null
          : (selectedReasonKey ?? this.selectedReasonKey),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
