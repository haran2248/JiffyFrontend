import 'package:dio/dio.dart';

import '../errors/api_error.dart';

/// Interceptor that normalizes all errors into [ApiError].
///
/// This is the LAST interceptor in the chain. Its job is to ensure
/// that no [DioException] escapes the networking layer without being
/// converted to an [ApiError].
///
/// Design decisions:
/// - Runs last to catch ALL errors, including those from other interceptors
/// - Converts [DioException] to [ApiError] using factory method
/// - Preserves original error for debugging
/// - Uses [handler.reject] to continue error flow with normalized error
///
/// After this interceptor:
/// - Repositories receive [DioException] with [error] field containing [ApiError]
/// - Repositories extract [ApiError] and return it to UI layers
/// - UI layers NEVER see [DioException] types
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // If error is already an ApiError, just pass it through
    if (err.error is ApiError) {
      return handler.next(err);
    }

    // Convert DioException to ApiError
    final apiError = ApiError.fromDioException(err);

    // Create a new DioException with ApiError as the error field
    // This pattern allows us to use Dio's error handling while
    // ensuring our custom error type is available
    final normalizedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: apiError,
      message: apiError.message,
    );

    handler.next(normalizedError);
  }
}
