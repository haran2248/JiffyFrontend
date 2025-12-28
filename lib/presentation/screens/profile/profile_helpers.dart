import "package:jiffy/presentation/screens/home/models/home_data.dart";
import "package:jiffy/presentation/screens/profile/models/profile_data.dart";

/// Helper functions for profile data conversion
class ProfileHelpers {
  /// Convert SuggestionCard to ProfileData
  static ProfileData suggestionCardToProfileData(SuggestionCard suggestion) {
    // Create mock photos with multiline captions
    final mockPhotos = <Photo>[];

    // Main photo (from suggestion)
    if (suggestion.imageUrl != null) {
      mockPhotos.add(
        Photo(
          url: suggestion.imageUrl!,
          caption: null, // Main photo doesn't have caption
        ),
      );
    }

    // Additional photos with multiline captions
    mockPhotos.addAll(const [
      Photo(
        url:
            "https://images.unsplash.com/photo-1522163182402-834f871fd851?w=400",
        caption:
            "Conquering my fear of heights one climb at a time. The view from the top is always worth it.",
      ),
      Photo(
        url:
            "https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=400",
        caption:
            "Capturing moments that take my breath away. Photography is my way of preserving memories.",
      ),
      Photo(
        url:
            "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400",
        caption:
            "Sunset hikes are my favorite way to end the day. Nature never fails to amaze me.",
      ),
    ]);

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
