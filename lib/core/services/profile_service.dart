import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jiffy/presentation/screens/profile/models/conversation_starter_data.dart';
import 'package:jiffy/presentation/screens/profile/models/profile_data.dart';
import 'package:jiffy/presentation/screens/profile/profile_helpers.dart';
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
    final step = await getOnboardingStep(userId);
    return step == null;
  }

  /// Get the raw onboarding status from the backend
  ///
  /// Returns the onboarding status string (e.g., 'COMPLETED', 'CONTEXT_STORED', etc.)
  /// Returns null if user not found or on error
  Future<String?> getOnboardingStatus(String userId) async {
    try {
      final response = await _dio.get(
        '/api/users/getUser',
        queryParameters: {'uid': userId},
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        return null;
      }

      final onboardingStatusRaw = data['onboardingStatus'];
      return onboardingStatusRaw?.toString().toUpperCase();
    } on DioException catch (e) {
      // Handle 500 error when user doesn't exist yet (new user)
      if (e.response?.statusCode == 500 || e.response?.statusCode == 404) {
        debugPrint(
            'ProfileService: User not found when getting onboarding status - new user');
        return null;
      }
      debugPrint('ProfileService: Error getting onboarding status: $e');
      return null;
    } catch (e) {
      debugPrint('ProfileService: Error getting onboarding status: $e');
      return null;
    }
  }

  /// Get the specific onboarding step the user needs to complete.
  ///
  /// Returns:
  /// - 'basics' if user needs to complete basic profile data
  /// - 'chat' if user needs to complete chat-based onboarding
  /// - null if user is fully onboarded
  ///
  /// On error, returns 'basics' (safer to show onboarding than skip it)
  Future<String?> getOnboardingStep(String userId) async {
    try {
      debugPrint('ProfileService: Checking onboarding step for user: $userId');

      final response = await _dio.get(
        '/api/users/getUser',
        queryParameters: {'uid': userId},
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        debugPrint(
            'ProfileService: No user data found - new user, needs basics');
        return 'basics';
      }

      // ZERO: Check if user is waitlisted
      final isWaitlisted = data['isWaitlisted'] == true;

      if (isWaitlisted) {
        debugPrint('ProfileService: User is waitlisted, routing to waitlist');
        return 'waitlist';
      }

      // FIRST: Check onboardingStatus - if COMPLETED, user is fully onboarded
      // This is the most reliable indicator and should be checked first
      final onboardingStatusRaw = data['onboardingStatus'];
      final onboardingStatus = onboardingStatusRaw?.toString().toUpperCase();
      final isChatOnboardingComplete = onboardingStatus == 'COMPLETED';

      debugPrint(
          'ProfileService: onboardingStatus=$onboardingStatusRaw (normalized: $onboardingStatus), isChatOnboardingComplete=$isChatOnboardingComplete');

      if (isChatOnboardingComplete) {
        debugPrint(
            'ProfileService: User has COMPLETED onboarding status - fully onboarded');
        return null; // User is fully onboarded
      }

      // SECOND: Check if user has completed basics (name, basicDetails, images)
      final rootName = data['name'] as String?;
      final basicDetails = data['basicDetails'] as Map<String, dynamic>?;
      final basicDetailsName = basicDetails?['name'] as String?;
      final hasName = (rootName != null && rootName.isNotEmpty) ||
          (basicDetailsName != null && basicDetailsName.isNotEmpty);

      // Check if user has basicDetails object (indicates basics screen was completed)
      final hasBasicDetails = basicDetails != null;

      // Check for images - check both imageIds list and individual image ID fields
      final imageIds = data['imageIds'] as List?;
      final firstImageId = data['firstImageId'] as String?;
      final hasImages = (imageIds != null && imageIds.isNotEmpty) ||
          (firstImageId != null && firstImageId.isNotEmpty);

      // If user has started chat onboarding (CONTEXT_STORED or ANSWERS_STORED),
      // they've already progressed past basics, so images are optional
      final hasStartedChatOnboarding = onboardingStatus == 'CONTEXT_STORED' ||
          onboardingStatus == 'ANSWERS_STORED';

      // User has completed basics if they have name and basicDetails
      // Images are required UNLESS they've already started chat onboarding
      final hasCompletedBasics =
          hasName && hasBasicDetails && (hasImages || hasStartedChatOnboarding);

      debugPrint(
          'ProfileService: hasName=$hasName, hasBasicDetails=$hasBasicDetails, hasImages=$hasImages, hasStartedChatOnboarding=$hasStartedChatOnboarding, hasCompletedBasics=$hasCompletedBasics');

      if (!hasCompletedBasics) {
        debugPrint(
            'ProfileService: User needs to complete basics (missing: ${!hasName ? "name" : ""} ${!hasBasicDetails ? "basicDetails" : ""} ${!hasImages && !hasStartedChatOnboarding ? "images" : ""})');
        return 'basics';
      }

      // Basics are complete - check onboarding status
      // If status is CONTEXT_STORED or ANSWERS_STORED, user needs to complete chat onboarding
      // If status is null or NOT_STARTED, user also needs to complete chat onboarding
      final needsChatOnboarding = onboardingStatus == null ||
          onboardingStatus == 'NOT_STARTED' ||
          onboardingStatus == 'CONTEXT_STORED' ||
          onboardingStatus == 'ANSWERS_STORED';

      if (needsChatOnboarding) {
        debugPrint(
            'ProfileService: User needs to complete chat onboarding (status: $onboardingStatus)');
        return 'chat';
      }

      // Unknown status but basics are complete - assume chat onboarding needed
      debugPrint(
          'ProfileService: Unknown onboarding status ($onboardingStatus), routing to chat onboarding');
      return 'chat';
    } on DioException catch (e) {
      // Handle 500 error when user doesn't exist yet (new user)
      if (e.response?.statusCode == 500 || e.response?.statusCode == 404) {
        debugPrint('ProfileService: User not found (new user) - needs basics');
        return 'basics';
      }

      debugPrint(
          'ProfileService: DioException checking onboarding - ${e.message}');
      if (e.response != null) {
        debugPrint(
            'ProfileService: Response status: ${e.response?.statusCode}, data: ${e.response?.data}');
      }
      // On error, return basics to be safe
      return 'basics';
    } catch (e) {
      debugPrint('ProfileService: Error checking onboarding step: $e');
      // On error, return basics to be safe
      return 'basics';
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

  /// Fetch full profile data for a specific user ID
  Future<ProfileData?> fetchUserProfile(String userId) async {
    try {
      debugPrint("ProfileService: Fetching profile data for user: $userId");

      // 1. Fetch user basic info
      final userResponse = await _dio.get(
        '/api/users/getUser',
        queryParameters: {'uid': userId},
      );

      final userData = userResponse.data as Map<String, dynamic>?;
      if (userData == null) return null;

      // Parse basic details
      final basicDetails = userData['basicDetails'] as Map<String, dynamic>?;
      final name = basicDetails?['name'] as String? ??
          userData['name'] as String? ??
          "User";

      final dobString = basicDetails?['birthDate'] as String?;
      final age = ProfileHelpers.calculateAge(dobString);
      final location = basicDetails?['location'] as String?;
      final onboardingStatusRaw = userData['onboardingStatus'];
      final onboardingStatus = onboardingStatusRaw?.toString().toUpperCase();

      // Parse photos
      final photos = <Photo>[];
      final imageFields = [
        'firstImageId',
        'secondImageId',
        'thirdImageId',
        'fourthImageId'
      ];
      for (int i = 0; i < imageFields.length; i++) {
        final field = imageFields[i];
        String? imageId = userData[field] as String?;

        // If firstImageId is missing, fallback to the legacy 'imageId' to match ViewModels
        if (field == 'firstImageId' && (imageId == null || imageId.isEmpty)) {
          imageId = userData['imageId'] as String?;
        }

        if (imageId != null && imageId.isNotEmpty) {
          photos.add(Photo(
            url:
                'https://jiffystorebucket.s3.ap-south-1.amazonaws.com/$imageId',
            id: imageId,
            backendSlot: i + 1,
          ));
        }
      }

      // 2. Fetch curated profile data if available
      String aboutMe = '';
      List<String> interests = [];
      List<String> traits = [];
      String? conversationStyle;

      try {
        final curatedResponse = await _dio.get(
          '/api/onboarding/curated-profile',
          queryParameters: {'uid': userId},
        );

        if (curatedResponse.statusCode == 200) {
          final curatedDataData = curatedResponse.data as Map<String, dynamic>?;
          if (curatedDataData != null) {
            final curatedProfileData =
                curatedDataData['curatedProfile'] as Map<String, dynamic>?;
            if (curatedProfileData != null) {
              aboutMe = curatedProfileData['aboutMe'] as String? ?? '';
              interests = (curatedProfileData['interests'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [];
              traits =
                  (curatedProfileData['personalityTraits'] as List<dynamic>?)
                          ?.map((e) => e.toString())
                          .toList() ??
                      [];
              conversationStyle =
                  curatedProfileData['conversationStyleDescription'] as String?;
            }
          }
        }
      } catch (e) {
        debugPrint(
            "ProfileService: Error fetching curated profile for $userId: $e");
        // Non-fatal, continue with what we have
      }

      // If no aboutMe, fallback to bio if available in root
      if (aboutMe.isEmpty) {
        aboutMe = userData['bio'] as String? ?? '';
      }

      return ProfileData(
        id: userId,
        userId: userId,
        name: name,
        age: age,
        location: location,
        photos: photos,
        bio: aboutMe,
        interests: interests,
        traits: traits,
        conversationStyle: conversationStyle,
        onboardingStatus: onboardingStatus,
        isWaitlisted: userData['isWaitlisted'] == true,
      );
    } catch (e) {
      debugPrint("ProfileService: Error fetching user profile: $e");
      return null;
    }
  }
}
