import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show debugPrint, Icons;
import 'package:jiffy/core/auth/auth_repository.dart';
import 'package:jiffy/presentation/screens/home/models/home_data.dart';
import 'package:jiffy/presentation/screens/home/models/suggestion_response.dart';
import 'package:jiffy/presentation/screens/profile/models/profile_data.dart';
import 'package:jiffy/presentation/screens/stories/data/stories_repository.dart';
import 'package:jiffy/presentation/screens/matches/data/matches_repository.dart';

/// Service for fetching home screen data from backend
class HomeService {
  final StoriesRepository _storiesRepository;
  final MatchesRepository _matchesRepository;
  final AuthRepository _authRepository;
  final Dio _dio;

  HomeService({
    required StoriesRepository storiesRepository,
    required MatchesRepository matchesRepository,
    required AuthRepository authRepository,
    required Dio dio,
  })  : _storiesRepository = storiesRepository,
        _matchesRepository = matchesRepository,
        _authRepository = authRepository,
        _dio = dio;

  /// Fetch all home screen data
  ///
  /// This will call the backend API to get:
  /// - Stories (from matched users)
  /// - Suggestions for the day
  /// - Trending items
  /// - Current match prompt
  Future<HomeData> fetchHomeData() async {
    debugPrint('HomeService: Fetching home data from backend...');

    // Fetch stories from matched users
    List<StoryItem> stories = await _fetchStories();

    // Mock data for other sections - TODO: Replace with actual API calls
    return HomeData(
      stories: stories,
      suggestions: [], // Suggestions now fetched separately via fetchSuggestions
      trendingItems: [
        TrendingItem(
          id: 'trending-1',
          title: 'Hot Take: Pineapple on Pizza',
          description: 'Do you love it or hate it?',
          type: TrendingItemType.hotTake,
          iconData: Icons.local_fire_department,
        ),
      ],
      currentPrompt: MatchPrompt(
        id: 'prompt-1',
        promptText: 'What\'s a small thing that brings you immense joy?',
        isNew: true,
      ),
    );
  }

  /// Fetch stories from matched users and combine with match info
  Future<List<StoryItem>> _fetchStories() async {
    try {
      final user = _authRepository.currentUser;
      if (user == null) {
        debugPrint(
            'HomeService: User not authenticated, returning empty stories');
        return [];
      }

      // Fetch stories from matched users
      final storiesJson = await _storiesRepository.fetchStories();
      debugPrint('HomeService: Fetched ${storiesJson.length} stories from API');

      if (storiesJson.isEmpty) {
        // Return only user's own story if no matches have stories
        return [
          StoryItem(
            id: 'user-story',
            userId: user.uid,
            name: 'Your Story',
            isUserStory: true,
          ),
        ];
      }

      // Fetch matches to get user names and images
      final matchesJson = await _matchesRepository.fetchMatches();
      debugPrint('HomeService: Fetched ${matchesJson.length} matches from API');

      // Create a map of userId -> match info for quick lookup
      final matchesMap = <String, Map<String, dynamic>>{};
      for (final match in matchesJson) {
        final uid = match['uid']?.toString();
        if (uid != null && uid.isNotEmpty) {
          matchesMap[uid] = match;
        }
      }

      int? _parseTimestamp(dynamic timestamp) {
        if (timestamp == null) return null;
        if (timestamp is int) return timestamp;
        if (timestamp is String) {
          final dateTime = DateTime.tryParse(timestamp);
          return dateTime?.millisecondsSinceEpoch;
        }
        return null;
      }

      // Group stories by userId and get the most recent one per user
      final storiesByUser = <String, Map<String, dynamic>>{};
      for (final story in storiesJson) {
        final userId = story['userId'] as String?;
        if (userId == null) continue;

        final existingStory = storiesByUser[userId];
        if (existingStory == null) {
          storiesByUser[userId] = story;
        } else {
          // Compare createdAt to keep the most recent
          final existingTs = _parseTimestamp(existingStory['createdAt']);
          final currentTs = _parseTimestamp(story['createdAt']);
          if (currentTs != null &&
              (existingTs == null || currentTs > existingTs)) {
            storiesByUser[userId] = story;
          }
        }
      }

      // Convert to StoryItem objects
      final storyItems = <StoryItem>[
        // User's own story at the beginning
        StoryItem(
          id: 'user-story',
          userId: user.uid,
          name: 'Your Story',
          isUserStory: true,
        ),
      ];

      // Add matched users' stories
      for (final entry in storiesByUser.entries) {
        final userId = entry.key;
        final story = entry.value;
        final matchInfo = matchesMap[userId];

        final name = matchInfo?['name'] as String? ?? 'Unknown';
        // Note: MatchResponse provides imageId, not imageUrl. For now, we leave imageUrl as null.
        // The Avatar widget will show a default icon when imageUrl is null.
        // TODO: Convert imageId to presigned URL if profile images are needed for story previews
        const String? imageUrl = null;

        final createdAt = story['createdAt'];
        DateTime? createdAtDate;
        if (createdAt is int) {
          createdAtDate =
              DateTime.fromMillisecondsSinceEpoch(createdAt, isUtc: true);
        } else if (createdAt is String) {
          createdAtDate = DateTime.tryParse(createdAt)?.toUtc();
        }

        storyItems.add(
          StoryItem(
            id: story['id'] as String? ?? userId,
            userId: userId,
            name: name,
            imageUrl: imageUrl,
            isUserStory: false,
            createdAt: createdAtDate,
          ),
        );
      }

      debugPrint('HomeService: Created ${storyItems.length} story items');
      return storyItems;
    } catch (e) {
      debugPrint('HomeService: Error fetching stories: $e');
      // Return user's own story on error
      final user = _authRepository.currentUser;
      if (user != null) {
        return [
          StoryItem(
            id: 'user-story',
            userId: user.uid,
            name: 'Your Story',
            isUserStory: true,
          ),
        ];
      }
      return [];
    }
  }

  Future<SuggestionResponse> fetchSuggestions(String userId) async {
    try {
      debugPrint('HomeService: Fetching real suggestions for $userId...');
      final response = await _dio.get('/api/suggestions/$userId');

      if (response.statusCode == 200) {
        return SuggestionResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch suggestions: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('HomeService: Error fetching suggestions: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchMatches(String userId) async {
    try {
      debugPrint('HomeService: Fetching matches for $userId...');
      final response = await _dio.get(
        '/api/v1/match/myMatches',
        queryParameters: {'uid': userId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception("Failed to fetch matches: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('HomeService: Error fetching matches: $e');
      // Return empty list on error instead of breaking home screen
      return [];
    }
  }

  Future<HomeData> refreshHomeData() async {
    return fetchHomeData();
  }
}
