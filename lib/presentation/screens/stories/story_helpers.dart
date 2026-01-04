import 'package:jiffy/presentation/screens/home/models/home_data.dart';
import 'package:jiffy/presentation/screens/stories/models/story_models.dart';

/// Helper functions for story-related operations
class StoryHelpers {
  /// Convert a StoryItem to a Story for viewing
  /// This is a temporary helper until backend integration is complete
  static Story storyItemToStory(StoryItem storyItem) {
    // For now, create a mock story with a single content item
    // In production, this would fetch actual story content from backend
    final content = StoryContent(
      id: '${storyItem.id}_content_1',
      imageUrl: storyItem.imageUrl ?? '',
      overlays: const [],
      createdAt: DateTime.now(),
      isLocal: false,
    );

    return Story(
      id: storyItem.id,
      userId: storyItem.userId,
      userName: storyItem.name,
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

