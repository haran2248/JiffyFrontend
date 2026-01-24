import "package:flutter/material.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:jiffy/presentation/screens/profile_self/models/profile_self_state.dart";
import "package:jiffy/presentation/screens/profile_self/models/profile_self_data.dart";
import "package:jiffy/presentation/screens/onboarding/data/repository/onboarding_repository.dart";
import "package:jiffy/presentation/screens/onboarding/data/models/curated_profile.dart";
import "package:jiffy/core/auth/auth_repository.dart";
import "package:dio/dio.dart";
import "package:jiffy/core/services/photo_upload_service.dart";
import "package:jiffy/core/services/service_providers.dart";
import "package:jiffy/core/network/dio_provider.dart";
import "package:jiffy/presentation/screens/profile/models/profile_data.dart";
import "package:jiffy/presentation/screens/profile/profile_view_screen.dart";

part "profile_self_viewmodel.g.dart";

// Preview mode placeholder constants
const _kPreviewRelationshipText =
    "This section shows compatibility insights when others view your profile.";
const _kPreviewComparisonInsights = [
  ComparisonInsight(
      label: "Similar conversation style", type: InsightType.common),
  ComparisonInsight(label: "Shared interest in Art", type: InsightType.common),
];

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

  PhotoUploadService get _photoUploadService =>
      ref.read(photoUploadServiceProvider);

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

          // Get photos from specific image ID fields
          final firstImageId = userData['firstImageId'] as String?;
          if (firstImageId != null && firstImageId.isNotEmpty) {
            photos.add(ProfileSelfPhoto(
              id: firstImageId,
              url:
                  'https://jiffystorebucket.s3.ap-south-1.amazonaws.com/$firstImageId',
              isPrimary: true,
            ));
          }

          final secondImageId = userData['secondImageId'] as String?;
          if (secondImageId != null && secondImageId.isNotEmpty) {
            photos.add(ProfileSelfPhoto(
              id: secondImageId,
              url:
                  'https://jiffystorebucket.s3.ap-south-1.amazonaws.com/$secondImageId',
              isPrimary: false,
            ));
          }

          final thirdImageId = userData['thirdImageId'] as String?;
          if (thirdImageId != null && thirdImageId.isNotEmpty) {
            photos.add(ProfileSelfPhoto(
              id: thirdImageId,
              url:
                  'https://jiffystorebucket.s3.ap-south-1.amazonaws.com/$thirdImageId',
              isPrimary: false,
            ));
          }

          final fourthImageId = userData['fourthImageId'] as String?;
          if (fourthImageId != null && fourthImageId.isNotEmpty) {
            photos.add(ProfileSelfPhoto(
              id: fourthImageId,
              url:
                  'https://jiffystorebucket.s3.ap-south-1.amazonaws.com/$fourthImageId',
              isPrimary: false,
            ));
          }

          debugPrint(
              "ProfileSelfViewModel: Loaded user - name: $name, age: $age, photos: ${photos.length}");
        }
      } catch (e) {
        debugPrint("ProfileSelfViewModel: Error fetching user data: $e");
        rethrow;
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
        // Use stored aboutMe if available, otherwise generate from traits/interests
        if (curatedProfile.aboutMe != null &&
            curatedProfile.aboutMe!.isNotEmpty) {
          aboutMe = curatedProfile.aboutMe!;
        } else {
          final traits = curatedProfile.personalityTraits;
          final interests = curatedProfile.interests;
          if (traits.isNotEmpty || interests.isNotEmpty) {
            final traitsPart =
                traits.isNotEmpty ? "I'm ${traits.join(', ')}." : "";
            final interestsPart =
                interests.isNotEmpty ? "I love ${interests.join(', ')}." : "";
            aboutMe = [traitsPart, interestsPart]
                .where((s) => s.isNotEmpty)
                .join(" ");
          }
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
        aboutMe: currentData.aboutMe,
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
        aboutMe: currentData.aboutMe,
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
        aboutMe: currentData.aboutMe,
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

  /// Update about me via API
  Future<void> updateAboutMe(String newAboutMe) async {
    final currentData = state.data;
    if (currentData == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final updatedProfile = CuratedProfile(
        personalityTraits: currentData.personalityTraits,
        interests: currentData.interests,
        conversationStyleDescription: currentData.conversationStyleDescription,
        aboutMe: newAboutMe,
      );

      await _onboardingRepository.updateCuratedProfile(updatedProfile);

      // Reload to get fresh data
      await loadProfileData();
    } catch (e) {
      debugPrint("ProfileSelfViewModel: Error updating about me - $e");
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: () => "Failed to update about me. Please try again.",
      );
    }
  }

  /// Upload a photo for a specific index
  Future<void> uploadPhoto(int index) async {
    final currentData = state.data;
    if (currentData == null) return;

    // Check if we already have a photo at this index (for edit vs add)
    // Primary index is 1. Secondary starts at 2.
    // Index 1 = Primary
    // Index 2 = Secondary 1
    // Index 3 = Secondary 2
    // Index 4 = Secondary 3

    try {
      // Pick and crop image
      // Use 3:4 ratio for all profile photos as per design usually, but service defaults to square (1.0)
      // Jiffy design often uses 3:4 for vertical cards. Let's use 3:4 (0.75) for better portrait fit.
      final file = await _photoUploadService.pickAndCropImage(
        aspectRatio: 0.75,
      );

      if (file == null) {
        // User cancelled
        return;
      }

      state = state.copyWith(isLoading: true);

      // Upload image
      await _onboardingRepository.uploadProfileImage(
        file.path,
        index: index,
        name:
            currentData.name, // Pass name just in case, though usually optional
      );

      // Refresh data to show new photo
      await loadProfileData();
    } catch (e) {
      debugPrint(
          "ProfileSelfViewModel: Error uploading photo (index $index) - $e");
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: () => "Failed to upload photo. Please try again.",
      );
    }
  }

  /// Edit main profile photo (Index 1)
  void onEditMainPhoto() {
    uploadPhoto(1);
  }

  /// Add a new secondary photo
  /// Finds the first available slot (2, 3, or 4) or appends to end
  void onAddSecondaryPhoto() {
    final currentData = state.data;
    if (currentData == null) return;

    // Current photos include primary + secondary
    // We want to add to the next available slot.
    // If we have 1 primary + 0 secondary -> next is 2
    // If we have 1 primary + 1 secondary -> next is 3

    // Calculate next index based on current total photos
    // Note: This logic assumes photos are filled sequentially.
    // If we allow holes (e.g. 1 and 3 but no 2), backend/app might need robust handling.
    // For now, assume sequential filling: count + 1.
    final nextIndex = currentData.photos.length + 1;

    if (nextIndex > 4) {
      // Max photos reached (1 primary + 3 secondary)
      // This case should be handled by UI disabling "Add" button, but safe guard here.
      debugPrint("ProfileSelfViewModel: Max photos reached");
      return;
    }

    uploadPhoto(nextIndex);
  }

  /// Edit a specific secondary photo
  void onEditSecondaryPhoto(ProfileSelfPhoto photo) {
    final currentData = state.data;
    if (currentData == null) return;

    // Find index of this photo in the full list
    // photos[0] is primary (index 1)
    // photos[1] is secondary 1 (index 2)
    final listIndex = currentData.photos.indexWhere((p) => p.id == photo.id);
    if (listIndex == -1) return;

    // API index is listIndex + 1
    uploadPhoto(listIndex + 1);
  }

  /// Navigate to photo management
  void onManagePhotos() {
    // This is now handled by onAddSecondaryPhoto / onEditSecondaryPhoto
    // But kept as fallback or if UI calls it directly for general management
    debugPrint(
        "ProfileSelfViewModel: Manage photos called - use specific add/edit methods");
  }

  /// Navigate to preview profile
  void onPreviewProfile(BuildContext context) {
    final currentData = state.data;
    if (currentData == null) return;

    // Map ProfileSelfData to ProfileData
    // We map the user's own data to the generic profile view model
    // so they can see exactly what other users see.
    final profileData = ProfileData(
      id: currentData.id,
      userId: currentData.id,
      name: currentData.name,
      age: currentData.age,
      location: currentData.location,
      bio: currentData.aboutMe,
      // Map photos: ProfileSelfPhoto -> Photo
      photos: currentData.photos
          .map((p) => Photo(url: p.url, caption: null))
          .toList(),
      interests: currentData.interests,
      traits: currentData.personalityTraits,
      // Map conversation style
      conversationStyle: currentData.conversationStyleDescription,
      // Show placeholder for relationship preview in self-view so the section appears
      relationshipPreview: _kPreviewRelationshipText,
      comparisonInsights: _kPreviewComparisonInsights,
      conversationStarter: null,
    );

    // Show profile in full-screen modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileViewScreen(
        profile: profileData,
        isPreview: true,
      ),
    );
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
