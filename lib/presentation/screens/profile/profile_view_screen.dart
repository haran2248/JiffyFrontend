import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:jiffy/core/navigation/navigation_service.dart";
import "package:jiffy/presentation/screens/profile/models/profile_data.dart";
import "package:jiffy/presentation/screens/profile/widgets/profile_main_photo.dart";
import "package:jiffy/presentation/screens/profile/widgets/profile_relationship_preview.dart";
import "package:jiffy/presentation/screens/profile/widgets/profile_additional_photos.dart"
    show ProfileAdditionalPhotos, PhotoWithCaption;
import "package:jiffy/presentation/screens/profile/widgets/profile_bio.dart";
import "package:jiffy/presentation/screens/profile/widgets/profile_personality_section.dart";
import "package:jiffy/presentation/screens/profile/widgets/profile_conversation_style.dart";
import "package:jiffy/presentation/screens/profile/widgets/profile_conversation_starter.dart";
import "package:jiffy/presentation/screens/profile/widgets/profile_sticky_actions.dart";
import "package:jiffy/presentation/screens/profile/widgets/profile_close_button.dart";

/// Profile view screen showing full profile details
class ProfileViewScreen extends ConsumerStatefulWidget {
  final ProfileData profile;

  const ProfileViewScreen({
    super.key,
    required this.profile,
  });

  @override
  ConsumerState<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends ConsumerState<ProfileViewScreen> {
  void _handleClose() {
    context.popRoute();
  }

  void _handleLike() {
    // TODO: Implement like functionality
    _handleClose();
  }

  void _handlePass() {
    // TODO: Implement pass functionality
    _handleClose();
  }

  void _handleSparkConversation() {
    // TODO: Show conversation starter dialog
    _handleLike();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              child: Column(
                children: [
                  // Main Profile Photo
                  ProfileMainPhoto(profile: widget.profile),

                  // Content sections - matching Figma layout
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Relationship Preview
                        ProfileRelationshipPreview(profile: widget.profile),

                        const SizedBox(height: 16),

                        // Additional Photos
                        ProfileAdditionalPhotos(profile: widget.profile),
                      ],
                    ),
                  ),

                  // Bio section - separate section, no cutting
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ProfileBio(profile: widget.profile),
                  ),

                  // Additional Content - matching Figma p-6 space-y-6
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // Interest Photos - using PhotoWithCaption component
                        if (widget.profile.interests.isNotEmpty)
                          Column(
                            children: widget.profile.interests.map((interest) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: PhotoWithCaption(
                                  photoUrl:
                                      "https://images.unsplash.com/photo-1522163182402-834f871fd851?w=400",
                                  caption: interest,
                                ),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 24),

                        // Personality & Values
                        ProfilePersonalitySection(profile: widget.profile),

                        const SizedBox(height: 16),

                        // Conversation Style
                        ProfileConversationStyle(profile: widget.profile),

                        const SizedBox(height: 16),

                        // Conversation Starter
                        ProfileConversationStarter(profile: widget.profile),

                        // Spacer for sticky buttons
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Close button - top right
            ProfileCloseButton(onClose: _handleClose),

            // Sticky Actions - bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ProfileStickyActions(
                onSparkConversation: _handleSparkConversation,
                onPass: _handlePass,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
