import "package:flutter/material.dart" show debugPrint;
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:jiffy/presentation/screens/profile_curated/models/profile_curated_state.dart";
import "package:jiffy/presentation/screens/profile_curated/models/profile_curated_data.dart";
import "package:jiffy/presentation/screens/onboarding/data/repository/onboarding_repository.dart";
import "package:jiffy/presentation/screens/onboarding/data/models/curated_profile.dart";
import "package:jiffy/core/auth/auth_repository.dart";
import "package:jiffy/core/services/profile_service.dart";

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

  OnboardingRepository get _repository =>
      ref.read(onboardingRepositoryProvider);

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  /// Load curated profile data from backend
  Future<void> loadCuratedProfile() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, error: () => null);

    try {
      debugPrint("ProfileCuratedViewModel: Loading curated profile data...");

      final user = _authRepository.currentUser;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          error: () => "User not authenticated",
        );
        return;
      }

      final uid = user.uid;

      final profileService = ref.read(profileServiceProvider);
      final fetchedData = await profileService.fetchUserProfile(uid);

      if (fetchedData == null) {
        throw Exception("Failed to fetch user profile data");
      }

      String? avatarUrl;
      final photo1 =
          fetchedData.photos.where((p) => p.backendSlot == 1).firstOrNull;
      if (photo1 != null) {
        avatarUrl = photo1.url;
      } else if (fetchedData.photos.isNotEmpty) {
        avatarUrl = fetchedData.photos.first.url;
      }

      final onboardingStatus = fetchedData.onboardingStatus;

      // If onboarding chat was not completed, show placeholder instead of
      // generating from insufficient data.
      if (onboardingStatus != 'COMPLETED') {
        debugPrint(
            "ProfileCuratedViewModel: Onboarding not completed (status: $onboardingStatus), showing placeholder");
        if (!ref.mounted) return;
        state = state.copyWith(
          data: ProfileCuratedData.empty(
            name: fetchedData.name,
            age: fetchedData.age,
            avatarUrl: avatarUrl,
          ).copyWith(gender: fetchedData.gender),
          isLoading: false,
          isIncomplete: true,
        );
        return;
      }

      // Try to get existing curated profile first
      CuratedProfile? curatedProfile = await _repository.getCuratedProfile();

      // If no existing profile, generate one from AI
      if (curatedProfile == null) {
        debugPrint(
            "ProfileCuratedViewModel: No existing profile, generating...");
        curatedProfile = await _repository.generateCuratedProfile();
      }

      // Convert to UI data model
      final profileData = ProfileCuratedData(
        name: fetchedData.name,
        age: fetchedData.age,
        subtitle:
            "Here's what we've learned about you.\nReview and edit to make sure it's perfect.",
        avatarUrl: avatarUrl,
        personalityTraits: curatedProfile.personalityTraits,
        interests: curatedProfile.interests,
        conversationStyleDescription:
            curatedProfile.conversationStyleDescription,
        aboutMe: curatedProfile.aboutMe,
        gender: fetchedData.gender,
      );

      if (!ref.mounted) return;
      state = state.copyWith(data: profileData, isLoading: false);
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

  /// Update personality traits via API
  Future<void> updateTraits(List<String> newTraits) async {
    final currentData = state.data;
    if (currentData == null) return;

    state = state.copyWith(isLoading: true, error: () => null);

    try {
      final updatedProfile = CuratedProfile(
        personalityTraits: newTraits,
        interests: currentData.interests,
        conversationStyleDescription: currentData.conversationStyleDescription,
        aboutMe: currentData.aboutMe,
      );

      await _repository.updateCuratedProfile(updatedProfile);

      // Update local state
      final updatedData = currentData.copyWith(personalityTraits: newTraits);
      if (!ref.mounted) return;
      state = state.copyWith(data: updatedData, isLoading: false);
    } catch (e) {
      debugPrint("ProfileCuratedViewModel: Error updating traits - $e");
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: () => "Failed to update traits. Please try again.",
      );
    }
  }

  /// Update interests via API
  Future<void> updateInterests(List<String> newInterests) async {
    final currentData = state.data;
    if (currentData == null) return;

    state = state.copyWith(isLoading: true, error: () => null);

    try {
      final updatedProfile = CuratedProfile(
        personalityTraits: currentData.personalityTraits,
        interests: newInterests,
        conversationStyleDescription: currentData.conversationStyleDescription,
        aboutMe: currentData.aboutMe,
      );

      await _repository.updateCuratedProfile(updatedProfile);

      // Update local state
      final updatedData = currentData.copyWith(interests: newInterests);
      if (!ref.mounted) return;
      state = state.copyWith(data: updatedData, isLoading: false);
    } catch (e) {
      debugPrint("ProfileCuratedViewModel: Error updating interests - $e");
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: () => "Failed to update interests. Please try again.",
      );
    }
  }

  /// Update conversation style via API
  Future<void> updateConversationStyle(String newDescription) async {
    final currentData = state.data;
    if (currentData == null) return;

    state = state.copyWith(isLoading: true, error: () => null);

    try {
      final updatedProfile = CuratedProfile(
        personalityTraits: currentData.personalityTraits,
        interests: currentData.interests,
        conversationStyleDescription: newDescription,
        aboutMe: currentData.aboutMe,
      );

      await _repository.updateCuratedProfile(updatedProfile);

      // Update local state
      final updatedData =
          currentData.copyWith(conversationStyleDescription: newDescription);
      if (!ref.mounted) return;
      state = state.copyWith(data: updatedData, isLoading: false);
    } catch (e) {
      debugPrint(
          "ProfileCuratedViewModel: Error updating conversation style - $e");
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: () => "Failed to update conversation style. Please try again.",
      );
    }
  }

  /// Finalize the curated profile and navigate to next step
  void onFinalizeProfile() {
    debugPrint("ProfileCuratedViewModel: Finalizing curated profile...");
    // Profile is already saved via API, navigation is handled by the screen
  }
}
