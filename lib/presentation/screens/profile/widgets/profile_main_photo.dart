import "package:flutter/material.dart";
import "package:jiffy/presentation/screens/profile/models/profile_data.dart";

/// Main profile photo with name and location overlay
class ProfileMainPhoto extends StatelessWidget {
  final ProfileData profile;

  const ProfileMainPhoto({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasPhoto = profile.photos.isNotEmpty;
    final photo = hasPhoto ? profile.photos[0] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Photo container
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  child: hasPhoto && photo != null
                      ? Image.network(
                          photo.url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPhotoPlaceholder(context, colorScheme);
                          },
                        )
                      : _buildPhotoPlaceholder(context, colorScheme),
                ),

                // Name & Location Overlay - Bottom (gradient only on photo, not extending beyond)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${profile.name}, ${profile.age}",
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (profile.location != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            profile.location!,
                            style: textTheme.bodyMedium?.copyWith(
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
      ),
    );
  }

  Widget _buildPhotoPlaceholder(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Icon(
        Icons.person,
        size: 80,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
