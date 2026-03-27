import "dart:convert";
import "dart:async";
import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
/// Service for Jiffy AI chat conversations.
///
/// Provides two modes:
/// - [sendMessageToAI] — legacy batch mode (non-streaming)
/// - [streamMessageToAI] — streaming mode via SSE, yields tokens as they arrive
class AiChatService {
  final Dio _dio;

  AiChatService({required Dio dio}) : _dio = dio;

  // ---------------------------------------------------------------------------
  // Legacy batch mode (kept for fallback / non-Jiffy-bot chats)
  // ---------------------------------------------------------------------------

  Future<bool> sendMessageToAI({
    required String userId,
    required String text,
  }) async {
    try {
      final response = await _dio.post(
        "/ai/chat",
        data: {"userId": userId, "text": text},
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("AiChatService: Error sending message: $e");
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Streaming mode — POST /api/chat/stream?uid={userId}
  // ---------------------------------------------------------------------------

  /// Streams the AI response token-by-token via Server-Sent Events.
  ///
  /// [userId]  - Firebase UID of the sender
  /// [matchId] - UID of the match being chatted with (empty for Jiffy bot)
  /// [text]    - The user's message
  ///
  /// Yields plain string tokens as they arrive. Completes on [DONE].
  Stream<String> streamMessageToAI({
    required String userId,
    required String matchId,
    required String text,
  }) async* {
    try {
      debugPrint("AiChatService: Opening stream to /api/chat/stream");

      final response = await _dio.post<ResponseBody>(
        "/api/chat/stream?uid=$userId",
        data: jsonEncode({"matchId": matchId, "text": text}),
        options: Options(
          responseType: ResponseType.stream,
          headers: {"Content-Type": "application/json"},
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      final lines = response.data!.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lines) {
        if (line.isEmpty) continue;
        if (line.startsWith("data:")) {
          final data = line.substring(5);
          if (data.trim() == "[DONE]") break;
          yield data;
        }
      }
    } catch (e, st) {
      debugPrint("AiChatService: Stream error: $e\n$st");
      rethrow;
    }
  }
}
