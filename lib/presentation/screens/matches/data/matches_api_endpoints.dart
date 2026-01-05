/// API endpoint definitions for the matches feature.
///
/// This file serves as the single source of truth for all API endpoints
/// used by the matches feature. All endpoints should be defined here as
/// constants to ensure consistency and maintainability.
///
/// Usage:
/// ```dart
/// final response = await _dio.get(MatchesApiEndpoints.myMatches);
/// ```
class MatchesApiEndpoints {
  // Private constructor to prevent instantiation
  MatchesApiEndpoints._();

  /// Base path for match-related endpoints
  static const String basePath = '/api/v1/match';

  /// Get user's matches
  /// GET /api/v1/match/myMatches?uid={uid}
  static const String myMatches = '$basePath/myMatches';

  /// Find a match for the user
  /// POST /api/v1/match/findMatch?uid={uid}&latitude={lat}&longitude={lng}
  static const String findMatch = '$basePath/findMatch';

  /// Add a match
  /// POST /api/v1/match/addMatch?uid={uid}&matchUid={matchUid}&eventName={eventName}
  static const String addMatch = '$basePath/addMatch';
}

