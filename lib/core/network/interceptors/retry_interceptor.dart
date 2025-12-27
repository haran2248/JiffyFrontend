import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

/// Interceptor that retries failed requests with exponential backoff.
///
/// This interceptor handles transient failures like:
/// - Network timeouts
/// - Connection errors
/// - Server errors (502, 503)
///
/// It does NOT retry:
/// - Client errors (400, 401, 403, 404)
/// - Cancelled requests
/// - Requests that have exceeded max retries
///
/// Design decisions:
/// - Exponential backoff with jitter to prevent thundering herd
/// - Retry count stored in request extras
/// - Respects cancellation before each retry
/// - Only retries idempotent operations by default
class RetryInterceptor extends Interceptor {
  /// Maximum number of retry attempts.
  final int maxRetries;

  /// Initial delay before first retry.
  final Duration initialDelay;

  /// Maximum delay between retries (cap for exponential backoff).
  final Duration maxDelay;

  /// Dio instance for retrying requests.
  /// Should have all interceptors EXCEPT RetryInterceptor to avoid loops.
  final Dio _retryDio;

  /// Random instance for jitter calculation.
  final Random _random = Random();

  /// Key used to track retry count in request extras.
  static const String _retryCountKey = '_retryCount';

  /// HTTP status codes that should be retried.
  static const List<int> _retryableStatusCodes = [502, 503, 504];

  RetryInterceptor({
    required Dio retryDio,
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 10),
  }) : _retryDio = retryDio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;

    // Don't retry if explicitly disabled
    if (options.extra['disableRetry'] == true) {
      return handler.next(err);
    }

    // Only retry idempotent methods by default (prevents duplicate side effects)
    // POST and PATCH can be explicitly enabled via 'forceRetry' extra
    if (!_isIdempotentMethod(options.method) &&
        options.extra['forceRetry'] != true) {
      return handler.next(err);
    }

    // Don't retry if not a retryable error
    if (!_isRetryable(err)) {
      return handler.next(err);
    }

    // Get current retry count
    final currentRetry = (options.extra[_retryCountKey] as int?) ?? 0;

    // Check if we've exceeded max retries
    if (currentRetry >= maxRetries) {
      return handler.next(err);
    }

    // Check if request was cancelled
    if (options.cancelToken?.isCancelled ?? false) {
      return handler.next(err);
    }

    // Calculate delay with exponential backoff and jitter
    final delay = _calculateDelay(currentRetry);

    // Wait before retrying
    await Future.delayed(delay);

    // Check again if cancelled during the delay
    if (options.cancelToken?.isCancelled ?? false) {
      return handler.next(err);
    }

    // Increment retry count and retry
    options.extra[_retryCountKey] = currentRetry + 1;

    try {
      // Use injected Dio that has auth/error interceptors but no retry interceptor
      final response = await _retryDio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      // Re-enter retry logic to evaluate if we should retry again
      // The updated retry count in options.extra will be checked
      return onError(e, handler);
    }
  }

  /// Determines if an error is retryable.
  ///
  /// Only retries transient errors that might succeed on retry.
  bool _isRetryable(DioException err) {
    switch (err.type) {
      // Retryable Dio error types
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;

      // Never retry cancelled requests
      case DioExceptionType.cancel:
        return false;

      // Check status code for bad response
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode == null) return false;
        return _retryableStatusCodes.contains(statusCode);

      // Don't retry certificate errors
      case DioExceptionType.badCertificate:
        return false;

      // For unknown errors, check if it's a network-related issue
      case DioExceptionType.unknown:
        // SocketException indicates a network issue
        final error = err.error;
        if (error != null && error.toString().contains('SocketException')) {
          return true;
        }
        return false;
    }
  }

  /// Calculates the delay for a given retry attempt using exponential backoff.
  ///
  /// Formula: min(initialDelay * 2^retryCount + jitter, maxDelay)
  /// Jitter is ±25% of the calculated delay to prevent thundering herd.
  Duration _calculateDelay(int retryCount) {
    // Calculate base delay with exponential backoff
    final exponentialDelay = initialDelay * pow(2, retryCount);

    // Apply jitter (±25%)
    final jitterFactor = 0.75 + (_random.nextDouble() * 0.5); // 0.75 to 1.25
    final delayWithJitter = exponentialDelay * jitterFactor;

    // Cap at max delay
    final cappedDelay = delayWithJitter.inMilliseconds > maxDelay.inMilliseconds
        ? maxDelay
        : Duration(milliseconds: delayWithJitter.inMilliseconds.toInt());

    return cappedDelay;
  }

  /// Checks if the HTTP method is idempotent (safe to retry).
  ///
  /// Idempotent methods can be retried without causing duplicate side effects.
  /// POST and PATCH are excluded as they may create duplicate resources.
  bool _isIdempotentMethod(String method) {
    const idempotentMethods = ['GET', 'HEAD', 'OPTIONS', 'PUT', 'DELETE'];
    return idempotentMethods.contains(method.toUpperCase());
  }
}
