import "dart:convert";
import "dart:async";
import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:jiffy/core/network/dio_provider.dart";

final chatStreamingServiceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return ChatStreamingService(dio: dio);
});

class ChatStreamingService {
  final Dio _dio;

  ChatStreamingService({required Dio dio}) : _dio = dio;

  /// Streams chunks of the assistant's response via Server-Sent Events.
  /// Converts the `text/event-stream` format (`data:{chunk}\n\n`) into a `Stream<String>`.
  Stream<String> streamQuestions({
    required String uid,
    required List<Map<String, String>> history,
  }) async* {
    try {
      debugPrint("ChatStreamingService: Connecting to /api/onboarding/stream-questions");

      final response = await _dio.post<ResponseBody>(
        "/api/onboarding/stream-questions?uid=$uid",
        data: jsonEncode(history),
        options: Options(
          responseType: ResponseType.stream,
          headers: {"Content-Type": "application/json"},
          receiveTimeout: const Duration(minutes: 2),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      debugPrint("ChatStreamingService: Stream connected");

      final lines = response.data!.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lines) {
        if (line.isEmpty) continue;

        if (line.startsWith("data:")) {
          final data = line.startsWith("data: ") ? line.substring(6) : line.substring(5);

          if (data.trim() == "[DONE]") {
            debugPrint("ChatStreamingService: [DONE] signal received");
            break;
          }

          yield data;
        }
      }
    } catch (e, st) {
      debugPrint("ChatStreamingService: Exception caught: $e\n$st");
      rethrow;
    }
  }

  /// Sends the final conversation history to mark onboarding as complete.
  Future<void> completeOnboarding({
    required String uid,
    required List<Map<String, String>> history,
  }) async {
    try {
      debugPrint("ChatStreamingService: Completing onboarding");

      await _dio.post(
        "/api/onboarding/stream-complete?uid=$uid",
        data: jsonEncode(history),
        options: Options(headers: {"Content-Type": "application/json"}),
      );
    } catch (e) {
      debugPrint("ChatStreamingService: Completion exception: $e");
      rethrow;
    }
  }
}
