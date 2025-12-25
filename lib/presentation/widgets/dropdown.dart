import 'package:flutter/material.dart';

class Dropdown<T> extends StatefulWidget {
  final String label;
  final String? placeholder;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  const Dropdown({
    super.key,
    required this.label,
    required this.items,
    this.placeholder,
    this.value,
    this.onChanged,
    this.validator,
  });

  @override
  State<Dropdown<T>> createState() => _DropdownState<T>();
}

class _DropdownState<T> extends State<Dropdown<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          // Using value (not initialValue) to create a controlled component
          // that updates when external value changes (e.g., form resets)
          // ignore: deprecated_member_use
          value: widget.value,
          items: widget.items,
          onChanged: widget.onChanged,
          validator: widget.validator,
          isExpanded: true,
          menuMaxHeight: 300,
          style: Theme.of(context).textTheme.bodyLarge,
          dropdownColor: Theme.of(context).colorScheme.surface,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
