import 'package:flutter/material.dart';

/// Full-screen modal that slides up when the user selects "Other" as a reason.
/// Returns the typed text as a [String] on confirm, or null on cancel/back.
class OtherReasonScreen extends StatefulWidget {
  final String hint;

  const OtherReasonScreen({super.key, required this.hint});

  static Future<String?> show(BuildContext context, {String hint = 'Tell us more…'}) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => OtherReasonScreen(hint: hint),
      ),
    );
  }

  @override
  State<OtherReasonScreen> createState() => _OtherReasonScreenState();
}

class _OtherReasonScreenState extends State<OtherReasonScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      Navigator.of(context).pop(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // Let Scaffold handle keyboard resizing — button lives in bottomNavigationBar
      resizeToAvoidBottomInset: true,
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Your reason',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      // Button pinned above keyboard — no Spacer needed
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(
          24,
          12,
          24,
          24,
        ),
        child: AnimatedOpacity(
          opacity: _controller.text.trim().isNotEmpty ? 1.0 : 0.45,
          duration: const Duration(milliseconds: 200),
          child: FilledButton(
            onPressed: _controller.text.trim().isNotEmpty ? _handleConfirm : null,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Confirm',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.hint,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 6,
              minLines: 4,
              maxLength: 200,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Describe your reason…',
                hintStyle: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: colorScheme.onSurface.withValues(alpha: 0.05),
                counterStyle: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.secondary.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.secondary,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.secondary.withValues(alpha: 0.3),
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
