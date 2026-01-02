import "package:flutter/material.dart" show debugPrint;
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:jiffy/presentation/screens/profile_curated/models/profile_curated_state.dart";
import "package:jiffy/presentation/screens/profile_curated/models/profile_curated_data.dart";

part "profile_curated_viewmodel.g.dart";

/// ViewModel for the Profile Curated (Review & Finalize) screen.
///
/// Manages loading, error handling, and state for reviewing the curated profile
/// before finalizing during onboarding.
@riverpod
class ProfileCuratedViewModel extends _$ProfileCuratedViewModel {
  @override
  ProfileCuratedState build() {
    // Load data on initialization after build completes
    Future.microtask(() => loadCuratedProfile());
    return const ProfileCuratedState(isLoading: true);
  }

  /// Load curated profile data from backend
  Future<void> loadCuratedProfile() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, error: () => null);

    try {
      // TODO: Replace with actual API call via repository
      // Example: final data = await ref.read(profileRepositoryProvider).getCuratedProfile();
      debugPrint("ProfileCuratedViewModel: Loading curated profile data...");

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data matching the design mockup
      const mockData = ProfileCuratedData(
        name: "kn",
        age: 90,
        subtitle: "Here's what makes you unique and it's perfect.",
        avatarUrl: null, // No avatar, shows placeholder
        personalityTraits: ["Creative", "Adventurous", "Humorous"],
        interests: [
          "Indie Music",
          "Photography",
          "Hiking",
          "Baking",
          "Sci-Fi Flicks"
        ],
        conversationStyleDescription:
            "You enjoy witty banter and deep conversations, often using humor and empathy to connect with others. You're a thoughtful listener with quick, insightful responses.",
      );

      if (!ref.mounted) return;
      state = state.copyWith(data: mockData, isLoading: false);
    } catch (e) {
      debugPrint("ProfileCuratedViewModel: Error loading profile - $e");
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: () => "Failed to load your curated profile. Please try again.",
      );
    }
  }

  /// Refresh curated profile data
  Future<void> refresh() async {
    await loadCuratedProfile();
  }

  /// Navigate to edit personality traits
  void onEditTraits() {
    // TODO: Navigate to traits edit screen
    debugPrint("ProfileCuratedViewModel: Navigate to edit personality traits");
  }

  /// Navigate to edit interests
  void onEditInterests() {
    // TODO: Navigate to interests edit screen
    debugPrint("ProfileCuratedViewModel: Navigate to edit interests");
  }

  /// Navigate to edit conversation style
  void onEditConversationStyle() {
    // TODO: Navigate to conversation style edit screen
    debugPrint("ProfileCuratedViewModel: Navigate to edit conversation style");
  }

  /// Finalize the curated profile and navigate to next step
  void onFinalizeProfile() {
    // TODO: Call API to finalize profile, then navigate to home
    debugPrint("ProfileCuratedViewModel: Finalizing curated profile...");
    // Example navigation: context.goToRoute(AppRoutes.home);
  }
}
