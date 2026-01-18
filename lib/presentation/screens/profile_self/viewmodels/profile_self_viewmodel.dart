import "package:flutter/material.dart" show debugPrint;
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:jiffy/presentation/screens/profile_self/models/profile_self_state.dart";
import "package:jiffy/presentation/screens/profile_self/models/profile_self_data.dart";
import "package:jiffy/presentation/screens/onboarding/data/repository/onboarding_repository.dart";
import "package:jiffy/presentation/screens/onboarding/data/models/curated_profile.dart";
import "package:jiffy/core/auth/auth_repository.dart";
import "package:dio/dio.dart";
import "package:jiffy/core/network/dio_provider.dart";

part "profile_self_viewmodel.g.dart";

/// ViewModel for the Profile Self (Editable View) screen.
///
/// Manages loading, error handling, and state for the user's own profile.
@riverpod
class ProfileSelfViewModel extends _$ProfileSelfViewModel {
  @override
  ProfileSelfState build() {
    // Load data on initialization after build completes
    Future.microtask(() => loadProfileData());
    return const ProfileSelfState(isLoading: true);
  }

  OnboardingRepository get _onboardingRepository =>
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
      debugPrint("ProfileSelfViewModel: Error parsing DOB: $e");
      return 0;
    }
  }

  /// Load profile data from backend
  Future<void> loadProfileData() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, error: () => null);

    try {
      debugPrint("ProfileSelfViewModel: Loading profile data...");

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
      String? location;
      List<ProfileSelfPhoto> photos = [];

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

          // Calculate age from birthDate
          final dobString = basicDetails?['birthDate'] as String?;
          debugPrint(
              "ProfileSelfViewModel: DOB string from server: $dobString");
          age = _calculateAge(dobString);

          // Get location
          location = basicDetails?['location'] as String?;

          // Get photos from imageIds
          final imageIds = userData['imageIds'] as List<dynamic>?;
          if (imageIds != null && imageIds.isNotEmpty) {
            photos = imageIds.asMap().entries.map((entry) {
              final imageId = entry.value as String;
              return ProfileSelfPhoto(
                id: imageId,
                url:
                    'https://jiffystorebucket.s3.ap-south-1.amazonaws.com/$imageId',
                isPrimary: entry.key == 0,
              );
            }).toList();
          }

          debugPrint(
              "ProfileSelfViewModel: Loaded user - name: $name, age: $age, photos: ${photos.length}");
        }
      } catch (e) {
        debugPrint("ProfileSelfViewModel: Error fetching user data: $e");
      }

      // Fetch curated profile from API
      CuratedProfile? curatedProfile;
      try {
        curatedProfile = await _onboardingRepository.getCuratedProfile();
        debugPrint(
            "ProfileSelfViewModel: Curated profile fetched - traits: ${curatedProfile?.personalityTraits}, interests: ${curatedProfile?.interests}");
      } catch (e) {
        debugPrint("ProfileSelfViewModel: Error fetching curated profile: $e");
      }

      // Build "About Me" text from curated profile
      String aboutMe =
          "Complete your onboarding to see your AI-generated profile summary.";
      if (curatedProfile != null) {
        final traits = curatedProfile.personalityTraits;
        final interests = curatedProfile.interests;
        if (traits.isNotEmpty || interests.isNotEmpty) {
          final traitsPart =
              traits.isNotEmpty ? "I'm ${traits.join(', ')}." : "";
          final interestsPart =
              interests.isNotEmpty ? "I love ${interests.join(', ')}." : "";
          aboutMe =
              [traitsPart, interestsPart].where((s) => s.isNotEmpty).join(" ");
        }
      }

      // Build profile data
      final profileData = ProfileSelfData(
        id: uid,
        name: name,
        age: age,
        location: location,
        photos: photos,
        aboutMe: aboutMe,
        interests: curatedProfile?.interests ?? [],
        conversationStyleTitle: curatedProfile != null
            ? "Your Conversation Style"
            : "Not yet analyzed",
        conversationStyleDescription: curatedProfile
                ?.conversationStyleDescription ??
            "Complete your onboarding to see your AI-generated conversation style.",
        personalityTraits: curatedProfile?.personalityTraits ?? [],
      );

      if (!ref.mounted) return;
      state = state.copyWith(data: profileData, isLoading: false);
    } catch (e) {
      debugPrint("ProfileSelfViewModel: Error loading profile - $e");
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: () => "Failed to load profile. Please try again.",
      );
    }
  }

  /// Refresh profile data
  Future<void> refresh() async {
    await loadProfileData();
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

      await _onboardingRepository.updateCuratedProfile(updatedProfile);

      // Reload to get fresh data
      await loadProfileData();
    } catch (e) {
      debugPrint("ProfileSelfViewModel: Error updating traits - $e");
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

      await _onboardingRepository.updateCuratedProfile(updatedProfile);

      // Reload to get fresh data
      await loadProfileData();
    } catch (e) {
      debugPrint("ProfileSelfViewModel: Error updating interests - $e");
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

      await _onboardingRepository.updateCuratedProfile(updatedProfile);

      // Reload to get fresh data
      await loadProfileData();
    } catch (e) {
      debugPrint(
          "ProfileSelfViewModel: Error updating conversation style - $e");
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: () => "Failed to update conversation style. Please try again.",
      );
    }
  }

  /// Navigate to photo management
  void onManagePhotos() {
    // TODO: Navigate to photo management screen
    debugPrint("ProfileSelfViewModel: Navigate to manage photos");
  }

  /// Navigate to preview profile
  void onPreviewProfile() {
    // TODO: Navigate to profile preview screen
    debugPrint("ProfileSelfViewModel: Navigate to preview profile");
  }

  /// Navigate to edit about me
  void onEditAboutMe() {
    // TODO: Navigate to about me edit screen
    debugPrint("ProfileSelfViewModel: Navigate to edit about me");
  }

  /// Navigate to edit interests
  void onEditInterests() {
    // TODO: Navigate to interests edit screen
    debugPrint("ProfileSelfViewModel: Navigate to edit interests");
  }

  /// Navigate to review prompt answers
  void onReviewPromptAnswers() {
    // TODO: Navigate to prompt answers screen
    debugPrint("ProfileSelfViewModel: Navigate to review prompt answers");
  }
}
