import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jiffy/core/services/service_providers.dart';
import '../chat_constants.dart';
import '../data/chat_repository.dart';
import '../models/chat_message.dart';
import '../models/chat_state.dart';

part 'chat_viewmodel.g.dart';

@riverpod
class ChatViewModel extends _$ChatViewModel {
  late final ChatRepository _repository;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  /// Pending messages not yet confirmed by Firestore
  final List<ChatMessageDisplay> _pendingMessages = [];

  /// Whether AI is currently generating a response
  bool _isAiTyping = false;

  @override
  ChatState build(String otherUserId) {
    _repository = ref.read(chatRepositoryProvider);

    // Listen to Firestore messages stream
    _messagesSubscription = _repository.messagesStream(otherUserId).listen(
      (messages) {
        _onMessagesReceived(messages);
      },
      onError: (error) {
        debugPrint('ChatViewModel: Stream error: $error');
      },
    );

    // Cleanup subscription when disposed
    ref.onDispose(() {
      _messagesSubscription?.cancel();
    });

    return const ChatState(messages: [], isAiTyping: false);
  }

  void _onMessagesReceived(List<ChatMessage> firestoreMessages) {
    // Convert Firestore messages to display messages
    final confirmedMessages = firestoreMessages
        .map((m) => ChatMessageDisplay.fromChatMessage(m))
        .toList();

    // Remove pending messages that are now confirmed
    _pendingMessages.removeWhere((pending) {
      return confirmedMessages.any((confirmed) =>
          confirmed.message == pending.message &&
          confirmed.senderId == pending.senderId);
    });

    // If we received a NEW AI message (i.e. the latest message is from AI), stop typing
    // We sort by timestamp to find the latest
    if (_isAiTyping && firestoreMessages.isNotEmpty) {
      final sortedMessages = List<ChatMessage>.from(firestoreMessages)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first

      final latestMessage = sortedMessages.first;
      if (latestMessage.senderId == ChatConstants.jiffyBotId) {
        // We received the response!
        _isAiTyping = false;
      }
    }

    // Combine confirmed and pending messages
    final allMessages = [...confirmedMessages, ..._pendingMessages];
    allMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    state = ChatState(
      messages: allMessages,
      isAiTyping: _isAiTyping,
    );
  }

  Future<void> sendMessage(String text) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // If chatting with Jiffy AI, send via AI chat API
    if (otherUserId == ChatConstants.jiffyBotId) {
      // Add optimistic message immediately
      final pendingMsg = ChatMessageDisplay.pending(
        senderId: currentUser.uid,
        receiverId: otherUserId,
        message: text,
      );
      _pendingMessages.add(pendingMsg);

      // Show typing indicator
      _isAiTyping = true;

      // Update state immediately
      final currentMessages = state.messages;
      state = ChatState(
        messages: [...currentMessages, pendingMsg],
        isAiTyping: true,
      );

      // Send to AI API
      await _sendToAiChat(currentUser.uid, text);
    } else {
      // Regular user-to-user chat: add optimistic message
      final pendingMsg = ChatMessageDisplay.pending(
        senderId: currentUser.uid,
        receiverId: otherUserId,
        message: text,
      );
      _pendingMessages.add(pendingMsg);

      // Update state immediately
      final currentMessages = state.messages;
      state = state.copyWith(
        messages: [...currentMessages, pendingMsg],
      );

      // Send to Firestore
      await _repository.sendMessage(otherUserId, text);
    }
  }

  /// Send message to Jiffy AI via backend API.
  Future<void> _sendToAiChat(String userId, String text) async {
    try {
      final aiChatService = ref.read(aiChatServiceProvider);
      final success = await aiChatService.sendMessageToAI(
        userId: userId,
        text: text,
      );

      if (!success) {
        debugPrint('ChatViewModel: AI chat API call failed');
        // Stop typing indicator on failure
        _isAiTyping = false;
        state = state.copyWith(isAiTyping: false);
      }
      // Response will appear via Firestore stream
    } catch (e) {
      debugPrint('ChatViewModel: Error sending to AI: $e');
      _isAiTyping = false;
      state = state.copyWith(isAiTyping: false);
    }
  }

  Future<void> markAsRead() async {
    await _repository.markAsRead(otherUserId);
  }

  Future<void> checkAndSendPrompt(String prompt) async {
    // Only proceed if this is the Jiffy Bot
    if (otherUserId != ChatConstants.jiffyBotId) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Check last message to avoid duplicates
    final lastMsg = await _repository.getLastMessage(otherUserId);
    if (lastMsg != null &&
        lastMsg.message == prompt &&
        lastMsg.senderId == ChatConstants.jiffyBotId) {
      return;
    }

    // Show typing indicator for prompt
    _isAiTyping = true;
    state = state.copyWith(isAiTyping: true);

    // Send prompt via AI chat API
    await _sendToAiChat(currentUser.uid, prompt);
  }
}
