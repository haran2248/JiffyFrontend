import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Service for Jiffy AI chat conversations.
///
/// Calls the backend AI chat API. The backend handles:
/// - Processing the AI response
/// - Storing both user message and AI response to Firestore
///
/// The frontend should continue listening to the Firestore stream
/// to receive message updates.
class AiChatService {
  final Dio _dio;

  /// Base URL for the AI chat API
  static const String _baseUrl =
      'https://limitless-sea-53782-2c45e56f3e92.herokuapp.com';

  AiChatService({required Dio dio}) : _dio = dio;

  /// Send a message to Jiffy AI.
  ///
  /// [userId] - The current user's Firebase UID
  /// [text] - The message text to send to the AI
  ///
  /// Returns true if the API call was successful.
  /// The actual response will appear in the Firestore stream.
  Future<bool> sendMessageToAI({
    required String userId,
    required String text,
  }) async {
    try {
      final maskedUserId = userId.length > 4
          ? '${userId.substring(0, 4)}...${userId.hashCode}'
          : '...${userId.hashCode}';
      debugPrint('AiChatService: Sending message to AI for user $maskedUserId');

      final response = await _dio.post(
        '$_baseUrl/ai/chat',
        data: {
          'userId': userId,
          'text': text,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        debugPrint('AiChatService: Message sent successfully');
        return true;
      } else {
        debugPrint('AiChatService: Failed with status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('AiChatService: Error sending message: $e');
      return false;
    }
  }
}
