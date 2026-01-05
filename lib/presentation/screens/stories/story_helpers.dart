import 'package:jiffy/presentation/screens/home/models/home_data.dart';
import 'package:jiffy/presentation/screens/stories/models/story_models.dart';

/// Helper functions for story-related operations
class StoryHelpers {
  /// Convert a StoryItem to a Story for viewing
  ///
  /// **Temporary Mock Implementation:**
  /// This is a temporary helper until backend integration is complete.
  /// Currently reuses `storyItem.imageUrl` for both:
  /// - `StoryContent.imageUrl`: The story image content
  /// - `Story.userImageUrl`: The user's profile avatar
  ///
  /// **Production Note:**
  /// In production, `userImageUrl` should come from the user's profile data,
  /// not from the story item. The backend should provide distinct fields for
  /// the story content image and the user's profile avatar.
  static Story storyItemToStory(StoryItem storyItem) {
    // Create a mock story content with the story image
    // In production, this would fetch actual story content from backend
    final content = StoryContent(
      id: '${storyItem.id}_content_1',
      imageUrl: storyItem.imageUrl ?? '', // Story content image
      overlays: const [],
      createdAt: DateTime.now(),
      isLocal: false,
    );

    return Story(
      id: storyItem.id,
      userId: storyItem.userId,
      userName: storyItem.name,
      // TEMPORARY: Reusing storyItem.imageUrl for user avatar (mock data)
      // TODO: Replace with actual user profile avatar URL from backend
      userImageUrl: storyItem.imageUrl,
      contents: [content],
      createdAt: storyItem.createdAt ?? DateTime.now(),
    );
  }

  /// Convert a list of StoryItems to Stories
  static List<Story> storyItemsToStories(List<StoryItem> storyItems) {
    return storyItems
        .where((item) => !item.isUserStory) // Filter out user's own story
        .map((item) => storyItemToStory(item))
        .toList();
  }
}
