import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jiffy/core/services/chat_streaming_service.dart';
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

    // Get the user's display name or fallback
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName?.split(' ').first ?? 'there';

    final firstMessage = ChatMessage(
      text:
          "Hey $userName, we want to know you a bit better so that we can find you relevant matches, so tell me whats the craziest thing you have done lately?",
      isFromUser: false,
      timestamp: DateTime.now(),
    );

    // Inject the first app prompt and unlock input immediately
    state = state.copyWith(
      messages: [firstMessage],
      isTyping: false,
    );
  }

  void addUserMessage(String text) {
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

    // Hard cap the conversation at 6 user answers to prevent infinite loop
    final userMessageCount = nextMessages.where((m) => m.isFromUser).length;
    if (userMessageCount >= 6) {
      debugPrint(
          '✅ [ProfileSetupViewModel] Conversation cap reached. Ending onboarding natively.');

      final completionMessage = ChatMessage(
        text:
            "Perfect! I've got everything I need. Your profile is looking great! 🎉",
        isFromUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, completionMessage],
        showCompletionDialog: true,
      );
    } else {
      _startAssistantStream();
    }
  }

  void _startAssistantStream() {
    debugPrint('🚀 [ProfileSetupViewModel] _startAssistantStream initiated');
    // 1. Prepare history mapped to role/content JSON expectations
    final history = state.messages
        .map((msg) => {
              'role': msg.isFromUser ? 'user' : 'assistant',
              'content': msg.text,
            })
        .toList();

    // 2. Lock input and set typing indicator natively
    state = state.copyWith(
      isTyping: true, // Lock input while receiving stream
    );

    // 3. Initialize SSE Stream request
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous_uid';
    final chatService = ref.read(chatStreamingServiceProvider);

    _streamSubscription?.cancel();
    _streamSubscription =
        chatService.streamQuestions(uid: uid, history: history).listen(
      (chunk) {
        final currentMessages = List<ChatMessage>.from(state.messages);

        // If the last message was the user's, this is the first assistant token.
        // We will instantiate the assistant bubble now!
        if (currentMessages.isEmpty || currentMessages.last.isFromUser) {
          currentMessages.add(ChatMessage(
            text: chunk,
            isFromUser: false,
            timestamp: DateTime.now(),
          ));
        } else {
          // Trailing assistant message exists, append chunk
          final lastMsg = currentMessages.last;
          currentMessages[currentMessages.length - 1] = lastMsg.copyWith(
            text: lastMsg.text + chunk,
          );
        }

        // Setting state rapidly updates the UI to reflect new tokens
        state = state.copyWith(messages: currentMessages);
      },
      onDone: () {
        debugPrint('✅ [ProfileSetupViewModel] Stream completed natively');
        // [DONE] payload resolves the stream, unlock input.
        state = state.copyWith(isTyping: false);
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
