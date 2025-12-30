import 'dart:async';
import 'package:flutter/material.dart' show debugPrint;
import 'package:jiffy/presentation/screens/profile/models/conversation_starter_data.dart';

/// Service for fetching profile-related data from backend
class ProfileService {
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
      debugPrint('ProfileService: Fetching conversation starter data for user: $userId');
      
      // Simulate network delay with timeout
      await Future.delayed(const Duration(milliseconds: 500))
          .timeout(
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
            message: "I see you love hiking at Mission Peak. What's your favorite trail?",
            type: SparkIdeaType.location,
          ),
          SparkIdea(
            id: 'spark-2',
            category: 'Based on Interests',
            message: "We both love craft beer! Have you tried any new breweries lately?",
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
      debugPrint('ProfileService: Error fetching conversation starter data for user $userId - $e');
      rethrow;
    }
  }
}

