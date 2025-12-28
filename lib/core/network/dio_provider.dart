import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'config/api_config.dart';
import 'config/environment.dart';
import 'my_dio.dart';
import 'token/firebase_token_provider.dart';

part 'dio_provider.g.dart';

/// Provides a configured Dio instance for making HTTP requests.
///
/// This provider:
/// - Creates a single Dio instance that is shared across the app
/// - Uses the Firebase token provider for authentication
/// - Is configured for the current environment (dev/staging/prod)
///
/// Usage:
/// ```dart
/// final dio = ref.watch(dioProvider);
/// final response = await dio.get('/api/users');
/// ```
@riverpod
Dio dio(Ref ref) {
  // Get the token provider
  final tokenProvider = ref.read(firebaseTokenProviderProvider.notifier);

  // Create the API config with the current environment
  // TODO: Make environment configurable via a provider
  const config = ApiConfig(environment: StagingEnvironment());

  // Create and return the configured Dio instance
  return MyDio(
    config: config,
    tokenProvider: tokenProvider,
  );
}
