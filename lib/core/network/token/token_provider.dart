/// Abstract interface for Firebase token management.
///
/// This interface allows the networking layer to remain independent of
/// Firebase SDK integration. The concrete implementation will use
/// Firebase Auth to get and refresh ID tokens.
///
/// SwishBackend uses Firebase Authentication:
/// - Tokens are Firebase ID tokens (not custom JWTs)
/// - Token refresh is handled by Firebase SDK automatically
/// - Backend expects `Authorization: Bearer <firebaseIdToken>`
///
/// Implementation example with Riverpod and Firebase:
/// ```dart
/// @riverpod
/// class FirebaseTokenProvider extends _$FirebaseTokenProvider implements TokenProvider {
///   @override
///   Future<String?> getAccessToken() async {
///     final user = FirebaseAuth.instance.currentUser;
///     if (user == null) return null;
///     // getIdToken(true) forces refresh if expired
///     return user.getIdToken();
///   }
///
///   @override
///   Future<String?> getRefreshToken() async {
///     // Firebase handles refresh internally via getIdToken()
///     return null;
///   }
///
///   @override
///   Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
///     // Firebase manages tokens internally - nothing to save
///   }
///
///   @override
///   Future<void> clearTokens() async {
///     await FirebaseAuth.instance.signOut();
///   }
///
///   @override
///   void onTokenRefreshFailed() {
///     // Navigate to login, Firebase will clear credentials on signOut
///     ref.read(routerProvider).go('/login');
///   }
/// }
/// ```
abstract interface class TokenProvider {
  /// Retrieves the current Firebase ID token.
  ///
  /// For Firebase, this should call `FirebaseAuth.instance.currentUser?.getIdToken()`.
  /// Firebase SDK automatically refreshes expired tokens.
  ///
  /// Returns null if user is not logged in.
  Future<String?> getAccessToken();

  /// Retrieves the refresh token.
  ///
  /// For Firebase Authentication, this is typically not used because
  /// Firebase handles token refresh automatically via `getIdToken()`.
  ///
  /// Returns null for Firebase implementations.
  Future<String?> getRefreshToken();

  /// Saves tokens after login.
  ///
  /// For Firebase, this is typically a no-op because Firebase
  /// manages tokens internally. Only needed if storing custom tokens.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Clears all stored tokens / signs out user.
  ///
  /// For Firebase, this should call `FirebaseAuth.instance.signOut()`.
  Future<void> clearTokens();

  /// Called when authentication has failed.
  ///
  /// This signals to the application that the user needs to log in again.
  /// The implementation should:
  /// 1. Sign out from Firebase
  /// 2. Navigate to login screen
  /// 3. Show appropriate message to user
  ///
  /// This is called by interceptors when:
  /// - User token is missing
  /// - Firebase token verification fails (401 from backend)
  void onTokenRefreshFailed();
}

/// Response model for token refresh endpoint.
///
/// Note: For SwishBackend with Firebase Auth, this is typically not used
/// because Firebase handles token refresh automatically. This is kept
/// for compatibility with traditional JWT backends.
class TokenResponse {
  final String accessToken;
  final String refreshToken;

  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
}
