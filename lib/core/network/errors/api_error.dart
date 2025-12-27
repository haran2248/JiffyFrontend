import 'package:dio/dio.dart';

/// Classification of API errors for exhaustive handling.
///
/// Using an enum allows consumers to use switch statements with
/// compile-time exhaustiveness checking, ensuring all error types
/// are handled appropriately.
enum ApiErrorType {
  /// No internet connection, DNS failure, or network unreachable.
  network,

  /// Connection timeout, send timeout, or receive timeout.
  timeout,

  /// Request was cancelled via CancelToken.
  cancelled,

  /// HTTP 401 - Authentication required or token expired.
  unauthorized,

  /// HTTP 403 - Permission denied.
  forbidden,

  /// HTTP 400 - Bad request, validation error.
  badRequest,

  /// HTTP 404 - Resource not found.
  notFound,

  /// HTTP 5xx - Server error.
  server,

  /// Any other unexpected error.
  unknown,
}

/// Unified error model for the networking layer.
///
/// This is the ONLY error type that should escape the networking layer.
/// All Dio exceptions are converted to [ApiError] before being returned
/// to repositories and UI layers.
///
/// Design decisions:
/// - Does NOT extend DioException to fully abstract Dio internals
/// - Stores original error for debugging purposes only
/// - Provides factory constructors for common error patterns
/// - Implements Exception for standard error handling
class ApiError implements Exception {
  /// HTTP status code if available, null for network/timeout errors.
  final int? statusCode;

  /// Human-readable error message.
  final String message;

  /// Classification of the error for exhaustive handling.
  final ApiErrorType type;

  /// Original error for debugging. Should not be used in production logic.
  final dynamic originalError;

  /// Request path that caused the error, useful for debugging.
  final String? requestPath;

  const ApiError({
    this.statusCode,
    required this.message,
    required this.type,
    this.originalError,
    this.requestPath,
  });

  /// Creates an [ApiError] from a [DioException].
  ///
  /// This factory is the primary way errors are created in the networking layer.
  /// It maps Dio error types and HTTP status codes to [ApiErrorType].
  factory ApiError.fromDioException(DioException exception) {
    final response = exception.response;
    final statusCode = response?.statusCode;
    final requestPath = exception.requestOptions.path;

    // Try to extract error message from response body
    final message = _extractErrorMessage(exception);

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError(
          message: 'Request timed out. Please try again.',
          type: ApiErrorType.timeout,
          originalError: exception,
          requestPath: requestPath,
        );

      case DioExceptionType.connectionError:
        return ApiError(
          message: 'Unable to connect. Please check your internet connection.',
          type: ApiErrorType.network,
          originalError: exception,
          requestPath: requestPath,
        );

      case DioExceptionType.cancel:
        return ApiError(
          message: 'Request was cancelled.',
          type: ApiErrorType.cancelled,
          originalError: exception,
          requestPath: requestPath,
        );

      case DioExceptionType.badResponse:
        return ApiError._fromStatusCode(
          statusCode: statusCode,
          message: message,
          originalError: exception,
          requestPath: requestPath,
        );

      case DioExceptionType.badCertificate:
        return ApiError(
          message: 'Security certificate error.',
          type: ApiErrorType.network,
          originalError: exception,
          requestPath: requestPath,
        );

      case DioExceptionType.unknown:
        // Check if it's a SocketException (network error)
        if (exception.error != null &&
            exception.error.toString().contains('SocketException')) {
          return ApiError(
            message:
                'Unable to connect. Please check your internet connection.',
            type: ApiErrorType.network,
            originalError: exception,
            requestPath: requestPath,
          );
        }
        return ApiError(
          message: message,
          type: ApiErrorType.unknown,
          originalError: exception,
          requestPath: requestPath,
        );
    }
  }

  /// Creates an [ApiError] from an HTTP status code.
  factory ApiError._fromStatusCode({
    required int? statusCode,
    required String message,
    required dynamic originalError,
    required String? requestPath,
  }) {
    final ApiErrorType type;
    if (statusCode == null) {
      type = ApiErrorType.unknown;
    } else if (statusCode == 400) {
      type = ApiErrorType.badRequest;
    } else if (statusCode == 401) {
      type = ApiErrorType.unauthorized;
    } else if (statusCode == 403) {
      type = ApiErrorType.forbidden;
    } else if (statusCode == 404) {
      type = ApiErrorType.notFound;
    } else if (statusCode >= 500 && statusCode < 600) {
      type = ApiErrorType.server;
    } else {
      type = ApiErrorType.unknown;
    }

    return ApiError(
      statusCode: statusCode,
      message: message,
      type: type,
      originalError: originalError,
      requestPath: requestPath,
    );
  }

  /// Creates an unknown error from any exception.
  ///
  /// If [originalError] is already an [ApiError], it is returned as-is
  /// to preserve the original error type information.
  factory ApiError.unknown({
    required String message,
    dynamic originalError,
    String? requestPath,
  }) {
    // Preserve existing ApiError to avoid losing specific error types
    if (originalError is ApiError) {
      return originalError;
    }
    return ApiError(
      message: message,
      type: ApiErrorType.unknown,
      originalError: originalError,
      requestPath: requestPath,
    );
  }

  /// Creates a network error.
  factory ApiError.network({
    String message =
        'Unable to connect. Please check your internet connection.',
    dynamic originalError,
    String? requestPath,
  }) {
    return ApiError(
      message: message,
      type: ApiErrorType.network,
      originalError: originalError,
      requestPath: requestPath,
    );
  }

  /// Creates a timeout error.
  factory ApiError.timeout({
    String message = 'Request timed out. Please try again.',
    dynamic originalError,
    String? requestPath,
  }) {
    return ApiError(
      message: message,
      type: ApiErrorType.timeout,
      originalError: originalError,
      requestPath: requestPath,
    );
  }

  /// Attempts to extract a meaningful error message from a DioException.
  static String _extractErrorMessage(DioException exception) {
    // Try to get message from response body
    final data = exception.response?.data;
    if (data is Map) {
      // Common API error response formats
      final message = data['message'] ??
          data['error'] ??
          data['error_description'] ??
          data['detail'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    // Fallback to Dio's message
    if (exception.message != null && exception.message!.isNotEmpty) {
      return exception.message!;
    }

    // Generic fallback based on status code
    final statusCode = exception.response?.statusCode;
    if (statusCode == null) {
      return 'An unexpected error occurred.';
    } else if (statusCode == 400) {
      return 'Invalid request. Please check your input.';
    } else if (statusCode == 401) {
      return 'Authentication required. Please log in.';
    } else if (statusCode == 403) {
      return 'You do not have permission to perform this action.';
    } else if (statusCode == 404) {
      return 'The requested resource was not found.';
    } else if (statusCode >= 500 && statusCode < 600) {
      return 'Server error. Please try again later.';
    } else {
      return 'An unexpected error occurred.';
    }
  }

  /// Whether this error is due to authentication issues.
  bool get isAuthError =>
      type == ApiErrorType.unauthorized || type == ApiErrorType.forbidden;

  /// Whether this error might be resolved by retrying.
  bool get isRetryable =>
      type == ApiErrorType.network ||
      type == ApiErrorType.timeout ||
      type == ApiErrorType.server;

  @override
  String toString() {
    final buffer = StringBuffer('ApiError(');
    buffer.write('type: $type');
    if (statusCode != null) {
      buffer.write(', statusCode: $statusCode');
    }
    buffer.write(', message: $message');
    if (requestPath != null) {
      buffer.write(', path: $requestPath');
    }
    buffer.write(')');
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiError &&
        other.statusCode == statusCode &&
        other.message == message &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(statusCode, message, type);
}
