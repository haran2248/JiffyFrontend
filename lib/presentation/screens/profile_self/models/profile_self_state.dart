import "profile_self_data.dart";

/// Immutable state for the profile self screen viewmodel
class ProfileSelfState {
  final ProfileSelfData? data;
  final bool isLoading;
  final String? error;
  final bool isVerified;

  const ProfileSelfState({
    this.data,
    this.isLoading = false,
    this.error,
    this.isVerified = false,
  });

  ProfileSelfState copyWith({
    ProfileSelfData? data,
    bool? isLoading,
    String? Function()? error,
    bool? isVerified,
  }) {
    return ProfileSelfState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  /// Whether the state has valid data to display
  bool get hasData => data != null;

  /// Whether the state is in an error state
  bool get hasError => error != null;
}
