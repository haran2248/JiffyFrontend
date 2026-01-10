import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../network/dio_provider.dart';

part 'conversation_service.g.dart';

/// Service for generating conversation suggestions
@riverpod
ConversationService conversationService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ConversationService(dio: dio);
}

class ConversationService {
  final Dio _dio;

  ConversationService({required Dio dio}) : _dio = dio;

  /// Generate conversation suggestions for a match
  /// 
  /// [userId] - Current user ID
  /// [matchedUserId] - Matched user ID
  /// [context] - Optional conversation context (e.g., recent messages)
  /// 
  /// Returns a list of conversation suggestion strings
  Future<List<ConversationSuggestion>> generateSuggestions({
    required String userId,
    required String matchedUserId,
    String? context,
  }) async {
    try {
      debugPrint(
        'ConversationService: Generating suggestions for user $userId with match $matchedUserId'
      );

      final queryParams = {
        'uid': userId,
        'matchedUid': matchedUserId,
      };

      if (context != null && context.isNotEmpty) {
        queryParams['context'] = context;
      }

      final response = await _dio.post(
        '/api/v1/match/conversation/generate',
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;
      final suggestionsData = data['suggestions'] as List<dynamic>?;

      if (suggestionsData == null || suggestionsData.isEmpty) {
        debugPrint('ConversationService: No suggestions received');
        return [];
      }

      final suggestions = suggestionsData
          .map((item) => ConversationSuggestion.fromJson(item as Map<String, dynamic>))
          .toList();

      debugPrint('ConversationService: Generated ${suggestions.length} suggestions');
      return suggestions;
    } catch (e) {
      debugPrint('ConversationService: Error generating suggestions: $e');
      rethrow;
    }
  }
}

/// Model for a conversation suggestion
class ConversationSuggestion {
  final String text;
  final String category;

  ConversationSuggestion({
    required this.text,
    required this.category,
  });

  factory ConversationSuggestion.fromJson(Map<String, dynamic> json) {
    return ConversationSuggestion(
      text: json['text'] as String? ?? '',
      category: json['category'] as String? ?? 'question',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'category': category,
    };
  }
}
