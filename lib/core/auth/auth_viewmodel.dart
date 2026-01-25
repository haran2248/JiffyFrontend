import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'auth_repository.dart'
    show AuthException, AuthRepository, authRepositoryProvider;
import 'auth_state.dart';

part 'auth_viewmodel.g.dart';

/// ViewModel managing authentication state.
///
/// Listens to Firebase auth state changes and provides methods for:
/// - Google Sign-In
/// - Apple Sign-In
/// - Sign out
///
/// Usage in widgets:
/// ```dart
/// final authState = ref.watch(authViewModelProvider);
/// final authViewModel = ref.read(authViewModelProvider.notifier);
///
/// // Sign in
/// await authViewModel.signInWithGoogle();
///
/// // Check state
/// if (authState.isAuthenticated) { ... }
/// ```
@riverpod
class AuthViewModel extends _$AuthViewModel {
  StreamSubscription<User?>? _authSubscription;

  @override
  AuthState build() {
    // Listen to Firebase auth state changes
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);

    // Cleanup subscription when provider is disposed
    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    // Start with unknown state - the authStateChanges listener will
    // determine the actual auth state once Firebase is ready.
    // This prevents the login screen from flashing on hot restart.
    return AuthState.initial();
  }

  void _onAuthStateChanged(User? user) {
    if (user != null) {
      state = AuthState.authenticated(
        userId: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
    } else {
      state = AuthState.unauthenticated();
    }
  }

  /// Sign in with Google.
  ///
  /// Returns true on success, false on cancellation.
  /// Sets error state on failure.
  Future<bool> signInWithGoogle() async {
    state = state.copyWithGoogleLoading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signInWithGoogle();

      if (user == null) {
        // User cancelled
        state = state.copyWith(isGoogleLoading: false);
        return false;
      }

      // Verify token with backend
      await _verifyWithBackend(repository);

      // Reset loading state - auth state listener will update status
      state = state.copyWith(isGoogleLoading: false);

      return true;
    } on AuthException catch (e) {
      state = state.copyWithError(e.message);
      return false;
    } catch (e) {
      state = state.copyWithError('Sign-in failed. Please try again.');
      debugPrint('Google Sign-In error: $e');
      return false;
    }
  }

  /// Sign in with Apple (iOS only).
  ///
  /// Returns true on success, false on cancellation.
  /// Sets error state on failure.
  Future<bool> signInWithApple() async {
    state = state.copyWithAppleLoading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signInWithApple();

      if (user == null) {
        // User cancelled
        state = state.copyWith(isAppleLoading: false);
        return false;
      }

      // Verify token with backend
      await _verifyWithBackend(repository);

      // Reset loading state - auth state listener will update status
      state = state.copyWith(isAppleLoading: false);

      return true;
    } on AuthException catch (e) {
      state = state.copyWithError(e.message);
      return false;
    } catch (e) {
      state = state.copyWithError('Sign-in failed. Please try again.');
      debugPrint('Apple Sign-In error: $e');
      return false;
    }
  }

  /// Verify the Firebase token with the backend.
  Future<void> _verifyWithBackend(AuthRepository repository) async {
    try {
      await repository.verifyTokenWithBackend();
    } catch (e) {
      // Log but don't fail - user is authenticated with Firebase
      // Backend verification can be retried later
      debugPrint('Backend verification failed: $e');
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    state = state.copyWith(isGoogleLoading: true, isAppleLoading: true);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signOut();
      // State will be updated by the auth state listener
    } catch (e) {
      state = state.copyWithError('Sign-out failed. Please try again.');
      debugPrint('Sign-out error: $e');
    }
  }

  /// Clear any error message.
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}
