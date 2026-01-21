import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/presentation/widgets/chat_bubble.dart';
import 'package:jiffy/presentation/screens/onboarding/profile_setup/widgets/chat_input_field.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'widgets/chat_action_chip.dart';
import 'widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImage;
  final String? promptText;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImage,
    this.promptText,
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
      final viewModel =
          ref.read(chatViewModelProvider(widget.otherUserId).notifier);
      viewModel.markAsRead();

      // If there is a prompt text, try to send it as a system message
      if (widget.promptText != null && widget.promptText!.isNotEmpty) {
        viewModel.checkAndSendPrompt(widget.promptText!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider(widget.otherUserId));

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B14), // AppColors.midnightPlum
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0B14),
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
          // Messages List
          Expanded(
            child: _buildMessagesList(chatState),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(dynamic chatState) {
    // ChatState contains messages and isAiTyping
    final messages = chatState.messages;
    final isAiTyping = chatState.isAiTyping;

    // Messages are sorted ASC (oldest first)
    // ListView(reverse: true) needs them in DESC (newest at index 0)
    final displayMessages = List.of(messages.reversed);

    // Calculate item count: messages + typing indicator if active
    final itemCount = displayMessages.length + (isAiTyping ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // If typing indicator is active, show it as the first item (index 0 in reversed list)
        if (isAiTyping && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: TextStyle(
                    color: Colors.purple[200],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const TypingIndicator(),
              ],
            ),
          );
        }

        // Adjust index if typing indicator is shown
        final msgIndex = isAiTyping ? index - 1 : index;
        final msg = displayMessages[msgIndex];

        final isSender = msg.senderId != widget.otherUserId;
        final isPending = msg.isPending;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment:
                isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
              Opacity(
                // Slightly fade pending messages to indicate they're not yet confirmed
                opacity: isPending ? 0.7 : 1.0,
                child: ChatBubble(
                  text: msg.message,
                  isMe: isSender,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
