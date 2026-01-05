import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show debugPrint, Icons;
import 'package:jiffy/presentation/screens/home/models/home_data.dart';
import 'package:jiffy/presentation/screens/home/models/suggestion_response.dart';
import 'package:jiffy/presentation/screens/profile/models/profile_data.dart';

/// Service for fetching home screen data from backend
class HomeService {
  final Dio _dio;

  HomeService(this._dio);

  /// Fetch all home screen data
  ///
  /// This will call the backend API to get:
  /// - Stories
  /// - Suggestions for the day
  /// - Trending items
  /// - Current match prompt
  Future<HomeData> fetchHomeData() async {
    // TODO: Replace with actual API call for Home Data
    // For now, return mock data layout
    debugPrint('HomeService: Fetching home data from backend...');

    await Future.delayed(const Duration(milliseconds: 500));

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
          imageUrl: null,
          storyType: StoryType.dating,
        ),
      ],
      suggestions: [], // Suggestions now fetched separately
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

  /// Fetch suggestions for a specific user
  /// [userId] - Current user's ID
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

  /// Fetch user matches (reusing same logic as MatchesRepository to allow display on Home)
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

  /// Refresh home data
  Future<HomeData> refreshHomeData() async {
    return fetchHomeData();
  }
}
