import "profile_curated_data.dart";

/// Immutable state for the profile curated screen viewmodel.
///
/// Manages loading, error handling, and the curated profile data.
class ProfileCuratedState {
  final ProfileCuratedData? data;
  final bool isLoading;
  final String? error;

  const ProfileCuratedState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  /// Creates a copy with modified fields.
  ///
  /// Uses a function for [error] to allow setting it to null explicitly.
  ProfileCuratedState copyWith({
    ProfileCuratedData? data,
    bool? isLoading,
    String? Function()? error,
  }) {
    return ProfileCuratedState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }

  /// Whether the state has valid data to display
  bool get hasData => data != null;

  /// Whether the state is in an error state
  bool get hasError => error != null;
}
