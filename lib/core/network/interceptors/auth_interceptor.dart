import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../token/token_provider.dart';

/// Interceptor that injects authentication tokens into requests.
///
/// This interceptor runs early in the chain to ensure all requests
/// that require authentication have the proper Authorization header.
///
/// Design decisions:
/// - Token source is abstracted via [TokenProvider] interface
/// - Public paths (login, register, etc.) are skipped
/// - Uses Bearer token format (RFC 6750)
/// - Does NOT handle token refresh - that's [RefreshTokenInterceptor]'s job
///
/// Request flow:
/// 1. Check if path requires authentication
/// 2. If yes, get token from [TokenProvider]
/// 3. If token exists, add Authorization header
/// 4. Pass request to next interceptor
class AuthInterceptor extends Interceptor {
  final TokenProvider _tokenProvider;

  AuthInterceptor({required TokenProvider tokenProvider})
      : _tokenProvider = tokenProvider;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip authentication for public endpoints
    if (_shouldSkipAuth(options)) {
      return handler.next(options);
    }

    try {
      // Get the access token
      final accessToken = await _tokenProvider.getAccessToken();

      // If we have a token, add it to the request
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }

      handler.next(options);
    } catch (e) {
      // Ensure handler is always called to prevent request from hanging
      handler.reject(
        DioException(
          requestOptions: options,
          error: e,
          message: 'Failed to retrieve access token',
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  /// Determines if a request should skip authentication.
  ///
  /// Returns true for public paths like login, register, etc.
  bool _shouldSkipAuth(RequestOptions options) {
    // Check if the request explicitly opts out of auth
    if (options.extra['skipAuth'] == true) {
      return true;
    }

    // Check against the list of public paths
    return ApiConfig.isPublicPath(options.path);
  }
}
