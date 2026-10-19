import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
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

  // Automatically use ProdEnvironment in release builds (disables verbose HTTP logging)
  const config = ApiConfig(
    environment: kReleaseMode ? ProdEnvironment() : StagingEnvironment(),
  );

  // Create and return the configured Dio instance
  return MyDio(
    config: config,
    tokenProvider: tokenProvider,
  );
}
