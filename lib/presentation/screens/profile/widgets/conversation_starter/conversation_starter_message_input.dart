import "package:flutter/material.dart";

/// Custom message input section
class ConversationStarterMessageInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final int maxLength;
  final VoidCallback onChanged;

  const ConversationStarterMessageInput({
    super.key,
    required this.controller,
    this.focusNode,
    required this.maxLength,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Or type your own opening line...",
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLength: maxLength,
                maxLines: 4,
                minLines: 2,
                scrollPadding: const EdgeInsets.only(bottom: 100),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: "Type your message here...",
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  counterStyle: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onChanged: (_) => onChanged(),
              ),
            ),
          ],
        );
      },
    );
  }
}

