/// Authentication state model.
///
/// Represents the current authentication status of the user.
enum AuthStatus {
  /// Initial state - checking if user is logged in
  unknown,

  /// User is authenticated with Firebase
  authenticated,

  /// User is not authenticated
  unauthenticated,
}

/// Immutable authentication state.
///
/// Contains the current auth status and user information if authenticated.
class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isGoogleLoading;
  final bool isAppleLoading;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.userId,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isGoogleLoading = false,
    this.isAppleLoading = false,
    this.errorMessage,
  });

  /// Initial state when app starts
  factory AuthState.initial() => const AuthState();

  /// User is authenticated
  factory AuthState.authenticated({
    required String userId,
    String? email,
    String? displayName,
    String? photoUrl,
  }) =>
      AuthState(
        status: AuthStatus.authenticated,
        userId: userId,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
      );

  /// User is not authenticated
  factory AuthState.unauthenticated() => const AuthState(
        status: AuthStatus.unauthenticated,
      );

  /// Loading state for Google sign-in
  AuthState copyWithGoogleLoading({bool isLoading = true}) => AuthState(
        status: status,
        userId: userId,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        isGoogleLoading: isLoading,
        isAppleLoading: false,
        errorMessage: null,
      );

  /// Loading state for Apple sign-in
  AuthState copyWithAppleLoading({bool isLoading = true}) => AuthState(
        status: status,
        userId: userId,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        isGoogleLoading: false,
        isAppleLoading: isLoading,
        errorMessage: null,
      );

  /// Error state
  AuthState copyWithError(String message) => AuthState(
        status: status,
        userId: userId,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        isGoogleLoading: false,
        isAppleLoading: false,
        errorMessage: message,
      );

  /// Copy with new values
  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isGoogleLoading,
    bool? isAppleLoading,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      isAppleLoading: isAppleLoading ?? this.isAppleLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isUnknown => status == AuthStatus.unknown;
  bool get isLoading => isGoogleLoading || isAppleLoading;
}
