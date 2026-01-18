import 'package:flutter/material.dart';

/// A dialog for editing a text description (like conversation style).
class EditTextDialog extends StatefulWidget {
  final String title;
  final String text;
  final String hintText;
  final int maxLength;
  final int minLength;
  final int maxLines;

  const EditTextDialog({
    super.key,
    required this.title,
    required this.text,
    this.hintText = 'Enter description...',
    this.maxLength = 500,
    this.minLength = 10,
    this.maxLines = 6,
  });

  /// Shows the dialog and returns the updated text, or null if cancelled.
  static Future<String?> show({
    required BuildContext context,
    required String title,
    required String text,
    String hintText = 'Enter description...',
    int maxLength = 500,
    int minLength = 10,
    int maxLines = 6,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => EditTextDialog(
        title: title,
        text: text,
        hintText: hintText,
        maxLength: maxLength,
        minLength: minLength,
        maxLines: maxLines,
      ),
    );
  }

  @override
  State<EditTextDialog> createState() => _EditTextDialogState();
}

class _EditTextDialogState extends State<EditTextDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid {
    final text = _controller.text.trim();
    return text.length >= widget.minLength && text.length <= widget.maxLength;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        widget.title,
        style: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Minimum ${widget.minLength} characters',
              style: textTheme.bodySmall?.copyWith(
                color: _controller.text.trim().length < widget.minLength
                    ? colorScheme.error
                    : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        FilledButton(
          onPressed: _isValid
              ? () => Navigator.of(context).pop(_controller.text.trim())
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
