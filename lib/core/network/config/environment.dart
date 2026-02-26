/// Environment configuration for the networking layer.
///
/// Using a sealed class provides:
/// - Compile-time exhaustiveness when switching on environment type
/// - Clear separation between environment-specific values
/// - Immutability - environment doesn't change at runtime
///
/// Usage:
/// ```dart
/// final environment = Environment.dev();
/// debugPrint(environment.baseUrl); // https://dev-api.jiffy.ai
/// ```
sealed class Environment {
  /// The base URL for API requests.
  String get baseUrl;

  /// Human-readable name for logging.
  String get name;

  /// Timeout for establishing a connection.
  Duration get connectTimeout;

  /// Timeout for receiving data from the server.
  Duration get receiveTimeout;

  /// Timeout for sending data to the server.
  Duration get sendTimeout;

  /// Whether debug logging is enabled.
  bool get enableLogging;

  const Environment();

  /// Creates a development environment.
  factory Environment.dev() = DevEnvironment;

  /// Creates a staging environment.
  factory Environment.staging() = StagingEnvironment;

  /// Creates a production environment.
  factory Environment.prod() = ProdEnvironment;

  /// Creates an environment from a string name.
  /// Useful for configuration from environment variables.
  factory Environment.fromString(String name) {
    return switch (name.toLowerCase()) {
      'dev' || 'development' => Environment.dev(),
      'staging' || 'stage' => Environment.staging(),
      'prod' || 'production' => Environment.prod(),
      _ => throw ArgumentError('Unknown environment: $name'),
    };
  }
}

/// Development environment with verbose logging and longer timeouts.
final class DevEnvironment extends Environment {
  const DevEnvironment();

  @override
  String get baseUrl =>
      'https://limitless-sea-53782-2c45e56f3e92.herokuapp.com';

  @override
  String get name => 'development';

  @override
  Duration get connectTimeout => const Duration(seconds: 30);

  @override
  Duration get receiveTimeout => const Duration(seconds: 30);

  @override
  Duration get sendTimeout => const Duration(seconds: 30);

  @override
  bool get enableLogging => true;
}

/// Staging environment for QA testing.
final class StagingEnvironment extends Environment {
  const StagingEnvironment();

  @override
  String get baseUrl =>
      'https://limitless-sea-53782-2c45e56f3e92.herokuapp.com';

  @override
  String get name => 'staging';

  @override
  Duration get connectTimeout => const Duration(seconds: 20);

  @override
  Duration get receiveTimeout => const Duration(seconds: 20);

  @override
  Duration get sendTimeout => const Duration(seconds: 20);

  @override
  bool get enableLogging => true;
}

/// Production environment with optimized timeouts and no debug logging.
final class ProdEnvironment extends Environment {
  const ProdEnvironment();

  @override
  String get baseUrl =>
      'https://limitless-sea-53782-2c45e56f3e92.herokuapp.com';

  @override
  String get name => 'production';

  @override
  Duration get connectTimeout => const Duration(seconds: 15);

  @override
  Duration get receiveTimeout => const Duration(seconds: 15);

  @override
  Duration get sendTimeout => const Duration(seconds: 15);

  /// Disabled in production for performance and security.
  @override
  bool get enableLogging => false;
}
