import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jiffy/presentation/screens/profile/models/conversation_starter_data.dart';
import '../network/dio_provider.dart';

part 'profile_service.g.dart';

/// Service for fetching profile-related data from backend
@riverpod
ProfileService profileService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ProfileService(dio: dio);
}

class ProfileService {
  final Dio _dio;

  ProfileService({required Dio dio}) : _dio = dio;

  /// Check if user has completed onboarding
  ///
  /// A user is considered onboarded if they have:
  /// - Basic profile details (basicDetails with name, photo, dateOfBirth, gender)
  /// - Profile setup completed (prompts map is not null/empty)
  ///
  /// [userId] - The user ID to check
  ///
  /// Returns true if onboarding is complete, false otherwise
  /// On error, returns false (safer to show onboarding than skip it)
  Future<bool> isOnboardingComplete(String userId) async {
    try {
      debugPrint('ProfileService: Checking onboarding status for user: $userId');

      final response = await _dio.get(
        '/api/users/getUser',
        queryParameters: {'uid': userId},
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        debugPrint('ProfileService: No user data found');
        return false;
      }

      // Log the full response structure for debugging
      debugPrint('ProfileService: User data keys: ${data.keys.toList()}');
      debugPrint('ProfileService: User data: $data');

      // Check if user has name (can be at root level or in basicDetails)
      final rootName = data['name'] as String?;
      final basicDetails = data['basicDetails'] as Map<String, dynamic>?;
      final basicDetailsName = basicDetails?['name'] as String?;
      final hasName = (rootName != null && rootName.isNotEmpty) ||
          (basicDetailsName != null && basicDetailsName.isNotEmpty);

      // Check if user has basicDetails object (indicates basics screen was completed)
      final hasBasicDetails = basicDetails != null;

      // Check if user has prompts (from profile setup screen)
      // Prompts can be Map<Integer, String> or Map<String, dynamic> depending on JSON serialization
      final prompts = data['prompts'];
      final hasPrompts = prompts != null && 
          (prompts is Map && prompts.isNotEmpty);

      // Check for other indicators of completed onboarding:
      // - bio (indicates profile was set up)
      // - imageIds (indicates photos were uploaded)
      final hasBio = data['bio'] != null && data['bio'].toString().isNotEmpty;
      final imageIds = data['imageIds'] as List?;
      final hasImages = imageIds != null && imageIds.isNotEmpty;

      // User is onboarded if they have:
      // 1. Name AND (basicDetails OR bio OR images) - indicates they completed basics and have profile data
      // OR
      // 2. Prompts - indicates profile setup was completed
      // This is more lenient to handle cases where prompts might not be saved yet
      final isOnboarded = hasName && (hasBasicDetails || hasBio || hasImages) || hasPrompts;
      
      debugPrint('ProfileService: Onboarding check - rootName=$rootName, basicDetailsName=$basicDetailsName, hasName=$hasName, hasBasicDetails=$hasBasicDetails, hasPrompts=$hasPrompts, hasBio=$hasBio, hasImages=$hasImages, isOnboarded=$isOnboarded');
      
      return isOnboarded;
    } on DioException catch (e) {
      debugPrint('ProfileService: DioException checking onboarding - ${e.message}');
      if (e.response != null) {
        debugPrint('ProfileService: Response status: ${e.response?.statusCode}, data: ${e.response?.data}');
      }
      // On error, assume not onboarded to be safe
      return false;
    } catch (e) {
      debugPrint('ProfileService: Error checking onboarding status: $e');
      // On error, assume not onboarded to be safe
      return false;
    }
  }

  /// Fetch conversation starter data (spark ideas) for a user
  ///
  /// This will call the backend API to get:
  /// - List of spark ideas (location-based, interest-based, AI-generated, etc.)
  /// - User online status
  /// - Maximum message length
  ///
  /// [userId] - The user ID for whom to fetch conversation starter data
  ///
  /// Throws [TimeoutException] if the request times out
  /// Throws [FormatException] if the response cannot be parsed
  /// Throws [Exception] for other network or server errors
  Future<ConversationStarterData> fetchConversationStarterData(
    String userId,
  ) async {
    try {
      // TODO: Replace with actual API call
      // TODO: Remove or replace debugPrint with proper logging framework before production
      debugPrint(
          'ProfileService: Fetching conversation starter data for user: $userId');

      // Simulate network delay with timeout
      await Future.delayed(const Duration(milliseconds: 500)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException(
            'Request timed out while fetching conversation starter data for user: $userId',
            const Duration(seconds: 10),
          );
        },
      );

      // Mock data - replace with actual API call
      // Backend should return JSON with structure:
      // {
      //   "userId": "user-123",
      //   "sparkIdeas": [
      //     {
      //       "id": "spark-1",
      //       "category": "Based on Local Spots",
      //       "message": "I see you love hiking at Mission Peak. What's your favorite trail?",
      //       "type": "location"
      //     },
      //     ...
      //   ],
      //   "maxMessageLength": 300,
      //   "isOnline": true
      // }
      // TODO: Add JSON validation before constructing ConversationStarterData
      return ConversationStarterData(
        userId: userId,
        sparkIdeas: const [
          SparkIdea(
            id: 'spark-1',
            category: 'Based on Local Spots',
            message:
                "I see you love hiking at Mission Peak. What's your favorite trail?",
            type: SparkIdeaType.location,
          ),
          SparkIdea(
            id: 'spark-2',
            category: 'Based on Interests',
            message:
                "We both love craft beer! Have you tried any new breweries lately?",
            type: SparkIdeaType.interests,
          ),
          SparkIdea(
            id: 'spark-3',
            category: 'AI Generated',
            message: "Ask me about my most recent travel mishap!",
            type: SparkIdeaType.aiGenerated,
          ),
        ],
        maxMessageLength: 300,
        isOnline: true,
      );
    } on TimeoutException catch (e) {
      // TODO: Replace with proper logging framework
      debugPrint('ProfileService: Timeout error - $e');
      rethrow;
    } on FormatException catch (e) {
      // TODO: Replace with proper logging framework
      debugPrint('ProfileService: Format error - $e');
      rethrow;
    } on Exception catch (e) {
      // TODO: Replace with proper logging framework
      debugPrint(
          'ProfileService: Error fetching conversation starter data for user $userId - $e');
      rethrow;
    }
  }
}
