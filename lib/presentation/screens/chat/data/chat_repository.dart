import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiffy/core/services/chat_service.dart';
import '../models/chat_message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_repository.g.dart';

class ChatRepository {
  final ChatService _chatService;

  ChatRepository(this._chatService);

  Future<void> sendMessage(String receiverID, String message) async {
    return _chatService.sendMessage(receiverID, message);
  }

  Stream<List<ChatMessage>> messagesStream(String otherUserId) {
    return _chatService.getMessages(otherUserId).map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatMessage.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<String> getLastMessage(String otherUserId) {
    return _chatService.getLastMessage(
        _chatService.currentUserId ?? '', otherUserId);
  }

  Future<void> markAsRead(String otherUserId) async {
    return _chatService.markMessagesAsRead(otherUserId);
  }
}

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) {
  return ChatRepository(ChatService());
}
