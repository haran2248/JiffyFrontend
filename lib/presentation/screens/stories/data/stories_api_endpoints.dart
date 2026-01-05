/// API endpoint definitions for the stories feature.
///
/// This file serves as the single source of truth for all API endpoints
/// used by the stories feature. All endpoints should be defined here as
/// constants to ensure consistency and maintainability.
///
/// Usage:
/// ```dart
/// final response = await _dio.get(StoriesApiEndpoints.matches);
/// ```
class StoriesApiEndpoints {
  // Private constructor to prevent instantiation
  StoriesApiEndpoints._();

  /// Base path for story-related endpoints
  static const String basePath = '/api/v1/stories';

  /// Get stories for matched users
  /// GET /api/v1/stories/matches
  /// Requires: userId as query parameter
  static const String matches = '$basePath/matches';

  /// Get user's own stories
  /// GET /api/v1/stories/my-stories
  /// Requires: userId as query parameter
  static const String myStories = '$basePath/my-stories';

  /// Upload a story
  /// POST /api/v1/stories/upload
  /// Requires: userId, mediaType, file as form data
  static const String upload = '$basePath/upload';
}

