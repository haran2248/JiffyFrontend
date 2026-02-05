import 'dart:typed_data';

/// Result of face verification matching
enum VerificationResult {
  matched,
  notMatched,
  error,
}

/// Immutable state for face verification screen
class FaceVerificationState {
  final Uint8List? referenceImage;
  final Uint8List? capturedImage;
  final bool isLoading;
  final bool isMatching;
  final bool isSdkInitialized;
  final double? similarityScore;
  final VerificationResult? result;
  final String? errorMessage;

  const FaceVerificationState({
    this.referenceImage,
    this.capturedImage,
    this.isLoading = false,
    this.isMatching = false,
    this.isSdkInitialized = false,
    this.similarityScore,
    this.result,
    this.errorMessage,
  });

  /// Check if verification was successful
  bool get isVerified => result == VerificationResult.matched;

  /// Check if ready to capture
  bool get canCapture =>
      isSdkInitialized && referenceImage != null && !isMatching;

  FaceVerificationState copyWith({
    Uint8List? referenceImage,
    Uint8List? capturedImage,
    bool? isLoading,
    bool? isMatching,
    bool? isSdkInitialized,
    double? similarityScore,
    VerificationResult? result,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
    bool clearReferenceImage = false,
    bool clearCapturedImage = false,
  }) {
    return FaceVerificationState(
      referenceImage:
          clearReferenceImage ? null : (referenceImage ?? this.referenceImage),
      capturedImage:
          clearCapturedImage ? null : (capturedImage ?? this.capturedImage),
      isLoading: isLoading ?? this.isLoading,
      isMatching: isMatching ?? this.isMatching,
      isSdkInitialized: isSdkInitialized ?? this.isSdkInitialized,
      similarityScore:
          clearResult ? null : (similarityScore ?? this.similarityScore),
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
