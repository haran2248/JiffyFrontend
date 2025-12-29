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
  Future<ConversationStarterData> fetchConversationStarterData(
    String userId,
  ) async {
    // TODO: Replace with actual API call
    // For now, return mock data
    // TODO: Remove or replace debugPrint with proper logging framework before production
    debugPrint('ProfileService: Fetching conversation starter data for user: $userId');
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
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
  }
}

