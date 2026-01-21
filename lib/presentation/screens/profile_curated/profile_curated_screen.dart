import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:jiffy/core/navigation/navigation_service.dart";
import "package:jiffy/core/navigation/app_routes.dart";
import "package:jiffy/presentation/screens/profile_curated/models/profile_curated_state.dart";
import "package:jiffy/presentation/screens/profile_curated/viewmodels/profile_curated_viewmodel.dart";
import "package:jiffy/presentation/screens/profile_curated/widgets/curated_profile_header.dart";
import "package:jiffy/presentation/screens/profile_curated/widgets/curated_traits_section.dart";
import "package:jiffy/presentation/screens/profile_curated/widgets/curated_interests_section.dart";
import "package:jiffy/presentation/screens/profile_curated/widgets/curated_conversation_style_section.dart";
import "package:jiffy/presentation/screens/profile_curated/widgets/finalize_profile_button.dart";
import "package:jiffy/presentation/widgets/edit_list_dialog.dart";
import "package:jiffy/presentation/widgets/edit_text_dialog.dart";

/// Profile Curated Screen (Review & Finalize)
///
/// Displays the user's curated profile for review before finalizing.
/// Part of the onboarding confirmation flow.
class ProfileCuratedScreen extends ConsumerWidget {
  const ProfileCuratedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(profileCuratedViewModelProvider);
    final viewModel = ref.read(profileCuratedViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface,
          ),
          onPressed: () => context.popRoute(),
        ),
        title: Text(
          "Your Curated Profile",
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(context, state, viewModel),
      bottomNavigationBar: state.hasData
          ? FinalizeProfileButton(
              onTap: () {
                viewModel.onFinalizeProfile();
                // Navigate to home screen after finalizing profile
                context.goToRoute(AppRoutes.home);
              },
              isLoading: state.isLoading,
            )
          : null,
    );
  }

  Future<void> _showEditTraitsDialog(
    BuildContext context,
    ProfileCuratedViewModel viewModel,
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
    ProfileCuratedViewModel viewModel,
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
    ProfileCuratedViewModel viewModel,
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
    ProfileCuratedState state,
    ProfileCuratedViewModel viewModel,
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
                      horizontal: 24,
                      vertical: 12,
                    ),
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
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Header
              CuratedProfileHeader(
                name: data.name,
                age: data.age,
                subtitle: data.subtitle,
                avatarUrl: data.avatarUrl,
              ),
              const SizedBox(height: 32),
              // Personality Traits Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CuratedTraitsSection(
                  traits: data.personalityTraits,
                  onEdit: () => _showEditTraitsDialog(
                    context,
                    viewModel,
                    data.personalityTraits,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Interests Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CuratedInterestsSection(
                  interests: data.interests,
                  onEdit: () => _showEditInterestsDialog(
                    context,
                    viewModel,
                    data.interests,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Conversation Style Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CuratedConversationStyleSection(
                  description: data.conversationStyleDescription,
                  onEdit: () => _showEditConversationStyleDialog(
                    context,
                    viewModel,
                    data.conversationStyleDescription,
                  ),
                ),
              ),
              // Bottom padding for safe area
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
