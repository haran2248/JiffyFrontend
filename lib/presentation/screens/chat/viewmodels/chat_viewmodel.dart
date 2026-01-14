import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../chat_constants.dart';
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

    // Trigger AI response if chatting with Jiffy Bot
    if (otherUserId == ChatConstants.jiffyBotId) {
      _triggerAIResponse();
    }
  }

  Future<void> _triggerAIResponse() async {
    // 1. Wait for a delay
    await Future.delayed(const Duration(seconds: 2));

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // 2. Select a random response
    final List<String> aiResponses = [
      "That's fascinating! Tell me more.",
      "I see, that's a unique perspective.",
      "Interesting choice! purely logical, of course.",
      "I'm processing that... sounds great!",
    ];
    final randomResponse = aiResponses[Random().nextInt(aiResponses.length)];

    // 3. Send as system message
    await _repository.sendSystemMessage(
      currentUser.uid,
      randomResponse,
      ChatConstants.jiffyBotId,
    );
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

    // Send as system message
    await _repository.sendSystemMessage(
        currentUser.uid, prompt, ChatConstants.jiffyBotId);
  }
}
