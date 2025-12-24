import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'config/api_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/refresh_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'token/token_provider.dart';

/// Production-grade HTTP client using DioMixin.
///
/// This is the main entry point for all HTTP operations in the application.
/// It uses [DioMixin] instead of [Dio()] directly for:
/// - Full control over initialization
/// - Explicit dependency injection
/// - No hidden behavior from factory constructors
/// - Cleaner testability
///
/// Interceptor Order (IMPORTANT):
/// 1. LoggingInterceptor - Logs raw request (first, before any modification)
/// 2. AuthInterceptor - Adds authentication token
/// 3. RetryInterceptor - Handles transient failures with retry
/// 4. RefreshTokenInterceptor - Handles 401 with token refresh
/// 5. ErrorInterceptor - Normalizes all errors to ApiError (LAST)
///
/// Why this order?
/// - Logging first sees the original request
/// - Auth adds token before any request goes out
/// - Retry handles network issues before checking auth
/// - Refresh only runs if retry didn't fix 401
/// - Error interceptor catches everything at the end
///
/// Usage:
/// ```dart
/// final dio = MyDio(
///   config: ApiConfig(environment: Environment.dev()),
///   tokenProvider: myTokenProvider,
/// );
/// ```
class MyDio with DioMixin implements Dio {
  final ApiConfig _config;
  final TokenProvider _tokenProvider;

  // These field overrides are required by the DioMixin pattern.
  // ignore: overridden_fields
  @override
  late final HttpClientAdapter httpClientAdapter;

  // ignore: overridden_fields
  @override
  late final BaseOptions options;

  // ignore: overridden_fields
  @override
  late Transformer transformer;

  @override
  final Interceptors interceptors = Interceptors();

  MyDio({
    required ApiConfig config,
    required TokenProvider tokenProvider,
  })  : _config = config,
        _tokenProvider = tokenProvider {
    // Configure base options from config
    options = _config.baseOptions;

    // Configure transformer
    transformer = BackgroundTransformer();

    // Configure HTTP adapter (different for web vs mobile)
    httpClientAdapter = _createAdapter();

    // Setup interceptors in the correct order
    _setupInterceptors();
  }

  /// Creates the appropriate HTTP adapter for the current platform.
  ///
  /// Uses IOHttpClientAdapter for mobile/desktop platforms.
  /// For web, Dio automatically uses the appropriate adapter.
  HttpClientAdapter _createAdapter() {
    // IOHttpClientAdapter works for mobile/desktop
    // On web, you may need to use a different adapter depending on Dio version
    // For Dio 5.x, it handles web automatically via dio_web_adapter package
    return IOHttpClientAdapter();
  }

  /// Sets up interceptors in the correct order.
  ///
  /// Order matters! Each interceptor has a specific responsibility
  /// and must run at the right point in the request/response cycle.
  void _setupInterceptors() {
    // Create a separate Dio instance for token refresh
    // This prevents infinite loops and interceptor conflicts
    final refreshDio = _createRefreshDio();

    interceptors.addAll([
      // 1. Logging - first to log raw request
      if (_config.environment.enableLogging) LoggingInterceptor(),

      // 2. Auth - add token to requests
      AuthInterceptor(tokenProvider: _tokenProvider),

      // 3. Retry - handle transient failures
      RetryInterceptor(),

      // 4. Refresh - handle 401 with token refresh
      RefreshTokenInterceptor(
        tokenProvider: _tokenProvider,
        refreshDio: refreshDio,
      ),

      // 5. Error - normalize all errors (LAST)
      ErrorInterceptor(),
    ]);
  }

  /// Creates a separate Dio instance for token refresh requests.
  ///
  /// This instance:
  /// - Uses the same base URL
  /// - Has logging but no auth/retry/refresh interceptors
  /// - Prevents circular dependencies in token refresh
  Dio _createRefreshDio() {
    final refreshDio = Dio(BaseOptions(
      baseUrl: _config.environment.baseUrl,
      connectTimeout: _config.environment.connectTimeout,
      receiveTimeout: _config.environment.receiveTimeout,
      headers: _config.defaultHeaders,
    ));

    // Only add logging to refresh dio (no auth, retry, or refresh interceptors)
    if (_config.environment.enableLogging) {
      refreshDio.interceptors.add(LoggingInterceptor());
    }

    return refreshDio;
  }
}
