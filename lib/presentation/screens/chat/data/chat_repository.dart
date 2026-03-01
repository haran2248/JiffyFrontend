import 'package:jiffy/core/services/chat_service.dart';
import 'package:jiffy/core/network/dio_provider.dart';
import '../models/chat_message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_repository.g.dart';

class ChatRepository {
  final ChatService _chatService;

  ChatRepository(this._chatService);

  Future<void> sendMessage(String receiverID, String message) async {
    return _chatService.sendMessage(receiverID, message);
  }

  Future<void> sendSystemMessage(
      String receiverID, String message, String senderID) async {
    return _chatService.sendSystemMessage(receiverID, message, senderID);
  }

  Stream<List<ChatMessage>> messagesStream(String otherUserId) {
    return _chatService.getMessages(otherUserId).map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatMessage.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<ChatMessage?> getLastMessage(String otherUserId) async {
    final data = await _chatService.getLastMessage(
        _chatService.currentUserId ?? '', otherUserId);
    if (data != null) {
      return ChatMessage.fromMap(
          data, ''); // ID not strictly needed for preview
    }
    return null;
  }

  Future<bool> hasUserSentMessage(String otherUserId) async {
    final currentUserId = _chatService.currentUserId;
    if (currentUserId == null) return false;
    return _chatService.hasUserSentMessage(currentUserId, otherUserId);
  }

  Future<void> markAsRead(String otherUserId) async {
    return _chatService.markMessagesAsRead(otherUserId);
  }
}

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ChatRepository(ChatService(dio: dio));
}
