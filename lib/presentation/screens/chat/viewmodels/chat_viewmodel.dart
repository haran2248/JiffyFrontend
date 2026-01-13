import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/chat_repository.dart';
import '../models/chat_message.dart';

part 'chat_viewmodel.g.dart';

@riverpod
class ChatViewModel extends _$ChatViewModel {
  late final ChatRepository _repository;

  @override
  Stream<List<ChatMessage>> build(String otherUserId) {
    _repository = ref.read(chatRepositoryProvider);
    return _repository.messagesStream(otherUserId);
  }

  Future<void> sendMessage(String text) async {
    await _repository.sendMessage(otherUserId, text);
  }

  Future<void> markAsRead() async {
    await _repository.markAsRead(otherUserId);
  }
}
