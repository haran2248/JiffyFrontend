import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:jiffy/core/navigation/navigation_service.dart";
import "package:jiffy/core/services/profile_service.dart";
import "package:jiffy/presentation/screens/profile/models/profile_data.dart";
import "package:jiffy/presentation/screens/profile/widgets/profile_main_photo.dart";
import "package:jiffy/presentation/screens/profile/widgets/profile_relationship_preview.dart";
import "package:jiffy/presentation/screens/profile/widgets/profile_additional_photos.dart"
    show PhotoWithCaption;
import "package:jiffy/presentation/screens/profile/widgets/profile_bio.dart";
import "package:jiffy/presentation/screens/profile/widgets/profile_personality_section.dart";
import "package:jiffy/presentation/screens/profile/widgets/profile_conversation_style.dart";
import "package:jiffy/presentation/screens/profile/widgets/profile_conversation_starter.dart";
import "package:jiffy/presentation/screens/profile/widgets/profile_sticky_actions.dart";
import "package:jiffy/presentation/screens/profile/widgets/profile_close_button.dart";
import "package:jiffy/presentation/screens/profile/widgets/conversation_starter/conversation_starter_dialog.dart";

/// Profile view screen showing full profile details
class ProfileViewScreen extends ConsumerStatefulWidget {
  final ProfileData profile;
  final bool isPreview;

  const ProfileViewScreen({
    super.key,
    required this.profile,
    this.isPreview = false,
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

  void _handleSparkConversation() async {
    try {
      // Fetch conversation starter data from backend
      final profileService = ref.read(profileServiceProvider);
      final conversationData =
          await profileService.fetchConversationStarterData(
        widget.profile.userId,
      );

      // Check if widget is still mounted before using context
      if (!mounted) return;

      // Show conversation starter dialog
      final result = await ConversationStarterDialog.show(
        context,
        widget.profile,
        conversationData,
      );

      // Check again after async operation
      if (!mounted) return;

      // If user sent a message, proceed with like
      if (result != null && result.isNotEmpty) {
        // TODO: Send the spark message to backend
        _handleLike();
      }
    } catch (e) {
      // Check if widget is still mounted before using context
      if (!mounted) return;

      // Show error feedback to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to load conversation starters. Please try again.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
                  const SizedBox(height: 16),

                  // Main Profile Photo
                  ProfileMainPhoto(profile: widget.profile),

                  const SizedBox(height: 16),

                  // Content sections - Interleaved with photos
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Relationship Preview
                        ProfileRelationshipPreview(profile: widget.profile),

                        const SizedBox(height: 16),

                        // 2. Bio
                        ProfileBio(profile: widget.profile),

                        const SizedBox(height: 24),

                        // 3. Second Photo (if available)
                        // Photos array: [0] = primary (displayed above), [1] = second, [2] = third, [3] = fourth
                        if (widget.profile.photos.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: PhotoWithCaption(
                              photoUrl: widget.profile.photos[1].url,
                              caption: widget.profile.photos[1].caption,
                            ),
                          ),

                        // 4. Personality & Values
                        ProfilePersonalitySection(profile: widget.profile),

                        const SizedBox(height: 24),

                        // 5. Third Photo (if available)
                        if (widget.profile.photos.length > 2)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: PhotoWithCaption(
                              photoUrl: widget.profile.photos[2].url,
                              caption: widget.profile.photos[2].caption,
                            ),
                          ),

                        // 6. Conversation Style
                        ProfileConversationStyle(profile: widget.profile),

                        const SizedBox(height: 24),

                        // 7. Fourth Photo (if available)
                        if (widget.profile.photos.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: PhotoWithCaption(
                              photoUrl: widget.profile.photos[3].url,
                              caption: widget.profile.photos[3].caption,
                            ),
                          ),

                        // 8. Interests
                        if (widget.profile.interests.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: _ProfileInterestsSection(
                                interests: widget.profile.interests),
                          ),

                        // 9. Conversation Starter
                        ProfileConversationStarter(profile: widget.profile),

                        // Spacer for sticky buttons (or safe area)
                        SizedBox(height: widget.isPreview ? 24 : 120),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Close button - top right
            ProfileCloseButton(onClose: _handleClose),

            // Sticky Actions - bottom (only if not preview)
            if (!widget.isPreview)
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

class _ProfileInterestsSection extends StatelessWidget {
  final List<String> interests;

  const _ProfileInterestsSection({required this.interests});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.15),
            colorScheme.secondary.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.interests_outlined,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                "Interests",
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.map((interest) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  interest,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
