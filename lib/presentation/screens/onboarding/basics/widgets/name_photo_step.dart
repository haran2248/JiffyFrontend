import 'package:flutter/material.dart';
import '../../../../widgets/input.dart';
import 'photo_upload_section.dart';

class NamePhotoStep extends StatefulWidget {
  final String? firstName;
  final String? photoUrl;
  final ValueChanged<String?>? onFirstNameChanged;
  final VoidCallback? onPhotoTap;

  const NamePhotoStep({
    super.key,
    this.firstName,
    this.photoUrl,
    this.onFirstNameChanged,
    this.onPhotoTap,
  });

  @override
  State<NamePhotoStep> createState() => _NamePhotoStepState();
}

class _NamePhotoStepState extends State<NamePhotoStep> {
  late final TextEditingController _controller;
  String? _prepopulatedName;

  @override
  void initState() {
    super.initState();
    _prepopulatedName = widget.firstName;
    _controller = TextEditingController(text: widget.firstName ?? '');
  }

  @override
  void didUpdateWidget(covariant NamePhotoStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((_prepopulatedName == null || _prepopulatedName!.isEmpty) &&
        widget.firstName != null &&
        widget.firstName!.isNotEmpty) {
      _prepopulatedName = widget.firstName;
    }
    // Pre-populate if text is currently empty and a name becomes available
    if (_controller.text.isEmpty &&
        widget.firstName != null &&
        widget.firstName!.isNotEmpty &&
        oldWidget.firstName != widget.firstName) {
      _controller.text = widget.firstName!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String placeholder =
        (_prepopulatedName != null && _prepopulatedName!.isNotEmpty)
            ? _prepopulatedName!
            : (widget.firstName != null && widget.firstName!.isNotEmpty)
                ? widget.firstName!
                : "Jane";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PhotoUploadSection(
          imageUrl: widget.photoUrl,
          onTap: widget.onPhotoTap,
        ),
        const SizedBox(height: 48),
        ThemedInput(
          label: "First Name",
          placeholder: placeholder,
          controller: _controller,
          onChanged: widget.onFirstNameChanged,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            "This is how it will appear on your profile",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}
