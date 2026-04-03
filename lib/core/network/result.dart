/// A generic Result type for type-safe error handling.
sealed class Result<T, E> {
  const Result();

  factory Result.success(T data) = Success<T, E>;
  factory Result.failure(E error) = Failure<T, E>;

  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;

  T? get dataOrNull => switch (this) {
        Success(:final data) => data,
        Failure() => null,
      };

  E? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final error) => error,
      };

  Result<U, E> map<U>(U Function(T data) transform) {
    return switch (this) {
      Success(:final data) => Result.success(transform(data)),
      Failure(:final error) => Result.failure(error),
    };
  }

  Result<T, F> mapError<F>(F Function(E error) transform) {
    return switch (this) {
      Success(:final data) => Result.success(data),
      Failure(:final error) => Result.failure(transform(error)),
    };
  }
}

final class Success<T, E> extends Result<T, E> {
  final T data;
  const Success(this.data);
}

final class Failure<T, E> extends Result<T, E> {
  final E error;
  const Failure(this.error);
}
