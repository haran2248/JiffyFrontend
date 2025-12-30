import "package:flutter/material.dart";

/// Send Spark button at the bottom
class ConversationStarterSendButton extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback onSend;

  const ConversationStarterSendButton({
    super.key,
    required this.messageController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: messageController,
          builder: (context, value, _) {
            final hasMessage = value.text.trim().isNotEmpty;
            return ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Material(
                  color: colorScheme.surface.withValues(alpha: 0),
                  child: InkWell(
                    onTap: hasMessage ? onSend : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: hasMessage
                                ? colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Send Spark",
                            style: textTheme.labelLarge?.copyWith(
                              color: hasMessage
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

