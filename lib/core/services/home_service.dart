import 'package:flutter/material.dart' show debugPrint, Icons;
import 'package:jiffy/presentation/screens/home/models/home_data.dart';

/// Service for fetching home screen data from backend
class HomeService {
  /// Fetch all home screen data
  /// 
  /// This will call the backend API to get:
  /// - Stories
  /// - Suggestions for the day
  /// - Trending items
  /// - Current match prompt
  Future<HomeData> fetchHomeData() async {
    // TODO: Replace with actual API call
    // For now, return mock data
    debugPrint('HomeService: Fetching home data from backend...');
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock data - replace with actual API call
    return const HomeData(
      stories: [
        StoryItem(
          id: 'story-1',
          userId: 'user-current',
          name: 'Your Story',
          isUserStory: true,
        ),
        StoryItem(
          id: 'story-2',
          userId: 'user-2',
          name: 'Dating A...',
          imageUrl: null, // Placeholder
        ),
        StoryItem(
          id: 'story-3',
          userId: 'user-3',
          name: 'Alex',
          imageUrl: null,
        ),
        StoryItem(
          id: 'story-4',
          userId: 'user-4',
          name: 'Jordan',
          imageUrl: null,
        ),
      ],
      suggestions: [
        SuggestionCard(
          id: 'suggestion-1',
          userId: 'user-3',
          name: 'Alex',
          age: 24,
          bio: 'Weekend adventurer, weekday coffee...',
          relationshipPreview: 'Expect lots of outdoor dates, spontaneous road trips, and...',
          tags: ['Hiking', 'Photography'],
        ),
        SuggestionCard(
          id: 'suggestion-2',
          userId: 'user-4',
          name: 'Jordan',
          age: 26,
          bio: 'Art gallery regular, live music fanatic. Foodie...',
          relationshipPreview: 'Think art exhibitions, live concerts, cooking together, and trying...',
          tags: ['Art', 'Live Music'],
        ),
      ],
      trendingItems: [
        TrendingItem(
          id: 'trending-1',
          title: 'Hot Take: Pineapple on Pizza',
          description: 'Do you love it or hate it?',
          type: TrendingItemType.hotTake,
          iconData: Icons.local_fire_department,
        ),
        TrendingItem(
          id: 'trending-2',
          title: 'Favorite Local Hiking Trails',
          description: 'Top picks for hiking spots',
          type: TrendingItemType.location,
          iconData: Icons.location_on,
        ),
      ],
      currentPrompt: MatchPrompt(
        id: 'prompt-1',
        promptText: 'What\'s a small thing that brings you immense joy?',
        isNew: true,
      ),
    );
  }

  /// Refresh home data
  Future<HomeData> refreshHomeData() async {
    return fetchHomeData();
  }

  /// Fetch more suggestions (pagination)
  Future<List<SuggestionCard>> fetchMoreSuggestions({
    int page = 1,
    int limit = 10,
  }) async {
    debugPrint('HomeService: Fetching more suggestions (page: $page)...');
    await Future.delayed(const Duration(milliseconds: 500));
    
    // TODO: Replace with actual API call
    return const [];
  }
}

