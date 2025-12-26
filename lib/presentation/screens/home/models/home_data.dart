import 'package:flutter/material.dart';

/// Models for home screen server-driven data

/// Story item for the stories section
class StoryItem {
  final String id;
  final String userId;
  final String? name;
  final String? imageUrl;
  final bool isUserStory; // If true, shows "Your Story" with + icon
  final DateTime? createdAt;

  const StoryItem({
    required this.id,
    required this.userId,
    this.name,
    this.imageUrl,
    this.isUserStory = false,
    this.createdAt,
  });
}

/// Suggestion card data for "Suggestions for the Day"
class SuggestionCard {
  final String id;
  final String userId;
  final String name;
  final int age;
  final String? imageUrl;
  final String bio; // Short bio text
  final String relationshipPreview; // "Expect lots of outdoor dates..."
  final List<String> tags; // e.g., ["Hiking", "Photography"]

  const SuggestionCard({
    required this.id,
    required this.userId,
    required this.name,
    required this.age,
    this.imageUrl,
    required this.bio,
    required this.relationshipPreview,
    this.tags = const [],
  });
}

/// Trending topic/item in the area
class TrendingItem {
  final String id;
  final String title;
  final String description;
  final TrendingItemType type;
  final String? iconUrl; // Optional custom icon
  final IconData iconData; // Material icon as fallback

  const TrendingItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.iconUrl,
    required this.iconData,
  });
}

enum TrendingItemType {
  hotTake,
  location,
  interest,
  event,
}

/// Prompt card for matches section
class MatchPrompt {
  final String id;
  final String promptText;
  final bool isNew;
  final DateTime? createdAt;

  const MatchPrompt({
    required this.id,
    required this.promptText,
    this.isNew = false,
    this.createdAt,
  });
}

/// Complete home screen data model
class HomeData {
  final List<StoryItem> stories;
  final List<SuggestionCard> suggestions;
  final List<TrendingItem> trendingItems;
  final MatchPrompt? currentPrompt;

  const HomeData({
    this.stories = const [],
    this.suggestions = const [],
    this.trendingItems = const [],
    this.currentPrompt,
  });

  HomeData copyWith({
    List<StoryItem>? stories,
    List<SuggestionCard>? suggestions,
    List<TrendingItem>? trendingItems,
    MatchPrompt? Function()? currentPrompt,
  }) {
    return HomeData(
      stories: stories ?? this.stories,
      suggestions: suggestions ?? this.suggestions,
      trendingItems: trendingItems ?? this.trendingItems,
      currentPrompt:
          currentPrompt != null ? currentPrompt() : this.currentPrompt,
    );
  }
}
