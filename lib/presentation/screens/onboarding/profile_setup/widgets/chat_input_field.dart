import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatInputField extends StatefulWidget {
  final String? initialValue;
  final Function(String) onSend;
  final bool isEnabled;

  const ChatInputField({
    super.key,
    this.initialValue,
    required this.onSend,
    this.isEnabled = true,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant ChatInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && widget.isEnabled) {
      HapticFeedback.lightImpact();
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        // Removed top border for cleaner look
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.isEnabled,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white, // AppColors.textPrimary
                    ),
                cursorColor:
                    const Color(0xFFD81B60), // AppColors.primaryRaspberry
                decoration: InputDecoration(
                  hintText: "Type your response...",
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            const Color(0xFFB0A8BF), // AppColors.textSecondary
                      ),
                  filled: true,
                  fillColor: const Color(0xFF2A1B3D), // AppColors.surfacePlum
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(
                      color: Color(0xFF8E24AA), // AppColors.primaryViolet
                      width: 1.5,
                    ),
                  ),
                ),
                onSubmitted: (_) => _handleSend(),
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: widget.isEnabled
                    ? const LinearGradient(
                        colors: [
                          Color(0xFFD81B60), // AppColors.primaryRaspberry
                          Color(0xFF8E24AA), // AppColors.primaryViolet
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: widget.isEnabled
                    ? null
                    : const Color(0xFF2A1B3D)
                        .withOpacity(0.5), // AppColors.surfacePlum
                shape: BoxShape.circle,
                boxShadow: widget.isEnabled
                    ? [
                        BoxShadow(
                          color: const Color(0xFF8E24AA).withOpacity(0.4),
                          blurRadius: 12, // Increased blur for softer glow
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isEnabled ? _handleSend : null,
                  borderRadius: BorderRadius.circular(24),
                  child: Icon(
                    Icons.send_rounded,
                    color: widget.isEnabled
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
