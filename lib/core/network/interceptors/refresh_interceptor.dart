import 'dart:async';

import 'package:dio/dio.dart';

import '../token/token_provider.dart';

/// Interceptor that handles 401 responses with Firebase token re-fetch.
///
/// SwishBackend uses Firebase Authentication, which differs from traditional
/// JWT refresh patterns:
///
/// - Firebase tokens are refreshed automatically by the Firebase SDK
/// - Calling `getIdToken()` returns a fresh token if the current one expires
/// - There's no `/auth/refresh` endpoint on the backend
///
/// This interceptor:
/// 1. Catches 401 Unauthorized responses
/// 2. Requests a fresh token from Firebase via TokenProvider
/// 3. Retries the failed request with the new token
/// 4. Signals logout if token refresh fails
///
/// Design decisions:
/// - Uses [Completer] as a mutex to prevent concurrent token fetches
/// - Marks retried requests to prevent infinite loops
/// - Calls [TokenProvider.onTokenRefreshFailed] on hard failure
class RefreshTokenInterceptor extends Interceptor {
  final TokenProvider _tokenProvider;

  /// Separate Dio instance for retry calls.
  /// This prevents the retry from going through refresh interceptor again.
  final Dio _retryDio;

  /// Completer acts as a mutex - if not null, a token fetch is in progress.
  Completer<bool>? _refreshCompleter;

  /// Key used to mark requests that have already been retried.
  static const String _retryKey = '_refreshRetried';

  RefreshTokenInterceptor({
    required TokenProvider tokenProvider,
    required Dio refreshDio,
  })  : _tokenProvider = tokenProvider,
        _retryDio = refreshDio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only handle 401 Unauthorized errors
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Skip refresh for requests that opted out of auth (e.g., login, register)
    // A 401 on these endpoints means invalid credentials, not expired token
    if (err.requestOptions.extra['skipAuth'] == true) {
      return handler.next(err);
    }

    // If already retried, don't retry again (prevents infinite loop)
    if (err.requestOptions.extra[_retryKey] == true) {
      _tokenProvider.onTokenRefreshFailed();
      return handler.next(err);
    }

    try {
      // Wait for any in-progress token fetch or start a new one
      final refreshSuccess = await _ensureTokenRefreshed();

      if (refreshSuccess) {
        // Retry the original request with new token
        final response = await _retryRequest(err.requestOptions);
        return handler.resolve(response);
      } else {
        // Token fetch failed, trigger logout
        _tokenProvider.onTokenRefreshFailed();
        return handler.next(err);
      }
    } catch (e) {
      // Unexpected error during refresh
      _tokenProvider.onTokenRefreshFailed();
      return handler.next(err);
    }
  }

  /// Ensures a fresh token is available, handling concurrent requests.
  ///
  /// For Firebase: This calls getIdToken() which automatically refreshes
  /// if the token is expired. Firebase SDK handles the actual refresh.
  ///
  /// Returns true if a valid token is available, false otherwise.
  Future<bool> _ensureTokenRefreshed() async {
    // If a refresh is in progress, wait for it
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    // Start a new token fetch
    _refreshCompleter = Completer<bool>();

    try {
      final success = await _performTokenRefresh();
      _refreshCompleter!.complete(success);
      return success;
    } catch (e) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      // Reset the completer for future refreshes
      _refreshCompleter = null;
    }
  }

  /// Attempts to get a fresh token from Firebase via TokenProvider.
  ///
  /// For Firebase Auth:
  /// - TokenProvider.getAccessToken() should call user.getIdToken(true)
  /// - This forces Firebase to return a fresh token if current one is expired
  /// - Firebase SDK handles the actual refresh with Google servers
  Future<bool> _performTokenRefresh() async {
    // Request a fresh token from Firebase via TokenProvider
    final newToken = await _tokenProvider.getAccessToken();

    // If we got a token, refresh was successful
    if (newToken != null && newToken.isNotEmpty) {
      return true;
    }

    // No token available - user is not logged in
    return false;
  }

  /// Retries the original request with a fresh token.
  Future<Response<dynamic>> _retryRequest(RequestOptions options) async {
    // Mark as retried to prevent infinite loop
    options.extra[_retryKey] = true;

    // Get the fresh access token
    final newToken = await _tokenProvider.getAccessToken();
    if (newToken != null) {
      options.headers['Authorization'] = 'Bearer $newToken';
    }

    // Retry with the retry Dio instance
    return _retryDio.fetch(options);
  }
}
