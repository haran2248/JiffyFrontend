import "package:flutter/material.dart";
import "package:jiffy/presentation/screens/profile_self/models/profile_self_data.dart";
import "profile_self_photos_grid.dart";

/// Header card widget for profile self screen.
///
/// Shows main profile photo, name/age/location, secondary photos,
/// edit icons, Preview button, and Manage Photos button.
class ProfileSelfHeaderCard extends StatelessWidget {
  final ProfileSelfData data;
  final VoidCallback? onPreview;
  final VoidCallback? onAddPhoto;
  final void Function(ProfileSelfPhoto)? onEditPhoto;
  final VoidCallback? onEditMainPhoto;

  const ProfileSelfHeaderCard({
    super.key,
    required this.data,
    this.onPreview,
    this.onAddPhoto,
    this.onEditPhoto,
    this.onEditMainPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final primaryPhoto = data.primaryPhoto;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main photo and secondary photos row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main photo
              Expanded(
                flex: 3,
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Stack(
                    children: [
                      // Photo container
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                          ),
                          child: primaryPhoto != null
                              ? Image.network(
                                  primaryPhoto.url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPhotoPlaceholder(
                                        context, colorScheme);
                                  },
                                )
                              : _buildPhotoPlaceholder(context, colorScheme),
                        ),
                      ),
                      // Edit icon on main photo
                      if (onEditMainPhoto != null)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onEditMainPhoto,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Name, age, location overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${data.name}, ${data.age}",
                                style: textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (data.location != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  data.location!,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Secondary photos column
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Secondary photos grid
                    ProfileSelfPhotosGrid(
                      photos: data.secondaryPhotos,
                      onAddPhoto: onAddPhoto,
                      onEditPhoto: onEditPhoto,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Preview Profile button
          if (onPreview != null)
            SizedBox(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPreview,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        "Preview Profile",
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Icon(
        Icons.person,
        size: 64,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
