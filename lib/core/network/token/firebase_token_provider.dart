import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'token_provider.dart';

part 'firebase_token_provider.g.dart';

/// Firebase implementation of [TokenProvider].
///
/// This provider integrates with Firebase Authentication to:
/// - Get Firebase ID tokens for API calls
/// - Handle sign-out
/// - Navigate to login on auth failures
///
/// Usage:
/// ```dart
/// final tokenProvider = ref.read(firebaseTokenProviderProvider);
/// final token = await tokenProvider.getAccessToken();
/// ```
@riverpod
class FirebaseTokenProvider extends _$FirebaseTokenProvider
    implements TokenProvider {
  @override
  void build() {
    // No-op build - this is a service provider, not a state provider
  }

  /// Gets the current Firebase ID token.
  ///
  /// Firebase SDK automatically handles token refresh when the token
  /// is expired or about to expire.
  ///
  /// Returns null if user is not logged in.
  @override
  Future<String?> getAccessToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      // getIdToken() will automatically refresh if expired
      return await user.getIdToken();
    } catch (e) {
      // Token retrieval failed - user might need to re-authenticate
      return null;
    }
  }

  /// Not used with Firebase - Firebase manages refresh internally.
  @override
  Future<String?> getRefreshToken() async {
    // Firebase handles token refresh automatically via getIdToken()
    return null;
  }

  /// Not used with Firebase - Firebase manages tokens internally.
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    // Firebase manages tokens internally - nothing to save
  }

  /// Signs out the current user from Firebase.
  @override
  Future<void> clearTokens() async {
    await FirebaseAuth.instance.signOut();
  }

  /// Called when authentication has completely failed.
  ///
  /// Signs out the user and navigation to login should be handled
  /// by the auth state listener.
  @override
  void onTokenRefreshFailed() {
    // Sign out and let the auth state listener handle navigation
    FirebaseAuth.instance.signOut();
  }
}
