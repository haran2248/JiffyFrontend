import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jiffy/core/services/chat_streaming_service.dart';
import 'package:jiffy/core/network/dio_provider.dart';
import '../models/profile_setup_form_data.dart';

part 'profile_setup_viewmodel.g.dart';

@riverpod
class ProfileSetupViewModel extends _$ProfileSetupViewModel {
  StreamSubscription<String>? _streamSubscription;
  bool _isInitialized = false;

  @override
  ProfileSetupFormData build() {
    ref.onDispose(() {
      _streamSubscription?.cancel();
    });

    // Initialize onboarding when viewmodel is created
    Future.microtask(() {
      if (!_isInitialized) {
        _initializeOnboarding();
      }
    });

    return const ProfileSetupFormData(
      messages: [],
      suggestedResponses: [],
      currentQuestion: null,
      currentStep: 2,
      isTyping: true,
      showCompletionDialog: false,
    );
  }

  Future<void> _initializeOnboarding() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final user = FirebaseAuth.instance.currentUser;
    String userName = user?.displayName?.split(' ').first ?? 'there';

    // Try to fetch the actual name the user entered in basicDetails
    try {
      final uid = user?.uid;
      if (uid != null) {
        final dio = ref.read(dioProvider);
        final response = await dio.get(
          '/api/users/getUser',
          queryParameters: {'uid': uid},
        );
        final data = response.data as Map<String, dynamic>?;
        final basicDetails = data?['basicDetails'] as Map<String, dynamic>?;
        final fullName = basicDetails?['name'] as String?;
        if (fullName != null && fullName.isNotEmpty) {
          userName = fullName.split(' ').first;
        }
      }
    } catch (e) {
      debugPrint('[ProfileSetupViewModel] Failed to fetch user name: $e');
      // Fall back to displayName or 'there'
    }

    final firstMessage = ChatMessage(
      text:
          "Hey $userName, we want to know you a bit better so that we can find you relevant matches. So tell me, what's taking your energy up lately?",
      isFromUser: false,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [firstMessage],
      isTyping: false,
    );
  }

  Future<void> addUserMessage(String text) async {
    debugPrint(
        '💬 [ProfileSetupViewModel] addUserMessage called with: "$text"');
    if (text.trim().isEmpty || state.isTyping) {
      debugPrint(
          '⚠️ [ProfileSetupViewModel] Message blocked. isEmpty: ${text.trim().isEmpty}, isTyping: ${state.isTyping}');
      return;
    }

    final userMessage = ChatMessage(
      text: text.trim(),
      isFromUser: true,
      timestamp: DateTime.now(),
    );

    final nextMessages = [...state.messages, userMessage];
    debugPrint(
        '🔄 [ProfileSetupViewModel] Updating state with new user message');
    state = state.copyWith(
      messages: nextMessages,
      userInput: () => null,
      clearUserInput: true,
    );

    _startAssistantStream(text.trim());
  }

  void _startAssistantStream(String message) {
    debugPrint('🚀 [ProfileSetupViewModel] _startAssistantStream initiated');

    // Lock input and set typing indicator natively
    state = state.copyWith(
      isTyping: true, // Lock input while receiving stream
    );

    // Initialize SSE Stream request
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous_uid';
    final chatService = ref.read(chatStreamingServiceProvider);

    _streamSubscription?.cancel();
    _streamSubscription =
        chatService.streamConversationTurn(uid: uid, message: message).listen(
      (chunkData) {
        try {
          final parsed = jsonDecode(chunkData);
          if (parsed is Map<String, dynamic>) {
            if (parsed.containsKey('chunk')) {
              final textChunk = parsed['chunk'] as String;
              final currentMessages = List<ChatMessage>.from(state.messages);

              if (currentMessages.isEmpty || currentMessages.last.isFromUser) {
                currentMessages.add(ChatMessage(
                  text: textChunk,
                  isFromUser: false,
                  timestamp: DateTime.now(),
                ));
              } else {
                final lastMsg = currentMessages.last;
                currentMessages[currentMessages.length - 1] = lastMsg.copyWith(
                  text: lastMsg.text + textChunk,
                );
              }
              state = state.copyWith(messages: currentMessages);
            } else if (parsed.containsKey('is_complete')) {
              final isComplete = parsed['is_complete'] as bool? ?? false;
              if (isComplete) {
                debugPrint(
                    '🏁 [ProfileSetupViewModel] Onboarding complete signal received');

                state = state.copyWith(
                  showCompletionDialog: true,
                  isCompleting: false,
                  isTyping: false,
                );
              }
            }
          }
        } catch (e) {
          // Ignore invalid JSON or fallback if needed
        }
      },
      onDone: () {
        debugPrint('✅ [ProfileSetupViewModel] Stream completed natively');
        if (state.isTyping && !state.showCompletionDialog) {
          state = state.copyWith(isTyping: false);
        }
      },
      onError: (e) {
        debugPrint('❌ [ProfileSetupViewModel] Streaming error SSE: $e');
        state = state.copyWith(isTyping: false);
      },
    );
  }

  void selectSuggestedResponse(String response) {
    addUserMessage(response);
  }

  void updateUserInput(String? input) {
    state = state.copyWith(userInput: () => input);
  }

  void nextStep() {
    debugPrint('🚀 Navigating to next step (permissions)');
  }

  void dismissCompletionDialog() {
    state = state.copyWith(showCompletionDialog: false);
  }

  void skip() {
    nextStep();
  }
}
