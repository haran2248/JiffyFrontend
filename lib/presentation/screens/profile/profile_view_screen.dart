import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:jiffy/core/navigation/navigation_service.dart";
import "package:jiffy/core/services/profile_service.dart";
import "package:jiffy/presentation/screens/chat/data/chat_repository.dart";
import "package:jiffy/presentation/screens/matches/data/matches_repository.dart";
import "package:jiffy/core/auth/auth_repository.dart";
import "package:jiffy/core/services/service_providers.dart";
import "package:jiffy/presentation/screens/matches/viewmodels/matches_viewmodel.dart";
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
  bool _isSendingSpark = false;
  late final DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  Future<void> _respondToSuggestion(String action, {String? feedback}) async {
    // Only respond if this is an actual suggestion card (not just viewing own profile or a matched profile)
    if (widget.isPreview) return;

    final timeSpent =
        DateTime.now().difference(_startTime).inMilliseconds / 1000.0;
    try {
      final homeService = ref.read(homeServiceProvider);
      final currentUser = ref.read(authRepositoryProvider).currentUser;

      if (currentUser != null) {
        await homeService.respondToSuggestion(
          currentUserId: currentUser.uid,
          candidateId: widget.profile.userId,
          action: action,
          timeSpentSeconds: timeSpent,
          feedbackText: feedback,
        );
      }
    } catch (e) {
      // Fire and forget; don't break UI if metrics fail
      debugPrint('ProfileViewScreen: Failed to record suggestion response: $e');
    }
  }

  void _handleClose() {
    context.popRoute();
  }

  void _handleLike() {
    // TODO: Implement like functionality
    _handleClose();
  }

  void _handlePass() async {
    // Treat "pass" as a REJECT
    await _respondToSuggestion("REJECT");
    if (mounted) _handleClose();
  }

  void _handleSparkConversation() async {
    try {
      // Fetch conversation starter data from backend
      final profileService = ref.read(profileServiceProvider);
      final conversationData = await profileService
          .fetchConversationStarterData(widget.profile.userId);

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
        if (_isSendingSpark) return;
        setState(() {
          _isSendingSpark = true;
        });

        try {
          final matchesRepository = ref.read(matchesRepositoryProvider);
          final chatRepository = ref.read(chatRepositoryProvider);

          try {
            // First, register the match on the backend so it creates the EventChat
            await matchesRepository.addMatch(widget.profile.userId);
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    const Text('Failed to create match. Please try again.'),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 3),
              ),
            );
            return;
          }

          try {
            // Then, send the actual message to Firestore
            await chatRepository.sendMessage(widget.profile.userId, result);
          } catch (e) {
            // Compensating rollback: if message failed, undo the match
            bool rollbackSucceeded = false;
            try {
              await matchesRepository.removeMatch(widget.profile.userId);
              rollbackSucceeded = true;
            } catch (rollbackError) {
              debugPrint('ProfileViewScreen: Rollback failed: $rollbackError');
            }
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  rollbackSucceeded
                      ? 'Message failed and match was removed. Please try again.'
                      : 'Message failed and rollback failed; match may exist. Please try again.',
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 4),
              ),
            );
            return;
          }

          // Invalidate matches view model to refresh data
          ref.invalidate(matchesViewModelProvider);

          // Trigger a like action if the message was sent successfully
          await _respondToSuggestion("ACCEPT");
          if (mounted) _handleLike();
        } finally {
          if (mounted) {
            setState(() {
              _isSendingSpark = false;
            });
          }
        }
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

    // Bottom sheets often strip the top padding from MediaQuery.
    // We restore the physical device padding here so the internal SafeArea works correctly.
    final mq = MediaQuery.of(context);
    final physicalPadding = MediaQueryData.fromView(View.of(context)).padding;

    return MediaQuery(
        data: mq.copyWith(
          padding: EdgeInsets.only(
            top: physicalPadding.top,
            bottom: mq.padding.bottom,
            left: mq.padding.left,
            right: mq.padding.right,
          ),
        ),
        child: Scaffold(
          backgroundColor: colorScheme.surface,
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
                                  interests: widget.profile.interests,
                                ),
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
                      onSparkConversation:
                          _isSendingSpark ? () {} : _handleSparkConversation,
                      onPass: _handlePass,
                    ),
                  ),
                // Loading overlay for matching
                if (_isSendingSpark)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ));
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
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
