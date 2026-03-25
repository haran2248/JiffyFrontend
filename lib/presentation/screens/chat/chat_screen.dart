import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:jiffy/core/services/service_providers.dart";
import "package:jiffy/presentation/widgets/chat_bubble.dart";
import "package:jiffy/presentation/screens/onboarding/profile_setup/widgets/chat_input_field.dart";
import "viewmodels/chat_viewmodel.dart";
import "widgets/chat_action_chip.dart";
import "widgets/typing_indicator.dart";
import "models/chat_state.dart";

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel =
          ref.read(chatViewModelProvider(widget.otherUserId).notifier);
      viewModel.markAsRead();

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        ref.read(homeServiceProvider).updateLastActive(uid);
      }

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

  Widget _buildMessagesList(ChatState chatState) {
    final messages = chatState.messages;
    final isAiTyping = chatState.isAiTyping;
    final streamingAiMessage = chatState.streamingAiMessage;

    // Streaming bubble takes slot 0; dots indicator only when no streaming yet
    final hasStreamingBubble = streamingAiMessage != null;
    final hasTypingDots = isAiTyping && !hasStreamingBubble;

    // Messages are sorted ASC (oldest first); ListView(reverse:true) needs DESC
    final displayMessages = List.of(messages.reversed);

    // Extra leading slot for either the streaming bubble or the typing dots
    final extraSlot = hasStreamingBubble || hasTypingDots ? 1 : 0;
    final itemCount = displayMessages.length + extraSlot;

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Slot 0: render streaming bubble or typing dots
        if (extraSlot == 1 && index == 0) {
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
                if (hasStreamingBubble && streamingAiMessage.isNotEmpty)
                  ChatBubble(
                    text: streamingAiMessage,
                    isMe: false,
                  )
                else
                  const TypingIndicator(),
              ],
            ),
          );
        }

        final msgIndex = extraSlot == 1 ? index - 1 : index;
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
              Row(
                mainAxisAlignment:
                    isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isSender && msg.hasError)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          ref
                              .read(chatViewModelProvider(widget.otherUserId)
                                  .notifier)
                              .retryMessage(msg);
                        },
                        child: const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  Flexible(
                    child: Opacity(
                      opacity: isPending ? 0.7 : 1.0,
                      child: ChatBubble(
                        text: msg.message,
                        isMe: isSender,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
