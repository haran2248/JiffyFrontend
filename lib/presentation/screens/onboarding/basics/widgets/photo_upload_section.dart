import 'package:flutter/material.dart';
import '../../../../widgets/avatar.dart';

class PhotoUploadSection extends StatelessWidget {
  final VoidCallback? onTap;
  final String? imageUrl;

  const PhotoUploadSection({
    super.key,
    this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Avatar(
            radius: 80,
            imageUrl: imageUrl,
            onTap: onTap,
          ),
          const SizedBox(height: 24),
          Text(
            "Add your photo to get started",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onTap,
            child: Text(
              "Change Photo",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
