import 'package:flutter/material.dart';
import '../../../../widgets/input.dart';
import 'photo_upload_section.dart';

class NamePhotoStep extends StatelessWidget {
  final String? firstName;
  final ValueChanged<String?>? onFirstNameChanged;
  final VoidCallback? onPhotoTap;

  const NamePhotoStep({
    super.key,
    this.firstName,
    this.onFirstNameChanged,
    this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PhotoUploadSection(onTap: onPhotoTap),
        const SizedBox(height: 48),
        ThemedInput(
          label: "First Name",
          placeholder: "Jane",
          initialValue: firstName,
          onChanged: onFirstNameChanged,
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
