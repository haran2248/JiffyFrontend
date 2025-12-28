import "package:flutter/material.dart";

/// Close button for profile view (top right)
class ProfileCloseButton extends StatelessWidget {
  final VoidCallback onClose;

  const ProfileCloseButton({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      top: 8,
      right: 8,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onClose,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close,
              color: colorScheme.onSurface,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

