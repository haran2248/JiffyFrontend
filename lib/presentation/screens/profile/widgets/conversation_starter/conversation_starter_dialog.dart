import "dart:ui";
import "package:flutter/material.dart";
import "package:jiffy/presentation/screens/profile/models/profile_data.dart";
import "package:jiffy/presentation/screens/profile/models/conversation_starter_data.dart";
import "package:jiffy/presentation/screens/profile/widgets/conversation_starter/conversation_starter_header.dart";
import "package:jiffy/presentation/screens/profile/widgets/conversation_starter/conversation_starter_profile_info.dart";
import "package:jiffy/presentation/screens/profile/widgets/conversation_starter/conversation_starter_spark_ideas.dart";
import "package:jiffy/presentation/screens/profile/widgets/conversation_starter/conversation_starter_message_input.dart";
import "package:jiffy/presentation/screens/profile/widgets/conversation_starter/conversation_starter_send_button.dart";

/// Conversation starter dialog with blurred background
class ConversationStarterDialog extends StatefulWidget {
  final ProfileData profile;
  final ConversationStarterData conversationData;

  const ConversationStarterDialog({
    super.key,
    required this.profile,
    required this.conversationData,
  });

  @override
  State<ConversationStarterDialog> createState() =>
      _ConversationStarterDialogState();

  /// Show the dialog
  static Future<String?> show(
    BuildContext context,
    ProfileData profile,
    ConversationStarterData conversationData,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface.withValues(alpha: 0),
      barrierColor: colorScheme.surface.withValues(alpha: 0.5),
      builder: (context) => ConversationStarterDialog(
        profile: profile,
        conversationData: conversationData,
      ),
    );
  }
}

class _ConversationStarterDialogState extends State<ConversationStarterDialog> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messageFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_messageFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _messageFocusNode.removeListener(_handleFocusChange);
    _messageFocusNode.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSendSpark() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      Navigator.of(context).pop(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isKeyboardVisible = viewInsets.bottom > 0;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: isKeyboardVisible ? screenHeight * 0.92 : screenHeight * 0.75,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: viewInsets.bottom),
              child: Column(
                children: [
                  // Fixed Header
                  ConversationStarterHeader(
                    profileName: widget.profile.name,
                    onClose: () => Navigator.of(context).pop(),
                  ),

                  // Scrollable body containing profile info, spark ideas, and message input
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile info
                          ConversationStarterProfileInfo(
                            profile: widget.profile,
                            isOnline: widget.conversationData.isOnline,
                          ),

                          const SizedBox(height: 20),

                          // Spark Ideas section
                          ConversationStarterSparkIdeas(
                            conversationData: widget.conversationData,
                            onCardTap: (message) {
                              final maxLength =
                                  widget.conversationData.maxMessageLength;
                              final truncatedMessage = message.length > maxLength
                                  ? message.substring(0, maxLength)
                                  : message;
                              _messageController.text = truncatedMessage;
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: 24),

                          // Custom message input
                          ConversationStarterMessageInput(
                            controller: _messageController,
                            focusNode: _messageFocusNode,
                            maxLength: widget.conversationData.maxMessageLength,
                            onChanged: () => setState(() {}),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // Send Spark button pinned right above keyboard
                  ConversationStarterSendButton(
                    messageController: _messageController,
                    onSend: _handleSendSpark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
