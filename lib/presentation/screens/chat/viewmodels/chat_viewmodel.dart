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

    // Reconcile pending messages: One-to-one matching
    // For each confirmed message, remove the FIRST matching pending message
    // Match logic: Same message content and senderId
    // We iterate backwards through confirmed messages to match naturally with pending queue
    final pendingToRemove = <ChatMessageDisplay>[];

    for (final confirmed in confirmedMessages) {
      // Find the first matching pending message that hasn't been marked for removal
      try {
        final match = _pendingMessages.firstWhere((pending) {
          return !pendingToRemove.contains(pending) &&
              pending.message == confirmed.message &&
              pending.senderId == confirmed.senderId;
        });
        pendingToRemove.add(match);
      } catch (e) {
        // No match found, that's fine (message wasn't pending or already handled)
      }
    }

    // Remove matched pending messages
    _pendingMessages.removeWhere((p) => pendingToRemove.contains(p));

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

    final pendingMsg = ChatMessageDisplay.pending(
      senderId: currentUser.uid,
      receiverId: otherUserId,
      message: text,
    );
    _pendingMessages.add(pendingMsg);

    // Update state immediately
    _updateState();

    try {
      if (otherUserId == ChatConstants.jiffyBotId) {
        // Show typing indicator
        _isAiTyping = true;
        _updateState();

        // Send to AI API
        await _sendToAiChat(currentUser.uid, text, pendingMsg);
      } else {
        // Regular user-to-user chat: send directly to Firestore
        await _repository.sendMessage(otherUserId, text);
      }
    } catch (e) {
      _handleSendError(pendingMsg);
    }
  }

  void _updateState() {
    final currentMessages = state.messages.where((m) => !m.isPending).toList();
    final allMessages = [...currentMessages, ..._pendingMessages];
    allMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    state = state.copyWith(
      messages: allMessages,
      isAiTyping: _isAiTyping,
    );
  }

  void _handleSendError(ChatMessageDisplay pendingMsg) {
    debugPrint('ChatViewModel: Error sending message');

    // Find message and mark as error
    final index = _pendingMessages.indexOf(pendingMsg);
    if (index != -1) {
      // Create copy with error flag
      final errorMsg = ChatMessageDisplay(
        id: pendingMsg.id,
        senderId: pendingMsg.senderId,
        receiverId: pendingMsg.receiverId,
        message: pendingMsg.message,
        timestamp: pendingMsg.timestamp,
        isRead: pendingMsg.isRead,
        type: pendingMsg.type,
        isPending: true, // Still pending (retryable)
        hasError: true,
      );

      _pendingMessages[index] = errorMsg;
      _isAiTyping = false; // Stop typing if error
      _updateState();
    }
  }

  /// Send message to Jiffy AI via backend API.
  Future<void> _sendToAiChat(
      String userId, String text, ChatMessageDisplay pendingMsg) async {
    try {
      final aiChatService = ref.read(aiChatServiceProvider);
      final success = await aiChatService.sendMessageToAI(
        userId: userId,
        text: text,
      );

      if (!success) {
        _handleSendError(pendingMsg);
      }
      // Response will appear via Firestore stream
    } catch (e) {
      _handleSendError(pendingMsg);
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
    // Use local state if available to save a read
    final messages = state.messages;
    if (messages.isNotEmpty) {
      final lastMsg = messages.last; // Sorted ASC, so last is newest
      if (lastMsg.message == prompt &&
          lastMsg.senderId == ChatConstants.jiffyBotId) {
        return;
      }
    } else {
      // Fallback to fetch if local state empty (edge case)
      final lastMsg = await _repository.getLastMessage(otherUserId);
      if (lastMsg != null &&
          lastMsg.message == prompt &&
          lastMsg.senderId == ChatConstants.jiffyBotId) {
        return;
      }
    }

    // Send the prompt as a message FROM Jiffy AI (not from the user)
    // This way it appears as Jiffy asking the user the question
    await _repository.sendSystemMessage(
      currentUser.uid, // receiverID: the current user receives this prompt
      prompt,
      ChatConstants.jiffyBotId, // senderID: Jiffy AI is asking the question
    );
    // The message will appear via the Firestore stream
    // User can then type their answer, which will trigger a normal AI response
  }

  Future<void> retryMessage(ChatMessageDisplay message) async {
    // Find the message in pending messages including those with errors
    final index = _pendingMessages.indexWhere((m) => m.id == message.id);
    if (index == -1) return;

    // Reset error state
    final pendingMsg = _pendingMessages[index];
    final retryingMsg = ChatMessageDisplay(
      id: pendingMsg.id,
      senderId: pendingMsg.senderId,
      receiverId: pendingMsg.receiverId,
      message: pendingMsg.message,
      timestamp: pendingMsg.timestamp,
      isRead: pendingMsg.isRead,
      type: pendingMsg.type,
      isPending: true,
      hasError: false, // Reset error
    );

    _pendingMessages[index] = retryingMsg;
    _updateState();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      if (otherUserId == ChatConstants.jiffyBotId) {
        // Show typing indicator again
        _isAiTyping = true;
        _updateState();

        await _sendToAiChat(currentUser.uid, retryingMsg.message, retryingMsg);
      } else {
        // Regular chat retry
        await _repository.sendMessage(otherUserId, retryingMsg.message);
      }
    } catch (e) {
      _handleSendError(retryingMsg);
    }
  }
}
