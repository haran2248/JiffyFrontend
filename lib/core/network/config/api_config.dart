import 'package:dio/dio.dart';

import 'environment.dart';

/// Centralized API configuration for the networking layer.
///
/// This class is the single point of truth for all HTTP configuration.
/// It takes an [Environment] and produces [BaseOptions] for Dio.
///
/// Configured for SwishBackend API structure:
/// - `/auth/*` - Authentication endpoints (Firebase token verification)
/// - `/api/users/*` - User operations
/// - `/api/v1/match/*` - Match operations
/// - `/api/onboarding/*` - Onboarding operations
/// - `/health` - Health check
class ApiConfig {
  /// The current environment configuration.
  final Environment environment;

  const ApiConfig({required this.environment});

  /// Creates [BaseOptions] for Dio based on the current environment.
  BaseOptions get baseOptions => BaseOptions(
        baseUrl: environment.baseUrl,
        connectTimeout: environment.connectTimeout,
        receiveTimeout: environment.receiveTimeout,
        sendTimeout: environment.sendTimeout,
        headers: defaultHeaders,
        // Always expect JSON responses
        responseType: ResponseType.json,
        // Validate status codes - return true to NOT throw for these codes
        // We want Dio to throw for all non-2xx so our interceptors can handle them
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      );

  /// Default headers applied to all requests.
  ///
  /// The Authorization header is added by [AuthInterceptor], not here.
  /// This keeps authentication logic centralized in one place.
  Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // TODO: Define API paths here as the backend API evolves
  // Example:
  // static const String usersPath = '/api/users';
  // static const String matchPath = '/api/v1/match';

  /// Paths that should NOT have authentication headers.
  /// These are typically public endpoints.
  static const List<String> publicPaths = [
    '/health',
    '/login',
    '/auth/verifyToken',
  ];

  /// Checks if a path should skip authentication.
  static bool isPublicPath(String path) {
    return publicPaths.any((publicPath) => path.startsWith(publicPath));
  }
}
