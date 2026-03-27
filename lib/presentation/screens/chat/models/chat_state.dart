import "chat_message.dart";

/// State class for chat UI that includes:
/// - Messages from Firestore
/// - Pending optimistic messages (shown immediately before Firestore confirms)
/// - Typing indicator state for AI responses
/// - Streaming AI message (partial text while tokens arrive)
class ChatState {
  final List<ChatMessageDisplay> messages;
  final bool isAiTyping;

  /// Non-null while an AI response is streaming token-by-token.
  /// Replaces the typing indicator when present.
  final String? streamingAiMessage;

  const ChatState({
    required this.messages,
    this.isAiTyping = false,
    this.streamingAiMessage,
  });

  ChatState copyWith({
    List<ChatMessageDisplay>? messages,
    bool? isAiTyping,
    String? Function()? streamingAiMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isAiTyping: isAiTyping ?? this.isAiTyping,
      streamingAiMessage: streamingAiMessage != null
          ? streamingAiMessage()
          : this.streamingAiMessage,
    );
  }
}

/// Display model for chat messages that can represent both
/// confirmed Firestore messages and pending optimistic messages.
class ChatMessageDisplay {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? type;

  /// True if this message is pending confirmation from Firestore
  final bool isPending;

  /// True if this message failed to send
  final bool hasError;

  const ChatMessageDisplay({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = "text",
    this.isPending = false,
    this.hasError = false,
  });

  /// Create from a confirmed ChatMessage
  factory ChatMessageDisplay.fromChatMessage(ChatMessage msg) {
    return ChatMessageDisplay(
      id: msg.id,
      senderId: msg.senderId,
      receiverId: msg.receiverId,
      message: msg.message,
      timestamp: msg.timestamp,
      isRead: msg.isRead,
      type: msg.type,
    );
  }

  /// Create an optimistic pending message
  factory ChatMessageDisplay.pending({
    required String senderId,
    required String receiverId,
    required String message,
  }) {
    return ChatMessageDisplay(
      id: "pending_${DateTime.now().millisecondsSinceEpoch}",
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      timestamp: DateTime.now(),
      isPending: true,
    );
  }
}
