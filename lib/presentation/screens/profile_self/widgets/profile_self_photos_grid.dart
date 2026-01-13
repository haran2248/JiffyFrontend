import "package:flutter/material.dart";
import "package:jiffy/presentation/screens/profile_self/models/profile_self_data.dart";

/// Photos grid widget showing existing photos and add photo slot.
///
/// Displays photos horizontally with edit icons and an empty add slot.
class ProfileSelfPhotosGrid extends StatelessWidget {
  final List<ProfileSelfPhoto> photos;
  final VoidCallback? onAddPhoto;
  final void Function(ProfileSelfPhoto photo)? onEditPhoto;

  const ProfileSelfPhotosGrid({
    super.key,
    required this.photos,
    this.onAddPhoto,
    this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Secondary photos (stacked vertically)
        ...photos.take(1).map(
              (photo) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PhotoThumbnail(
                  photo: photo,
                  onEdit:
                      onEditPhoto != null ? () => onEditPhoto!(photo) : null,
                ),
              ),
            ),
        // Add photo slot
        if (onAddPhoto != null) _AddPhotoSlot(onTap: onAddPhoto),
      ],
    );
  }
}

/// Photo thumbnail with edit icon overlay
class _PhotoThumbnail extends StatelessWidget {
  final ProfileSelfPhoto photo;
  final VoidCallback? onEdit;

  const _PhotoThumbnail({
    required this.photo,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 80,
      height: 100,
      child: Stack(
        children: [
          // Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              photo.url,
              width: 80,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.image,
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          // Edit icon overlay
          if (onEdit != null)
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Empty slot for adding a new photo
class _AddPhotoSlot extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddPhotoSlot({this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 80,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
            child: Center(
              child: Icon(
                Icons.add,
                size: 32,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for dashed border effect
class _DashedBorderPainter extends CustomPainter {
  final Color color;

  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Dashed border is already handled by the Container border
    // This painter is kept for potential future dashed pattern
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
