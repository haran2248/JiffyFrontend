import 'package:flutter/material.dart';

/// Spark idea model for conversation starters
class SparkIdea {
  final String id;
  final String
      category; // e.g., "Based on Local Spots", "Based on Interests", "AI Generated"
  final String message; // The conversation starter message
  final SparkIdeaType type; // Type of spark idea for icon selection
  final DateTime? createdAt;

  const SparkIdea({
    required this.id,
    required this.category,
    required this.message,
    required this.type,
    this.createdAt,
  });

  /// Get icon data based on type
  IconData get iconData {
    switch (type) {
      case SparkIdeaType.location:
        return Icons.location_on;
      case SparkIdeaType.interests:
        return Icons.favorite;
      case SparkIdeaType.aiGenerated:
        return Icons.auto_awesome;
      case SparkIdeaType.commonTraits:
        return Icons.people;
      case SparkIdeaType.events:
        return Icons.event;
      default:
        return Icons.lightbulb;
    }
  }
}

/// Type of spark idea for categorization and icon selection
enum SparkIdeaType {
  location, // Based on local spots/location
  interests, // Based on shared interests
  aiGenerated, // AI-generated conversation starter
  commonTraits, // Based on common personality traits
  events, // Based on events or activities
  other, // Other types
}

/// Complete conversation starter data model
class ConversationStarterData {
  final String userId; // Profile user ID
  final List<SparkIdea> sparkIdeas; // List of spark ideas
  final int maxMessageLength; // Maximum allowed message length (default: 300)
  final bool isOnline; // Whether the user is currently online

  const ConversationStarterData({
    required this.userId,
    this.sparkIdeas = const [],
    this.maxMessageLength = 300,
    this.isOnline = false,
  });

  ConversationStarterData copyWith({
    String? userId,
    List<SparkIdea>? sparkIdeas,
    int? maxMessageLength,
    bool? isOnline,
  }) {
    return ConversationStarterData(
      userId: userId ?? this.userId,
      sparkIdeas: sparkIdeas ?? this.sparkIdeas,
      maxMessageLength: maxMessageLength ?? this.maxMessageLength,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
