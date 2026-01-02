import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Six OTP input boxes for verification code entry.
///
/// Now functional with actual text input support.
class OtpInputBoxes extends StatefulWidget {
  final int boxCount;
  final ValueChanged<String>? onCompleted;

  const OtpInputBoxes({
    super.key,
    this.boxCount = 4,
    this.onCompleted,
  });

  @override
  State<OtpInputBoxes> createState() => _OtpInputBoxesState();
}

class _OtpInputBoxesState extends State<OtpInputBoxes> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.boxCount, (_) => TextEditingController());
    _focusNodes = List.generate(widget.boxCount, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length == 1 && index < widget.boxCount - 1) {
      // Move to next field
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Move to previous field on backspace
      _focusNodes[index - 1].requestFocus();
    }

    // Check if all fields are filled
    final code = _controllers.map((c) => c.text).join();
    if (code.length == widget.boxCount) {
      widget.onCompleted?.call(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.boxCount, (index) {
        final hasFocus = _focusNodes[index].hasFocus;

        return Container(
          margin: EdgeInsets.only(right: index < widget.boxCount - 1 ? 10 : 0),
          width: 48,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasFocus
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: hasFocus ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            onChanged: (value) => _onChanged(index, value),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        );
      }),
    );
  }
}
