import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jiffy/core/network/dio_provider.dart';
import 'package:jiffy/presentation/screens/chat/models/chat_message.dart';
import 'package:jiffy/presentation/screens/vibe_check/data/vibe_check_api_endpoints.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vibe_check_repository.g.dart';

class VibeCheckStatusResult {
  final String status;
  final int? score;
  final String? story;

  const VibeCheckStatusResult({
    required this.status,
    this.score,
    this.story,
  });
}

class VibeCheckRepository {
  final Dio _dio;
  final FirebaseFirestore _firestore;

  VibeCheckRepository({required Dio dio})
      : _firestore = FirebaseFirestore.instance,
        _dio = dio;

  /// GET /api/chip-probe/{userId}/{chipId}/status
  Future<VibeCheckStatusResult> getStatus(
      String userId, String chipId) async {
    try {
      final response =
          await _dio.get(VibeCheckApiEndpoints.status(userId, chipId));
      final data = response.data as Map<String, dynamic>;
      return VibeCheckStatusResult(
        status: data['status'] as String? ?? 'NOT_STARTED',
        score: data['score'] as int?,
        story: data['story'] as String?,
      );
    } catch (e) {
      debugPrint('VibeCheckRepository: getStatus error: $e');
      return const VibeCheckStatusResult(status: 'NOT_STARTED');
    }
  }

  /// POST /api/chip-probe/{userId}/{chipId}/chat — SSE stream.
  ///
  /// Yields plain text tokens. Yields '[COMPLETE:false]' or '[COMPLETE:true]'
  /// as terminal sentinels.
  Stream<String> streamAnswer(
      String userId, String chipId, String text) async* {
    try {
      final response = await _dio.post<ResponseBody>(
        VibeCheckApiEndpoints.chat(userId, chipId),
        data: jsonEncode({'text': text}),
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.acceptHeader: 'text/event-stream',
          },
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      final lines = response.data!.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lines) {
        if (line.isEmpty) continue;
        final raw = line.startsWith('data:') ? line.substring(5) : line;
        final trimmed = raw.trim();
        if (trimmed == '[DONE]') break;
        if (trimmed == '[COMPLETE:false]') {
          yield '[COMPLETE:false]';
          break;
        }
        if (trimmed == '[COMPLETE:true]') {
          yield '[COMPLETE:true]';
          break;
        }
        yield raw;
      }
    } catch (e, st) {
      debugPrint('VibeCheckRepository: streamAnswer error: $e\n$st');
      rethrow;
    }
  }

  /// Real-time Firestore listener for chip_probe_rooms/{userId}_{chipId}/messages.
  Stream<List<ChatMessage>> messagesStream(String userId, String chipId) {
    final roomId = '${userId}_$chipId';
    return _firestore
        .collection('chip_probe_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatMessage.fromMap(d.data(), d.id)).toList());
  }
}

@Riverpod(keepAlive: true)
VibeCheckRepository vibeCheckRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return VibeCheckRepository(dio: dio);
}
