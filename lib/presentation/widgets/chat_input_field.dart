import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/services/service_providers.dart';

class ChatInputField extends ConsumerStatefulWidget {
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
  ConsumerState<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ConsumerState<ChatInputField>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  
  bool _isListeningUI = false;

  // The text that was fully confirmed in previous pauses/sessions
  String _confirmedText = '';

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _hasText = _controller.text.trim().isNotEmpty;
    _controller.addListener(() {
      final hasTextNow = _controller.text.trim().isNotEmpty;
      if (_hasText != hasTextNow) {
        setState(() {
          _hasText = hasTextNow;
        });
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  void _startListening() async {
    final voiceService = ref.read(voiceServiceProvider);
    
    HapticFeedback.selectionClick();
    
    // Set the base text to whatever is currently in the box
    _confirmedText = _controller.text.trim();
    
    final success = await voiceService.startListening(
      onResult: (text, isFinal) {
        if (!mounted || !_isListeningUI) return;

        final newWords = text.trim();
        
        // Build the text from the base text + this current segment
        final full = _confirmedText.isEmpty
            ? newWords
            : '$_confirmedText $newWords';

        _controller.text = full;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
        
        // If this specific utterance is marked final by Deepgram,
        // bake it into confirmed text so the next partials build on top of it.
        if (isFinal && newWords.isNotEmpty) {
          _confirmedText = full.trim();
        }
      },
      onDone: () {
        if (mounted && _isListeningUI) {
          setState(() {
            _isListeningUI = false;
          });
          _pulseController.stop();
        }
      },
    );

    if (success && mounted) {
      setState(() {
        _isListeningUI = true;
      });
      _pulseController.repeat(reverse: true);
    }
  }

  void _stopListening() async {
    HapticFeedback.selectionClick();
    final voiceService = ref.read(voiceServiceProvider);
    await voiceService.stopListening();
    
    if (!mounted) return;
    
    _pulseController.stop();
    setState(() {
      _isListeningUI = false;
    });
  }

  void _toggleListening() {
    if (_isListeningUI) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  @override
  void didUpdateWidget(covariant ChatInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        widget.initialValue != null) {
      _controller.text = widget.initialValue!;
      _hasText = _controller.text.trim().isNotEmpty;
    }
  }

  @override
  void dispose() {
    if (_isListeningUI) {
      ref.read(voiceServiceProvider).stopListening();
    }
    _pulseController.dispose();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleAction() {
    if (!widget.isEnabled) return;

    if (_isListeningUI) {
      _stopListening();
      return;
    }

    if (_hasText) {
      final text = _controller.text.trim();
      if (text.isNotEmpty) {
        HapticFeedback.lightImpact();
        widget.onSend(text);
        _controller.clear();
        _confirmedText = '';
      }
    } else {
      _toggleListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.isEnabled && !_isListeningUI,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                cursorColor: const Color(0xFFD81B60),
                decoration: InputDecoration(
                  hintText: _isListeningUI
                      ? "Listening..."
                      : "Type or tap mic to speak...",
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _isListeningUI
                            ? const Color(0xFFD81B60)
                            : const Color(0xFFB0A8BF),
                      ),
                  filled: true,
                  fillColor: const Color(0xFF2A1B3D),
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
                      color: Color(0xFF8E24AA),
                      width: 1.5,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(
                      color: Color(0xFFD81B60),
                      width: 1.0,
                    ),
                  ),
                ),
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                onSubmitted: (_) {
                  if (_hasText && !_isListeningUI) _handleAction();
                },
              ),
            ),
            const SizedBox(width: 8),
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale =
                    _isListeningUI ? 1.0 + (_pulseController.value * 0.15) : 1.0;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: widget.isEnabled || _isListeningUI
                          ? const LinearGradient(
                              colors: [
                                Color(0xFFD81B60),
                                Color(0xFF8E24AA),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                      color: widget.isEnabled || _isListeningUI
                          ? null
                          : const Color(0xFF2A1B3D).withOpacity(0.5),
                      shape: BoxShape.circle,
                      boxShadow:
                          (widget.isEnabled && _hasText && !_isListeningUI) ||
                                  _isListeningUI
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFD81B60)
                                        .withOpacity(_isListeningUI ? 0.6 : 0.4),
                                    blurRadius: _isListeningUI ? 16 * scale : 12,
                                    offset: _isListeningUI
                                        ? Offset.zero
                                        : const Offset(0, 4),
                                  ),
                                ]
                              : null,
                    ),
                    child: Tooltip(
                      message: _isListeningUI ? 'Stop voice input' : (_hasText ? 'Send message' : 'Start voice input'),
                      child: Semantics(
                        button: true,
                        label: _isListeningUI ? 'Stop voice input' : (_hasText ? 'Send message' : 'Start voice input'),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: (widget.isEnabled || _isListeningUI)
                                ? _handleAction
                                : null,
                            borderRadius: BorderRadius.circular(24),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            _isListeningUI
                                ? Icons.stop_rounded
                                : (_hasText
                                    ? Icons.send_rounded
                                    : Icons.mic_rounded),
                            key: ValueKey('$_hasText-$_isListeningUI'),
                            color: widget.isEnabled || _isListeningUI
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
              },
            ),
          ],
        ),
      ),
    );
  }
}
