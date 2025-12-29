import "dart:ui";
import "package:flutter/material.dart";
import "package:jiffy/presentation/screens/profile/models/profile_data.dart";
import "package:jiffy/presentation/screens/profile/widgets/conversation_starter/conversation_starter_header.dart";
import "package:jiffy/presentation/screens/profile/widgets/conversation_starter/conversation_starter_profile_info.dart";
import "package:jiffy/presentation/screens/profile/widgets/conversation_starter/conversation_starter_spark_ideas.dart";
import "package:jiffy/presentation/screens/profile/widgets/conversation_starter/conversation_starter_message_input.dart";
import "package:jiffy/presentation/screens/profile/widgets/conversation_starter/conversation_starter_send_button.dart";

/// Conversation starter dialog with blurred background
class ConversationStarterDialog extends StatefulWidget {
  final ProfileData profile;

  const ConversationStarterDialog({
    super.key,
    required this.profile,
  });

  @override
  State<ConversationStarterDialog> createState() =>
      _ConversationStarterDialogState();

  /// Show the dialog
  static Future<String?> show(BuildContext context, ProfileData profile) {
    final colorScheme = Theme.of(context).colorScheme;
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface.withValues(alpha: 0),
      barrierColor: colorScheme.surface.withValues(alpha: 0.5),
      builder: (context) => ConversationStarterDialog(profile: profile),
    );
  }
}

class _ConversationStarterDialogState extends State<ConversationStarterDialog> {
  final TextEditingController _messageController = TextEditingController();
  final int _maxLength = 300;

  @override
  void dispose() {
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

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: screenHeight * 0.75,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              ConversationStarterHeader(
                profileName: widget.profile.name,
                onClose: () => Navigator.of(context).pop(),
              ),

              // Profile info
              ConversationStarterProfileInfo(profile: widget.profile),

              const SizedBox(height: 24),

              // Spark Ideas section
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConversationStarterSparkIdeas(
                        profile: widget.profile,
                        onCardTap: (message) {
                          _messageController.text = message;
                          setState(() {});
                        },
                      ),

                      const SizedBox(height: 32),

                      // Custom message input
                      ConversationStarterMessageInput(
                        controller: _messageController,
                        maxLength: _maxLength,
                        onChanged: () => setState(() {}),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Send Spark button
              ConversationStarterSendButton(
                messageController: _messageController,
                onSend: _handleSendSpark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
