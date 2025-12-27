import 'package:dio/dio.dart';

/// Registry for managing request cancellation tokens.
///
/// Provides centralized cancellation management with support for:
/// - Cancel by screen (e.g., when navigating away)
/// - Cancel by feature (e.g., cancel search when starting new search)
/// - Cancel all (e.g., on logout)
///
/// Design decisions:
/// - Tag-based system for flexible cancellation granularity
/// - Automatic cleanup of completed/cancelled tokens
/// - Thread-safe operations using Dart's single-threaded event loop
///
/// Usage:
/// ```dart
/// // Create a token for a request
/// final token = cancelRegistry.createToken('profile_screen');
/// await dio.get('/profile', cancelToken: token);
///
/// // Cancel all requests for a screen when navigating away
/// cancelRegistry.cancelByTag('profile_screen');
///
/// // Cancel all requests on logout
/// cancelRegistry.cancelAll();
/// ```
class CancelRegistry {
  /// Map of tag -> list of active cancel tokens.
  final Map<String, List<CancelToken>> _tokens = {};

  /// Creates a new [CancelToken] associated with the given [tag].
  ///
  /// The tag is used to group related requests. Common patterns:
  /// - Screen-based: `'profile_screen'`, `'home_screen'`
  /// - Feature-based: `'search'`, `'upload'`
  /// - Operation-based: `'fetch_user_123'`
  CancelToken createToken(String tag) {
    final token = CancelToken();
    _tokens.putIfAbsent(tag, () => []).add(token);
    return token;
  }

  /// Cancels all requests associated with the given [tag].
  ///
  /// This is typically called when:
  /// - User navigates away from a screen
  /// - User starts a new operation that replaces the previous one
  /// - A feature is being reset
  void cancelByTag(String tag, {String reason = 'Cancelled by tag'}) {
    final tokens = _tokens[tag];
    if (tokens == null) return;

    for (final token in tokens) {
      if (!token.isCancelled) {
        token.cancel(reason);
      }
    }

    // Remove the tag's tokens after cancellation
    _tokens.remove(tag);
  }

  /// Cancels all active requests across all tags.
  ///
  /// This is typically called on logout to ensure no stale requests
  /// continue with old authentication tokens.
  void cancelAll({String reason = 'All requests cancelled'}) {
    for (final entry in _tokens.entries) {
      for (final token in entry.value) {
        if (!token.isCancelled) {
          token.cancel(reason);
        }
      }
    }
    _tokens.clear();
  }

  /// Removes completed or cancelled tokens from the registry.
  ///
  /// Call this periodically to prevent memory leaks in long-running sessions.
  /// Typically called:
  /// - On app backgrounding
  /// - After a batch of requests completes
  /// - On a timer (e.g., every 5 minutes)
  void cleanup() {
    _tokens.removeWhere((tag, tokens) {
      tokens.removeWhere((token) => token.isCancelled);
      return tokens.isEmpty;
    });
  }

  /// Checks if there are any active tokens for the given [tag].
  bool hasActiveTokens(String tag) {
    final tokens = _tokens[tag];
    if (tokens == null) return false;
    return tokens.any((token) => !token.isCancelled);
  }

  /// Gets the count of active tokens for the given [tag].
  int activeTokenCount(String tag) {
    final tokens = _tokens[tag];
    if (tokens == null) return 0;
    return tokens.where((token) => !token.isCancelled).length;
  }

  /// Gets all active tags.
  List<String> get activeTags => _tokens.keys.toList();

  /// Total count of all active tokens across all tags.
  int get totalActiveTokens {
    int count = 0;
    for (final tokens in _tokens.values) {
      count += tokens.where((token) => !token.isCancelled).length;
    }
    return count;
  }

  /// Disposes of all tokens and clears the registry.
  ///
  /// Call this when the registry is no longer needed (e.g., on app shutdown).
  void dispose() {
    cancelAll(reason: 'Registry disposed');
  }
}
