import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../network/dio_provider.dart';

part 'auth_repository.g.dart';

/// Repository for authentication operations.
///
/// Handles:
/// - Google Sign-In
/// - Apple Sign-In (iOS only)
/// - Backend token verification
/// - Sign out
@riverpod
AuthRepository authRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio: dio);
}

class AuthRepository {
  final Dio _dio;

  AuthRepository({required Dio dio}) : _dio = dio;

  /// SharedPreferences key for caching OAuth prepopulated first name
  static const String prepopulatedFirstNameKey = 'auth_prepopulated_first_name';

  /// Get the current authenticated user value
  User? get currentUser => FirebaseAuth.instance.currentUser;

  /// Sign in with Google.
  ///
  /// Opens the Google Sign-In flow, then authenticates with Firebase.
  /// Returns the Firebase User on success, null on cancellation.
  /// Throws on error.
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // User cancelled the sign-in
      if (googleUser == null) return null;

      // Get the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a credential from the access token
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null &&
          user.displayName != null &&
          user.displayName!.isNotEmpty) {
        final firstName = user.displayName!.split(' ').first.trim();
        if (firstName.isNotEmpty) {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(prepopulatedFirstNameKey, firstName);
          } catch (e) {
            debugPrint('Failed to cache prepopulated first name from Google: $e');
          }
        }
      }

      return user;
    } catch (e) {
      throw AuthException(
        code: 'google-sign-in-failed',
        message: 'Google Sign-In failed: ${e.toString()}',
      );
    }
  }

  /// Sign in with Apple (iOS only).
  ///
  /// Opens the Apple Sign-In flow, then authenticates with Firebase.
  /// Returns the Firebase User on success.
  /// Throws on error or cancellation.
  Future<User?> signInWithApple() async {
    // Apple Sign-In is only available on iOS
    if (kIsWeb || !Platform.isIOS) {
      throw AuthException(
        code: 'apple-sign-in-unavailable',
        message: 'Apple Sign-In is only available on iOS',
      );
    }

    try {
      // Generate nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request Apple Sign-In
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an OAuth credential from the Apple credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      // Apple only sends the name on first sign-in, so update profile if needed
      final user = userCredential.user;
      final givenName = appleCredential.givenName?.trim();
      final familyName = appleCredential.familyName?.trim();
      final fullName = [
        if (givenName != null && givenName.isNotEmpty) givenName,
        if (familyName != null && familyName.isNotEmpty) familyName,
      ].join(' ').trim();

      if (user != null) {
        if (fullName.isNotEmpty &&
            (user.displayName == null || user.displayName!.isEmpty)) {
          await user.updateDisplayName(fullName);
          await user.reload();
        }

        // Determine first name to cache for onboarding pre-population
        String? firstNameToCache;
        if (givenName != null && givenName.isNotEmpty) {
          firstNameToCache = givenName;
        } else {
          final effectiveUser = FirebaseAuth.instance.currentUser ?? user;
          if (effectiveUser.displayName != null &&
              effectiveUser.displayName!.isNotEmpty) {
            firstNameToCache =
                effectiveUser.displayName!.split(' ').first.trim();
          }
        }

        if (firstNameToCache != null && firstNameToCache.isNotEmpty) {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(prepopulatedFirstNameKey, firstNameToCache);
          } catch (e) {
            debugPrint('Failed to cache prepopulated first name from Apple: $e');
          }
        }
      }

      return FirebaseAuth.instance.currentUser ?? user;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return null; // User cancelled
      }
      throw AuthException(
        code: 'apple-sign-in-failed',
        message: 'Apple Sign-In failed: ${e.message}',
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        code: 'apple-sign-in-failed',
        message: 'Apple Sign-In failed: ${e.toString()}',
      );
    }
  }

  /// Verify the Firebase token with the backend.
  ///
  /// Calls POST /auth/verifyToken with the Firebase ID token.
  /// The backend will create a new user if one doesn't exist.
  ///
  /// Returns the response data on success.
  /// Throws on error.
  Future<Map<String, dynamic>> verifyTokenWithBackend() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw AuthException(
        code: 'no-user',
        message: 'No authenticated user found',
      );
    }

    final idToken = await user.getIdToken();

    final response = await _dio.post(
      '/auth/verifyToken',
      data: {'idToken': idToken},
      options: Options(extra: {'skipAuth': true}),
    );

    return response.data as Map<String, dynamic>;
  }

  /// Sign out from Firebase.
  Future<void> signOut() async {
    try {
      await clearPrepopulatedFirstName();
    } catch (_) {}

    // Sign out from Google if signed in via Google
    try {
      await GoogleSignIn().signOut();
    } catch (_) {
      // Ignore errors - user might not have signed in via Google
    }

    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();
  }

  /// Get the pre-populated first name cached from OAuth login (Apple or Google).
  Future<String?> getPrepopulatedFirstName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(prepopulatedFirstNameKey);
    } catch (_) {
      return null;
    }
  }

  /// Clear the pre-populated first name cache.
  Future<void> clearPrepopulatedFirstName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(prepopulatedFirstNameKey);
    } catch (_) {}
  }

  /// Generates a cryptographically secure random nonce.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

/// Custom exception for auth errors.
class AuthException implements Exception {
  final String code;
  final String message;

  AuthException({required this.code, required this.message});

  @override
  String toString() => 'AuthException: [$code] $message';
}
