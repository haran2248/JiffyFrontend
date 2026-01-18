import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:jiffy/core/navigation/app_routes.dart";
import "package:jiffy/presentation/screens/profile_self/models/profile_self_state.dart";
import "package:jiffy/presentation/screens/profile_self/viewmodels/profile_self_viewmodel.dart";
import "package:jiffy/presentation/screens/profile_self/widgets/profile_self_header_card.dart";
import "package:jiffy/presentation/screens/profile_self/widgets/profile_self_about_me.dart";
import "package:jiffy/presentation/screens/profile_self/widgets/profile_self_interests.dart";
import "package:jiffy/presentation/screens/profile_self/widgets/profile_self_conversation_style.dart";
import "package:jiffy/presentation/widgets/bottom_navigation_bar.dart";
import "package:jiffy/presentation/widgets/edit_list_dialog.dart";
import "package:jiffy/presentation/widgets/edit_text_dialog.dart";

/// Profile Self Screen (Editable View)
///
/// Displays the logged-in user's own profile in an editable view.
/// Allows editing photos, about me, interests, and conversation style.
class ProfileSelfScreen extends ConsumerWidget {
  const ProfileSelfScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(profileSelfViewModelProvider);
    final viewModel = ref.read(profileSelfViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove default back button
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Profile",
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "(Editable View)",
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        actions: [
          // Preview button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: viewModel.onPreviewProfile,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "Preview",
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(context, state, viewModel),
      bottomNavigationBar: const BottomNavigationBarWidget(
        currentRoute: AppRoutes.profileSelf,
      ),
    );
  }

  Future<void> _showEditTraitsDialog(
    BuildContext context,
    ProfileSelfViewModel viewModel,
    List<String> currentTraits,
  ) async {
    final result = await EditListDialog.show(
      context: context,
      title: 'Edit Personality Traits',
      items: currentTraits,
      addHintText: 'Add a trait (e.g., Adventurous)',
      maxItems: 5,
      minItems: 1,
    );
    if (result != null) {
      await viewModel.updateTraits(result);
    }
  }

  Future<void> _showEditInterestsDialog(
    BuildContext context,
    ProfileSelfViewModel viewModel,
    List<String> currentInterests,
  ) async {
    final result = await EditListDialog.show(
      context: context,
      title: 'Edit Interests',
      items: currentInterests,
      addHintText: 'Add an interest (e.g., Hiking)',
      maxItems: 8,
      minItems: 1,
    );
    if (result != null) {
      await viewModel.updateInterests(result);
    }
  }

  Future<void> _showEditConversationStyleDialog(
    BuildContext context,
    ProfileSelfViewModel viewModel,
    String currentDescription,
  ) async {
    final result = await EditTextDialog.show(
      context: context,
      title: 'Edit Conversation Style',
      text: currentDescription,
      hintText: 'Describe your conversation style...',
      maxLength: 500,
      minLength: 20,
    );
    if (result != null) {
      await viewModel.updateConversationStyle(result);
    }
  }

  Widget _buildBody(
    BuildContext context,
    ProfileSelfState state,
    ProfileSelfViewModel viewModel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Loading state
    if (state.isLoading && state.data == null) {
      return Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      );
    }

    // Error state
    if (state.hasError && state.data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                state.error ?? "An error occurred",
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: viewModel.refresh,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      "Retry",
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Data state
    final data = state.data;
    if (data == null) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      color: colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card with photos
              ProfileSelfHeaderCard(
                data: data,
                onPreview: null,
                onManagePhotos: null,
                onEditMainPhoto: null,
              ),
              const SizedBox(height: 24),
              // Personality Traits section (from curated profile)
              if (data.personalityTraits.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ProfileSelfInterests(
                    interests: data.personalityTraits,
                    onEdit: () => _showEditTraitsDialog(
                      context,
                      viewModel,
                      data.personalityTraits,
                    ),
                    title: "Personality Traits",
                  ),
                ),
              if (data.personalityTraits.isNotEmpty) const SizedBox(height: 16),
              // About Me section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ProfileSelfAboutMe(
                  aboutMeText: data.aboutMe,
                  onEdit: null,
                  onBeginnerEdit: null,
                ),
              ),
              const SizedBox(height: 16),
              // Interests section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ProfileSelfInterests(
                  interests: data.interests,
                  onEdit: () => _showEditInterestsDialog(
                    context,
                    viewModel,
                    data.interests,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Conversation Style section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ProfileSelfConversationStyle(
                  title: data.conversationStyleTitle,
                  description: data.conversationStyleDescription,
                  onEdit: () => _showEditConversationStyleDialog(
                    context,
                    viewModel,
                    data.conversationStyleDescription,
                  ),
                  onReviewPromptAnswers: null,
                ),
              ),
              // Bottom padding for safe area
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
