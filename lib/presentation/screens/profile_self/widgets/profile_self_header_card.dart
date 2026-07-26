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
          // Name and Location Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${data.name}, ${data.age}",
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (data.location != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      data.location!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
              // Edit Icon for basic details (if needed)
              IconButton(
                onPressed: () {}, // TODO: Edit basic info handler
                icon: Icon(
                  Icons.edit_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Main photo and secondary photos row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main photo
              Expanded(
                flex: 2,
                child: AspectRatio(
                  aspectRatio: 2.2 / 3.5,
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
                      // Edit icon on main photo (bottom right now)
                      if (onEditMainPhoto != null)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onEditMainPhoto,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface.withValues(alpha: 0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                              ),
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
          // Manage all photos text
          Center(
            child: TextButton(
              onPressed: () {}, // TODO: handle manage photos
              child: Text(
                "Manage all photos",
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // PROFILE STRENGTH
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "PROFILE STRENGTH",
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Strong",
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.8, // Example value
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 24),
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
