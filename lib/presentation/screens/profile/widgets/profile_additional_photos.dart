import "package:flutter/material.dart";
import "package:jiffy/presentation/screens/profile/models/profile_data.dart";

/// Additional photos section with optional captions
class ProfileAdditionalPhotos extends StatelessWidget {
  final ProfileData profile;

  const ProfileAdditionalPhotos({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    if (profile.photos.length <= 1) {
      return const SizedBox.shrink();
    }

    final additionalPhotos = profile.photos.skip(1).take(3).toList();

    return Column(
      children: additionalPhotos.map((photo) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PhotoWithCaption(
            photoUrl: photo.url,
            caption: photo.caption,
          ),
        );
      }).toList(),
    );
  }
}

/// Photo with optional caption overlay
class PhotoWithCaption extends StatelessWidget {
  final String photoUrl;
  final String? caption;

  const PhotoWithCaption({
    super.key,
    required this.photoUrl,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        Icons.person,
                        size: 80,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
              // Caption overlay if caption exists
              if (caption != null && caption!.isNotEmpty)
                PhotoCaptionOverlay(caption: caption!),
            ],
          ),
        ),
      ),
    );
  }
}

/// Caption overlay component
class PhotoCaptionOverlay extends StatelessWidget {
  final String caption;

  const PhotoCaptionOverlay({
    super.key,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: screenWidth * 0.8,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            caption,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
