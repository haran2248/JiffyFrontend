import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jiffy/core/services/conversation_service.dart';
import '../data/chat_repository.dart';
import '../models/chat_message.dart';

part 'chat_viewmodel.g.dart';

@riverpod
class ChatViewModel extends _$ChatViewModel {
  late final ChatRepository _repository;
  late final ConversationService _conversationService;
  late final String _otherUserId;

  @override
  Stream<List<ChatMessage>> build(String otherUserId) {
    _otherUserId = otherUserId;
    _repository = ref.read(chatRepositoryProvider);
    _conversationService = ref.read(conversationServiceProvider);
    return _repository.messagesStream(otherUserId);
  }

  Future<void> sendMessage(String text) async {
    await _repository.sendMessage(_otherUserId, text);
  }

  Future<void> markAsRead() async {
    await _repository.markAsRead(_otherUserId);
  }

  /// Generate conversation suggestions using the AI API
  Future<List<ConversationSuggestion>> generateConversationSuggestions() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return [];
    }

    try {
      final suggestions = await _conversationService.generateSuggestions(
        userId: currentUser.uid,
        matchedUserId: _otherUserId,
      );
      return suggestions;
    } catch (e) {
      // Return empty list on error, UI will handle gracefully
      return [];
    }
  }
}
