import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jiffy/presentation/screens/chat/models/chat_message.dart';
import 'package:jiffy/presentation/screens/vibe_check/data/vibe_check_repository.dart';
import 'package:jiffy/presentation/screens/vibe_check/models/vibe_check_state.dart';

part 'vibe_check_viewmodel.g.dart';

@riverpod
class VibeCheckViewModel extends _$VibeCheckViewModel {
  late final VibeCheckRepository _repo;
  StreamSubscription<List<ChatMessage>>? _firestoreSub;
  StreamSubscription<String>? _sseSub;
  Timer? _pollTimer;
  int _pollCount = 0;
  int _initRetryCount = 0;
  static const int _maxInitRetries = 3; // 9s total — safety net only

  @override
  VibeCheckState build(String chipId) {
    _repo = ref.watch(vibeCheckRepositoryProvider);

    ref.onDispose(() {
      _firestoreSub?.cancel();
      _sseSub?.cancel();
      _pollTimer?.cancel();
    });

    Future.microtask(() => _init(chipId));
    return const VibeCheckState();
  }

  Future<void> _init(String chipId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final result = await _repo.getStatus(userId, chipId);

    if (result.status == 'COMPLETED') {
      state = state.copyWith(
        status: ProbeStatus.completed,
        score: result.score,
        story: result.story,
      );
      return;
    }

    if (result.status == 'NOT_STARTED') {
      // Backend lazy init takes a moment — retry up to 3 times (9s total).
      if (_initRetryCount >= _maxInitRetries) {
        state = state.copyWith(
          error: () => 'Couldn\'t load this probe — try again later',
        );
        return;
      }
      _initRetryCount++;
      await Future.delayed(const Duration(seconds: 3));
      return _init(chipId);
    }

    // IN_PROGRESS
    state = state.copyWith(status: ProbeStatus.inProgress);
    _attachFirestoreListener(userId, chipId);
  }

  void _attachFirestoreListener(String userId, String chipId) {
    _firestoreSub?.cancel();
    _firestoreSub = _repo.messagesStream(userId, chipId).listen(
      (msgs) {
        final count =
            msgs.where((m) => m.senderId == userId).length;
        state = state.copyWith(messages: msgs, userAnswerCount: count);
      },
      onError: (e) {
        debugPrint('VibeCheckViewModel: Firestore error: $e');
      },
    );
  }

  Future<void> sendAnswer(String chipId, String text) async {
    final userId = _currentUserId;
    if (userId == null || text.trim().isEmpty) return;
    if (state.isStreaming) return;

    // Optimistic user bubble — Firestore listener will confirm it
    final optimistic = ChatMessage(
      id: 'optimistic_${DateTime.now().millisecondsSinceEpoch}',
      senderId: userId,
      receiverId: 'jiffy-ai',
      message: text.trim(),
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, optimistic],
      isStreaming: true,
      streamBuffer: '',
      error: () => null,
    );

    _sseSub?.cancel();
    _sseSub = _repo.streamAnswer(userId, chipId, text.trim()).listen(
      (token) {
        if (token == '[COMPLETE:false]') {
          state = state.copyWith(isStreaming: false, streamBuffer: '');
          return;
        }
        if (token == '[COMPLETE:true]') {
          state = state.copyWith(
            isStreaming: false,
            streamBuffer: '',
            status: ProbeStatus.scoring,
          );
          _startPolling(userId, chipId);
          return;
        }
        state = state.copyWith(streamBuffer: state.streamBuffer + token);
      },
      onError: (e) {
        debugPrint('VibeCheckViewModel: SSE error: $e');
        // Remove optimistic bubble on failure
        final msgs = state.messages.where((m) => m.id != optimistic.id).toList();
        state = state.copyWith(
          messages: msgs,
          isStreaming: false,
          streamBuffer: '',
          error: () => 'Couldn\'t send — try again',
        );
      },
    );
  }

  void _startPolling(String userId, String chipId) {
    _pollCount = 0;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      _pollCount++;
      if (_pollCount > 15) {
        _pollTimer?.cancel();
        state = state.copyWith(
          error: () => 'Score still processing — check back soon',
        );
        return;
      }
      try {
        final result = await _repo.getStatus(userId, chipId);
        if (result.status == 'COMPLETED') {
          _pollTimer?.cancel();
          state = state.copyWith(
            status: ProbeStatus.completed,
            score: result.score,
            story: result.story,
          );
        }
      } catch (e) {
        debugPrint('VibeCheckViewModel: Poll error: $e');
      }
    });
  }

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;
}
