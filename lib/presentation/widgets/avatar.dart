import 'dart:io';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final double radius;
  final String? imageUrl;
  final VoidCallback? onTap;

  const Avatar({
    super.key,
    this.radius = 48,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Determine if imageUrl is a local file path or network URL
    ImageProvider? imageProvider;
    if (imageUrl != null) {
      if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
        // Network image
        imageProvider = NetworkImage(imageUrl!);
      } else {
        // Local file path
        final file = File(imageUrl!);
        if (file.existsSync()) {
          imageProvider = FileImage(file);
        }
      }
    }
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: colorScheme.surfaceContainerHighest,
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? Icon(
                  Icons.person_outline,
                  size: radius * 0.8,
                  color: colorScheme.onSurfaceVariant,
                )
              : null,
        ),
      ),
    );
  }
}
