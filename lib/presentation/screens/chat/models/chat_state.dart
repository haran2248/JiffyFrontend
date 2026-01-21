import 'chat_message.dart';

/// State class for chat UI that includes:
/// - Messages from Firestore
/// - Pending optimistic messages (shown immediately before Firestore confirms)
/// - Typing indicator state for AI responses
class ChatState {
  final List<ChatMessageDisplay> messages;
  final bool isAiTyping;

  const ChatState({
    required this.messages,
    this.isAiTyping = false,
  });

  ChatState copyWith({
    List<ChatMessageDisplay>? messages,
    bool? isAiTyping,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isAiTyping: isAiTyping ?? this.isAiTyping,
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

  const ChatMessageDisplay({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = 'text',
    this.isPending = false,
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
      isPending: false,
    );
  }

  /// Create an optimistic pending message
  factory ChatMessageDisplay.pending({
    required String senderId,
    required String receiverId,
    required String message,
  }) {
    return ChatMessageDisplay(
      id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      timestamp: DateTime.now(),
      isPending: true,
    );
  }
}
