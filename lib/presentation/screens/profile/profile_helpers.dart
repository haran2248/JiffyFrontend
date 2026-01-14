import "package:jiffy/presentation/screens/home/models/home_data.dart";
import "package:jiffy/presentation/screens/profile/models/profile_data.dart";

/// Helper functions for profile data conversion
class ProfileHelpers {
  /// Convert SuggestionCard to ProfileData
  static ProfileData suggestionCardToProfileData(SuggestionCard suggestion) {
    // Create mock photos with multiline captions
    final mockPhotos = <Photo>[];

    // Use real images from suggestion if available
    if (suggestion.imageUrls.isNotEmpty) {
      mockPhotos.addAll(
        suggestion.imageUrls.map(
          (url) => Photo(
            url: url,
            caption: null, // Captions might need to come from backend later
          ),
        ),
      );
    } else if (suggestion.imageUrl != null) {
      // Fallback to legacy single image
      mockPhotos.add(
        Photo(
          url: suggestion.imageUrl!,
          caption: null,
        ),
      );
    }

    // Add mock placeholders only if we have NO images (or maybe fewer than 2 to look good?)
    // For now, let's assume if backend provides images, we show ONLY those.
    // If backend provides 0 images, we show placeholders to avoid broken UI.
    if (mockPhotos.isEmpty) {
      mockPhotos.addAll(const [
        Photo(
          url:
              "https://images.unsplash.com/photo-1522163182402-834f871fd851?w=400",
          caption: "Conquering my fear of heights one climb at a time.",
        ),
        Photo(
          url:
              "https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=400",
          caption: "Photography is my way of preserving memories.",
        ),
        Photo(
          url:
              "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400",
          caption: "Nature never fails to amaze me.",
        ),
      ]);
    }

    return ProfileData(
      id: suggestion.id,
      userId: suggestion.userId,
      name: suggestion.name,
      age: suggestion.age,
      bio: suggestion.bio,
      relationshipPreview: suggestion.relationshipPreview,
      comparisonInsights: suggestion.comparisonInsights,
      photos: mockPhotos,
      interests: suggestion.interests,
      traits: [],
      conversationStyle: null,
      conversationStarter: null,
    );
  }
}
