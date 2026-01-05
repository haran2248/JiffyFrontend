import 'package:jiffy/presentation/screens/stories/models/story_models.dart';

/// Helper functions for converting API responses to Story models
class StoryApiHelpers {
  /// Convert API response (Map) to Story model
  ///
  /// The backend returns Story objects with:
  /// - id: String
  /// - userId: String
  /// - mediaUrl: String (presigned URL)
  /// - mediaType: String ("IMAGE" or "VIDEO")
  /// - createdAt: Date (milliseconds since epoch or ISO string)
  /// - expiresAt: Date (milliseconds since epoch or ISO string)
  static Story storyFromApiJson(Map<String, dynamic> json) {
    // Parse dates - handle both milliseconds and ISO strings
    // Epoch timestamps are UTC-based, so use UTC when parsing
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is int) {
        // Epoch timestamps are UTC milliseconds since epoch
        return DateTime.fromMillisecondsSinceEpoch(dateValue, isUtc: true);
      }
      if (dateValue is String) {
        // ISO strings may include timezone info, tryParse handles it
        final parsed = DateTime.tryParse(dateValue);
        // If no timezone info, assume UTC
        if (parsed != null && !parsed.isUtc) {
          return parsed.toUtc();
        }
        return parsed;
      }
      return null;
    }

    final createdAt = parseDate(json['createdAt']) ?? DateTime.now();
    final expiresAt = parseDate(json['expiresAt']);

    // Create StoryContent from the API response
    final content = StoryContent(
      id: json['id'] ?? '',
      imageUrl: json['mediaUrl'] ?? '',
      overlays: const [], // Text overlays not yet supported in API
      createdAt: createdAt,
      isLocal: false,
    );

    return Story(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: null, // User name not in Story API response
      userImageUrl: null, // User avatar not in Story API response
      contents: [content],
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  /// Convert list of API responses to Story models
  static List<Story> storiesFromApiJson(List<dynamic> jsonList) {
    return jsonList
        .where((item) => item is Map<String, dynamic>)
        .map((item) => storyFromApiJson(item as Map<String, dynamic>))
        .toList();
  }
}

