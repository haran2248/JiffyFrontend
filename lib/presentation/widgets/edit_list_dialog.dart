import 'package:flutter/material.dart';

/// A dialog for editing a list of items (traits or interests).
///
/// Shows a text field to add new items and displays existing items as chips
/// that can be removed.
class EditListDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final String addHintText;
  final int maxItems;
  final int minItems;

  const EditListDialog({
    super.key,
    required this.title,
    required this.items,
    this.addHintText = 'Add new item',
    this.maxItems = 8,
    this.minItems = 1,
  });

  /// Shows the dialog and returns the updated list, or null if cancelled.
  static Future<List<String>?> show({
    required BuildContext context,
    required String title,
    required List<String> items,
    String addHintText = 'Add new item',
    int maxItems = 8,
    int minItems = 1,
  }) {
    return showDialog<List<String>>(
      context: context,
      builder: (context) => EditListDialog(
        title: title,
        items: items,
        addHintText: addHintText,
        maxItems: maxItems,
        minItems: minItems,
      ),
    );
  }

  @override
  State<EditListDialog> createState() => _EditListDialogState();
}

class _EditListDialogState extends State<EditListDialog> {
  late List<String> _items;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (_items.length >= widget.maxItems) return;
    if (_items.contains(text)) return;

    setState(() {
      _items.add(text);
      _controller.clear();
    });
    _focusNode.requestFocus();
  }

  void _removeItem(String item) {
    if (_items.length <= widget.minItems) return;
    setState(() {
      _items.remove(item);
    });
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
            // Add new item field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: widget.addHintText,
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _items.length < widget.maxItems ? _addItem : null,
                  icon: Icon(
                    Icons.add_circle,
                    color: _items.length < widget.maxItems
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_items.length}/${widget.maxItems} items',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            // Current items as chips
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _items.map((item) {
                    return Chip(
                      label: Text(
                        item,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                      backgroundColor: colorScheme.secondaryContainer,
                      deleteIcon: Icon(
                        Icons.close,
                        size: 18,
                        color: _items.length > widget.minItems
                            ? colorScheme.onSecondaryContainer
                            : colorScheme.onSecondaryContainer
                                .withValues(alpha: 0.3),
                      ),
                      onDeleted: _items.length > widget.minItems
                          ? () => _removeItem(item)
                          : null,
                    );
                  }).toList(),
                ),
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
          onPressed: _items.length >= widget.minItems
              ? () => Navigator.of(context).pop(_items)
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
