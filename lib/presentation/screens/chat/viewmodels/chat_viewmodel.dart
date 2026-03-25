import "dart:async";

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:jiffy/core/services/service_providers.dart";
import "../chat_constants.dart";
import "../data/chat_repository.dart";
import "../models/chat_message.dart";
import "../models/chat_state.dart";

part "chat_viewmodel.g.dart";

@riverpod
class ChatViewModel extends _$ChatViewModel {
  late final ChatRepository _repository;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  /// Active AI streaming subscription — non-null while tokens are arriving.
  StreamSubscription<String>? _streamSubscription;

  /// Accumulated streaming text for the current AI response.
  String _streamingMessage = "";

  /// ID of the last confirmed Jiffy Bot message seen from Firestore.
  /// Used to detect when the NEW AI response lands so we can clear the
  /// streaming bubble and show the confirmed message in one state update.
  String? _lastSeenAiMessageId;

  /// Pending messages not yet confirmed by Firestore
  final List<ChatMessageDisplay> _pendingMessages = [];

  /// Whether AI is currently generating a response (shows dots before first token)
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
        debugPrint("ChatViewModel: Stream error: $error");
      },
    );

    // Cleanup subscriptions when disposed
    ref.onDispose(() {
      _messagesSubscription?.cancel();
      _streamSubscription?.cancel();
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
    final pendingToRemove = <ChatMessageDisplay>[];

    for (final confirmed in confirmedMessages) {
      try {
        final match = _pendingMessages.firstWhere((pending) {
          return !pendingToRemove.contains(pending) &&
              pending.message == confirmed.message &&
              pending.senderId == confirmed.senderId;
        });
        pendingToRemove.add(match);
      } catch (e) {
        // No match found — message wasn't pending or already handled
      }
    }

    // Remove matched pending messages
    _pendingMessages.removeWhere((p) => pendingToRemove.contains(p));

    // Stop typing indicator when the AI response arrives in Firestore.
    // Only applies to the legacy typing-dots state; streaming mode manages its
    // own _isAiTyping flag via the stream callbacks.
    if (_isAiTyping && firestoreMessages.isNotEmpty) {
      final sortedMessages = List<ChatMessage>.from(firestoreMessages)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final latestMessage = sortedMessages.first;
      if (latestMessage.senderId == ChatConstants.jiffyBotId) {
        _isAiTyping = false;
      }
    }

    // Detect a genuinely new Jiffy Bot message by comparing against the last
    // known AI message ID. When one arrives while streaming is active, clear
    // the streaming bubble in the same state update to avoid a duplicate frame.
    final latestAiMessage = firestoreMessages
        .where((m) => m.senderId == ChatConstants.jiffyBotId)
        .fold<ChatMessage?>(null, (prev, curr) =>
            prev == null || curr.timestamp.isAfter(prev.timestamp) ? curr : prev);

    bool clearStreaming = false;
    if (latestAiMessage != null && latestAiMessage.id != _lastSeenAiMessageId) {
      _lastSeenAiMessageId = latestAiMessage.id;
      if (state.streamingAiMessage != null) {
        _streamSubscription?.cancel();
        _streamSubscription = null;
        _streamingMessage = "";
        clearStreaming = true;
      }
    }

    // Combine confirmed and pending messages
    final allMessages = [...confirmedMessages, ..._pendingMessages];
    allMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    state = state.copyWith(
      messages: allMessages,
      isAiTyping: _isAiTyping,
      streamingAiMessage: clearStreaming ? () => null : null,
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

    // Update state immediately with the optimistic message
    _updateState();

    try {
      if (otherUserId == ChatConstants.jiffyBotId) {
        // Show dots until first token arrives
        _isAiTyping = true;
        _updateState();

        await _streamAiChat(currentUser.uid, text, pendingMsg);
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
    debugPrint("ChatViewModel: Error sending message");

    final index = _pendingMessages.indexOf(pendingMsg);
    if (index != -1) {
      final errorMsg = ChatMessageDisplay(
        id: pendingMsg.id,
        senderId: pendingMsg.senderId,
        receiverId: pendingMsg.receiverId,
        message: pendingMsg.message,
        timestamp: pendingMsg.timestamp,
        isRead: pendingMsg.isRead,
        type: pendingMsg.type,
        isPending: true,
        hasError: true,
      );

      _pendingMessages[index] = errorMsg;
      _isAiTyping = false;
      _updateState();
    }
  }

  /// Streams the AI response token-by-token and updates [ChatState.streamingAiMessage]
  /// as each chunk arrives. On completion, clears the streaming bubble and lets
  /// the Firestore listener pick up the confirmed AI message.
  Future<void> _streamAiChat(
    String userId,
    String text,
    ChatMessageDisplay pendingMsg,
  ) async {
    final aiChatService = ref.read(aiChatServiceProvider);
    _streamingMessage = "";

    // Transition from dots to empty streaming bubble immediately
    _isAiTyping = false;
    state = state.copyWith(
      isAiTyping: false,
      streamingAiMessage: () => "",
    );

    _streamSubscription?.cancel();
    _streamSubscription = aiChatService
        .streamMessageToAI(
          userId: userId,
          matchId: otherUserId,
          text: text,
        )
        .listen(
          (token) {
            _streamingMessage += token;
            state = state.copyWith(
              streamingAiMessage: () => _streamingMessage,
            );
          },
          onDone: () {
            _streamingMessage = "";
            state = state.copyWith(
              streamingAiMessage: () => null,
              isAiTyping: false,
            );
          },
          onError: (Object e) {
            debugPrint("ChatViewModel: AI stream error: $e");
            _streamingMessage = "";
            _isAiTyping = false;
            state = state.copyWith(
              streamingAiMessage: () => null,
              isAiTyping: false,
            );
            _handleSendError(pendingMsg);
          },
          cancelOnError: true,
        );
  }

  Future<void> markAsRead() async {
    await _repository.markAsRead(otherUserId);
  }

  Future<void> checkAndSendPrompt(String prompt) async {
    if (otherUserId != ChatConstants.jiffyBotId) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final messages = state.messages;
    if (messages.isNotEmpty) {
      final lastMsg = messages.last;
      if (lastMsg.message == prompt &&
          lastMsg.senderId == ChatConstants.jiffyBotId) {
        return;
      }
    } else {
      final lastMsg = await _repository.getLastMessage(otherUserId);
      if (lastMsg != null &&
          lastMsg.message == prompt &&
          lastMsg.senderId == ChatConstants.jiffyBotId) {
        return;
      }
    }

    await _repository.sendSystemMessage(
      currentUser.uid,
      prompt,
      ChatConstants.jiffyBotId,
    );
  }

  Future<void> retryMessage(ChatMessageDisplay message) async {
    final index = _pendingMessages.indexWhere((m) => m.id == message.id);
    if (index == -1) return;

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
      hasError: false,
    );

    _pendingMessages[index] = retryingMsg;
    _updateState();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      if (otherUserId == ChatConstants.jiffyBotId) {
        _isAiTyping = true;
        _updateState();

        await _streamAiChat(currentUser.uid, retryingMsg.message, retryingMsg);
      } else {
        await _repository.sendMessage(otherUserId, retryingMsg.message);
      }
    } catch (e) {
      _handleSendError(retryingMsg);
    }
  }
}
