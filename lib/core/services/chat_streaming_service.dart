import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatStreamingServiceProvider = Provider((ref) => ChatStreamingService());

class ChatStreamingService {
  final String _baseUrl = 'http://192.168.0.100:5003';

  /// Streams chunks of the assistant's response via Server-Sent Events.
  /// Converts the `text/event-stream` format (`data:{chunk}\n\n`) into a Stream<String>.
  Stream<String> streamQuestions({
    required String uid,
    required List<Map<String, String>> history,
  }) async* {
    final client = http.Client();
    try {
      final uri =
          Uri.parse('$_baseUrl/api/onboarding/stream-questions?uid=$uid');
      debugPrint('🚀 [ChatStreamingService] Connecting to: $uri');

      final request = http.Request('POST', uri);
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(history);

      debugPrint('📦 [ChatStreamingService] Payload: ${request.body}');

      final response = await client.send(request);
      debugPrint(
          '📥 [ChatStreamingService] Response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        debugPrint('❌ [ChatStreamingService] Error body: $errorBody');
        throw Exception('Failed to stream questions: ${response.statusCode}');
      }

      final stream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in stream) {
        if (line.isEmpty) continue;

        debugPrint('🌊 [ChatStreamingService] Received raw line: $line');

        if (line.startsWith('data:')) {
          String data = line.substring(5); // Remove 'data:' prefix
          // Removed the SSE delimiter space logic, as the backend drops raw payload right after the colon

          if (data.trim() == '[DONE]') {
            debugPrint('✅ [ChatStreamingService] [DONE] signal received');
            break;
          }

          yield data;
        }
      }
    } catch (e, st) {
      debugPrint('❌ [ChatStreamingService] Exception caught: $e\n$st');
      rethrow;
    } finally {
      debugPrint('🔌 [ChatStreamingService] Closing client stream');
      client.close();
    }
  }
}
