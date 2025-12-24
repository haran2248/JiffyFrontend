import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/core/theme/app_colors.dart';

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
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
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
        border: Border(
          top: BorderSide(
            color: AppColors.surfacePlum.withOpacity(0.3),
            width: 1,
          ),
        ),
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
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: "Type your response...",
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  filled: true,
                  fillColor: AppColors.surfacePlum,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: AppColors.primaryViolet.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: AppColors.primaryViolet,
                      width: 1.5,
                    ),
                  ),
                ),
                onSubmitted: (_) => _handleSend(),
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: widget.isEnabled ? AppColors.primaryGradient : null,
                  color: widget.isEnabled
                      ? null
                      : AppColors.surfacePlum.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: widget.isEnabled
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
