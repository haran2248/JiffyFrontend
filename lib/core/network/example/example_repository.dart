import 'package:dio/dio.dart';

import '../cancel/cancel_registry.dart';
import '../errors/api_error.dart';

/// Example repository demonstrating how to use the networking layer.
///
/// This file shows the recommended pattern for creating repositories
/// that use [MyDio] for HTTP operations. It demonstrates:
/// - Proper error handling with [ApiError]
/// - Using [CancelRegistry] for request cancellation
/// - Never exposing [DioException] to UI layers
/// - Using [Result] pattern for type-safe error handling
///
/// THIS FILE IS AN EXAMPLE - it can be used as a template or deleted.
/// The actual implementation should be in feature-specific repositories.

// ============================================================================
// RESULT PATTERN
// ============================================================================

/// A simple Result type for type-safe error handling.
///
/// This pattern forces callers to handle both success and failure cases,
/// making error handling explicit and reducing forgotten error handling.
///
/// Usage:
/// ```dart
/// final result = await repository.getUserProfile('123');
/// switch (result) {
///   case Success(:final data):
///     // Handle success with data
///     break;
///   case Failure(:final error):
///     // Handle error
///     break;
/// }
/// ```
sealed class Result<T, E> {
  const Result();

  /// Creates a successful result.
  factory Result.success(T data) = Success<T, E>;

  /// Creates a failed result.
  factory Result.failure(E error) = Failure<T, E>;

  /// Returns true if this is a successful result.
  bool get isSuccess => this is Success<T, E>;

  /// Returns true if this is a failed result.
  bool get isFailure => this is Failure<T, E>;

  /// Gets the data if successful, otherwise returns null.
  T? get dataOrNull => switch (this) {
        Success(:final data) => data,
        Failure() => null,
      };

  /// Gets the error if failed, otherwise returns null.
  E? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final error) => error,
      };

  /// Maps the success data to a new type.
  Result<U, E> map<U>(U Function(T data) transform) {
    return switch (this) {
      Success(:final data) => Result.success(transform(data)),
      Failure(:final error) => Result.failure(error),
    };
  }

  /// Maps the error to a new type.
  Result<T, F> mapError<F>(F Function(E error) transform) {
    return switch (this) {
      Success(:final data) => Result.success(data),
      Failure(:final error) => Result.failure(transform(error)),
    };
  }
}

/// Represents a successful result with data.
final class Success<T, E> extends Result<T, E> {
  final T data;

  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Success<T, E> && other.data == data;

  @override
  int get hashCode => data.hashCode;
}

/// Represents a failed result with an error.
final class Failure<T, E> extends Result<T, E> {
  final E error;

  const Failure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Failure<T, E> && other.error == error;

  @override
  int get hashCode => error.hashCode;
}

// ============================================================================
// EXAMPLE MODELS
// ============================================================================

/// Example user profile model.
///
/// In a real app, this would be in a separate models folder.
class UserProfile {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

// ============================================================================
// EXAMPLE REPOSITORY
// ============================================================================

/// Example repository showing how to use the networking layer.
///
/// Key patterns demonstrated:
/// 1. Inject [Dio] (not [MyDio]) - for testability
/// 2. Inject [CancelRegistry] - for request cancellation
/// 3. Return [Result<T, ApiError>] - for type-safe error handling
/// 4. Extract [ApiError] from [DioException] - per networking layer contract
class ExampleRepository {
  final Dio _dio;
  final CancelRegistry _cancelRegistry;

  /// Screen/feature tag for cancellation.
  /// This allows cancelling all requests when leaving a screen.
  static const String _tag = 'example';

  ExampleRepository({
    required Dio dio,
    required CancelRegistry cancelRegistry,
  })  : _dio = dio,
        _cancelRegistry = cancelRegistry;

  /// Fetches a user profile by ID.
  ///
  /// Returns [Result.success] with [UserProfile] on success.
  /// Returns [Result.failure] with [ApiError] on any failure.
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getUserProfile('123');
  /// switch (result) {
  ///   case Success(:final data):
  ///     setState(() => _profile = data);
  ///   case Failure(:final error):
  ///     _showError(error.message);
  /// }
  /// ```
  Future<Result<UserProfile, ApiError>> getUserProfile(String userId) async {
    try {
      final response = await _dio.get(
        '/users/$userId',
        cancelToken: _cancelRegistry.createToken(_tag),
      );

      final profile = UserProfile.fromJson(response.data as Map<String, dynamic>);
      return Result.success(profile);
    } catch (e) {
      return Result.failure(_extractError(e));
    }
  }

  /// Updates a user profile.
  ///
  /// Example showing POST request with body.
  Future<Result<UserProfile, ApiError>> updateProfile({
    required String userId,
    required String name,
    String? avatarUrl,
  }) async {
    try {
      final response = await _dio.put(
        '/users/$userId',
        data: {
          'name': name,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        },
        cancelToken: _cancelRegistry.createToken(_tag),
      );

      final profile = UserProfile.fromJson(response.data as Map<String, dynamic>);
      return Result.success(profile);
    } catch (e) {
      return Result.failure(_extractError(e));
    }
  }

  /// Deletes a user profile.
  ///
  /// Example showing DELETE request that returns void.
  Future<Result<void, ApiError>> deleteProfile(String userId) async {
    try {
      await _dio.delete(
        '/users/$userId',
        cancelToken: _cancelRegistry.createToken(_tag),
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(_extractError(e));
    }
  }

  /// Cancels all pending requests for this repository.
  ///
  /// Call this when leaving a screen or resetting state.
  void cancelPendingRequests() {
    _cancelRegistry.cancelByTag(_tag);
  }

  /// Extracts [ApiError] from any exception.
  ///
  /// The networking layer ensures [DioException.error] contains [ApiError],
  /// but we still handle edge cases gracefully.
  ApiError _extractError(Object error) {
    if (error is DioException && error.error is ApiError) {
      return error.error as ApiError;
    }

    // Fallback for unexpected errors
    return ApiError.unknown(
      message: error.toString(),
      originalError: error,
    );
  }
}

// ============================================================================
// RIVERPOD INTEGRATION EXAMPLE
// ============================================================================

/// Example showing how to integrate with Riverpod.
///
/// This is a conceptual example - actual implementation depends on your
/// Riverpod setup and preferences.
///
/// ```dart
/// // In providers.dart:
///
/// @riverpod
/// CancelRegistry cancelRegistry(CancelRegistryRef ref) {
///   final registry = CancelRegistry();
///   ref.onDispose(() => registry.dispose());
///   return registry;
/// }
///
/// @riverpod
/// Dio dio(DioRef ref) {
///   final tokenProvider = ref.watch(tokenProviderProvider);
///   final environment = ref.watch(environmentProvider);
///
///   return MyDio(
///     config: ApiConfig(environment: environment),
///     tokenProvider: tokenProvider,
///   );
/// }
///
/// @riverpod
/// ExampleRepository exampleRepository(ExampleRepositoryRef ref) {
///   return ExampleRepository(
///     dio: ref.watch(dioProvider),
///     cancelRegistry: ref.watch(cancelRegistryProvider),
///   );
/// }
///
/// // In a widget:
/// class ProfileScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     return FutureBuilder(
///       future: ref.watch(exampleRepositoryProvider).getUserProfile('123'),
///       builder: (context, snapshot) {
///         if (snapshot.connectionState == ConnectionState.waiting) {
///           return const LoadingIndicator();
///         }
///
///         final result = snapshot.data!;
///         return switch (result) {
///           Success(:final data) => ProfileView(profile: data),
///           Failure(:final error) => ErrorView(message: error.message),
///         };
///       },
///     );
///   }
/// }
/// ```
// See the doc comments above for Riverpod integration examples.
