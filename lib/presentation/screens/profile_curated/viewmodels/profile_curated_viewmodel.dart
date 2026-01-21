import "package:flutter/material.dart" show debugPrint;
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:jiffy/presentation/screens/profile_curated/models/profile_curated_state.dart";
import "package:jiffy/presentation/screens/profile_curated/models/profile_curated_data.dart";
import "package:jiffy/presentation/screens/onboarding/data/repository/onboarding_repository.dart";
import "package:jiffy/presentation/screens/onboarding/data/models/curated_profile.dart";
import "package:jiffy/core/auth/auth_repository.dart";
import "package:dio/dio.dart";
import "package:jiffy/core/network/dio_provider.dart";

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

  Dio get _dio => ref.read(dioProvider);

  /// Calculate age from date of birth string (format: "YYYY-MM-DD" or similar)
  int _calculateAge(String? dobString) {
    if (dobString == null || dobString.isEmpty) return 0;
    try {
      final dob = DateTime.parse(dobString);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age;
    } catch (e) {
      debugPrint("ProfileCuratedViewModel: Error parsing DOB: $e");
      return 0;
    }
  }

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

      // Fetch user basic info
      String name = "You";
      int age = 0;
      String? avatarUrl;

      try {
        final userResponse = await _dio.get(
          '/api/users/getUser',
          queryParameters: {'uid': uid},
        );

        final userData = userResponse.data as Map<String, dynamic>?;
        if (userData != null) {
          // Get name from basicDetails or root
          final basicDetails =
              userData['basicDetails'] as Map<String, dynamic>?;
          name = basicDetails?['name'] as String? ??
              userData['name'] as String? ??
              "You";

          // Calculate age from DOB
          final dobString = basicDetails?['birthDate'] as String?;
          age = _calculateAge(dobString);

          // Get first photo URL from imageIds
          final imageIds = userData['imageIds'] as List<dynamic>?;
          if (imageIds != null && imageIds.isNotEmpty) {
            final firstImageId = imageIds[0] as String;
            avatarUrl =
                'https://jiffystorebucket.s3.ap-south-1.amazonaws.com/$firstImageId';
          }

          debugPrint(
              "ProfileCuratedViewModel: Loaded user - name: $name, age: $age, hasPhoto: ${avatarUrl != null}");
        }
      } catch (e) {
        debugPrint("ProfileCuratedViewModel: Error fetching user data: $e");
        rethrow;
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
        name: name,
        age: age,
        subtitle:
            "Here's what we've learned about you.\nReview and edit to make sure it's perfect.",
        avatarUrl: avatarUrl,
        personalityTraits: curatedProfile.personalityTraits,
        interests: curatedProfile.interests,
        conversationStyleDescription:
            curatedProfile.conversationStyleDescription,
        aboutMe: curatedProfile.aboutMe,
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

    state = state.copyWith(isLoading: true);

    try {
      final updatedProfile = CuratedProfile(
        personalityTraits: newTraits,
        interests: currentData.interests,
        conversationStyleDescription: currentData.conversationStyleDescription,
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

    state = state.copyWith(isLoading: true);

    try {
      final updatedProfile = CuratedProfile(
        personalityTraits: currentData.personalityTraits,
        interests: newInterests,
        conversationStyleDescription: currentData.conversationStyleDescription,
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

    state = state.copyWith(isLoading: true);

    try {
      final updatedProfile = CuratedProfile(
        personalityTraits: currentData.personalityTraits,
        interests: currentData.interests,
        conversationStyleDescription: newDescription,
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
