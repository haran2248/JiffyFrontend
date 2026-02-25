import "profile_curated_data.dart";

/// Immutable state for the profile curated screen viewmodel.
///
/// Manages loading, error handling, and the curated profile data.
class ProfileCuratedState {
  final ProfileCuratedData? data;
  final bool isLoading;
  final String? error;

  /// Whether the curated profile is incomplete because the user
  /// skipped the chat-based onboarding.
  final bool isIncomplete;

  const ProfileCuratedState({
    this.data,
    this.isLoading = false,
    this.error,
    this.isIncomplete = false,
  });

  /// Creates a copy with modified fields.
  ///
  /// Uses a function for [error] to allow setting it to null explicitly.
  ProfileCuratedState copyWith({
    ProfileCuratedData? data,
    bool? isLoading,
    String? Function()? error,
    bool? isIncomplete,
  }) {
    return ProfileCuratedState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      isIncomplete: isIncomplete ?? this.isIncomplete,
    );
  }

  /// Whether the state has valid data to display
  bool get hasData => data != null;

  /// Whether the state is in an error state
  bool get hasError => error != null;
}
