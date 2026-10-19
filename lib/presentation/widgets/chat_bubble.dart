import 'package:flutter/material.dart';
import 'package:jiffy/presentation/screens/chat/chat_constants.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.text,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isMe
              ? LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isMe ? null : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          border: isMe
              ? null
              : Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.1),
                ),
        ),
        child: _buildMessageText(context),
      ),
    );
  }

  Widget _buildMessageText(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isMe
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: isMe ? FontWeight.w600 : FontWeight.normal,
        );

    const recipientPrefix = ChatConstants.storyReplyPrefix;
    const senderPrefix = ChatConstants.storyReplySenderPrefix;

    if (text.startsWith(recipientPrefix) || text.startsWith(senderPrefix)) {
      final actualMessage = text.startsWith(recipientPrefix)
          ? text.substring(recipientPrefix.length)
          : text.substring(senderPrefix.length);

      final displayPrefix =
          isMe ? 'Replied to story:' : 'Replied to your story:';

      return Text.rich(
        TextSpan(
          style: baseStyle,
          children: [
            TextSpan(
              text: '$displayPrefix\n',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            TextSpan(text: actualMessage),
          ],
        ),
        textScaler: MediaQuery.textScalerOf(context),
      );
    }

    return Text(
      text,
      style: baseStyle,
    );
  }
}
