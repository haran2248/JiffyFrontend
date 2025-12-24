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

  bool get _hasValidImageUrl {
    return imageUrl != null && imageUrl!.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: colorScheme.surface,
        child: _hasValidImageUrl
            ? ClipOval(
                child: Image.network(
                  imageUrl!,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.camera_alt_outlined,
                      size: radius * 0.8,
                      color: colorScheme.onSurface,
                    );
                  },
                ),
              )
            : Icon(
                Icons.camera_alt_outlined,
                size: radius * 0.8,
                color: colorScheme.onSurface,
              ),
      ),
    );
  }
}
