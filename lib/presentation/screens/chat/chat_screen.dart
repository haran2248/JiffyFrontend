import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/presentation/widgets/chat_bubble.dart';
import 'package:jiffy/presentation/screens/onboarding/profile_setup/widgets/chat_input_field.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'widgets/chat_action_chip.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImage;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImage,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Mark messages as read when entering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatViewModelProvider(widget.otherUserId).notifier).markAsRead();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider(widget.otherUserId));

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E24), // Dark background from design
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E24),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.otherUserImage != null
                  ? NetworkImage(widget.otherUserImage!)
                  : null,
              child: widget.otherUserImage == null
                  ? Text(widget.otherUserName[0].toUpperCase())
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              widget.otherUserName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // TODO: Profile/Report actions
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Actions (Optional/Games removed as per request, keeping one as placeholder if needed or removing completely)
          // Removing as per user request to ignore games for now.

          // Messages List
          Expanded(
            child: chatState.when(
              data: (messages) {
                // Messages are typically newest first in UI lists with reverse: true
                // But our stream might return them sorted by timestamp ASC or DESC.
                // Our service returns ASC. ListView(reverse: true) needs DESC (newest at index 0).
                // Let's reverse the list locally for display
                final displayMessages = List.of(messages.reversed);

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: displayMessages.length,
                  itemBuilder: (context, index) {
                    final msg = displayMessages[index];

                    final isSender = msg.senderId != widget.otherUserId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: isSender
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (!isSender) ...[
                            Text(
                              widget.otherUserName,
                              style: TextStyle(
                                color: Colors.purple[200],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          ChatBubble(
                            text: msg.message,
                            isMe: isSender,
                            // Customizing colors handled inside ChatBubble or we assume Theme is set correctly.
                            // The design requested specific gradient for sender.
                            // ChatBubble supports Theme colors.
                            // We can wrap ChatBubble in a Theme or just rely on global theme if updated.
                            // Or simpler: The ChatBubble widget we saw uses Theme.of(context).colorScheme.primary/secondary
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              error: (err, stack) => Center(
                  child: Text('Error: $err',
                      style: const TextStyle(color: Colors.white))),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),

          // Bottom Suggestions
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                ChatActionChip(
                  label: "Ask about her trip",
                  icon: Icons.flight,
                  onTap: () {
                    ref
                        .read(
                            chatViewModelProvider(widget.otherUserId).notifier)
                        .sendMessage("How was your trip?");
                  },
                ),
                ChatActionChip(
                  label: "Suggest a fun question",
                  icon: Icons.chat_bubble_outline,
                  onTap: () {
                    // TODO: Generate question
                    ref
                        .read(
                            chatViewModelProvider(widget.otherUserId).notifier)
                        .sendMessage(
                            "If you could have any superpower, what would it be?");
                  },
                ),
              ],
            ),
          ),

          // Input Area
          Container(
            padding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 8),
            child: ChatInputField(
              onSend: (text) {
                ref
                    .read(chatViewModelProvider(widget.otherUserId).notifier)
                    .sendMessage(text);
              },
              // We might need to style ChatInputField to match the dark theme better
              // It seems to use Theme.of(context).cardColor etc.
            ),
          ),
        ],
      ),
    );
  }
}
