import "package:flutter/material.dart" show debugPrint;
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:jiffy/presentation/screens/profile_self/models/profile_self_state.dart";
import "package:jiffy/presentation/screens/profile_self/models/profile_self_data.dart";

part "profile_self_viewmodel.g.dart";

/// ViewModel for the Profile Self (Editable View) screen.
///
/// Manages loading, error handling, and state for the user's own profile.
@riverpod
class ProfileSelfViewModel extends _$ProfileSelfViewModel {
  bool _isDisposed = false;

  @override
  ProfileSelfState build() {
    _isDisposed = false;
    ref.onDispose(() => _isDisposed = true);

    // Load data on initialization after build completes
    Future.microtask(() => loadProfileData());
    return const ProfileSelfState(isLoading: true);
  }

  /// Load profile data from backend
  Future<void> loadProfileData() async {
    if (_isDisposed) return;
    state = state.copyWith(isLoading: true, error: () => null);

    try {
      // TODO: Replace with actual API call via repository
      // Example: final data = await ref.read(profileSelfRepositoryProvider).fetchProfile();
      debugPrint("ProfileSelfViewModel: Loading profile data...");

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data for development
      const mockData = ProfileSelfData(
        id: "user-self-1",
        name: "Jessica",
        age: 28,
        location: "San Francisco, CA",
        photos: [
          ProfileSelfPhoto(
            id: "photo-1",
            url:
                "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400",
            isPrimary: true,
          ),
          ProfileSelfPhoto(
            id: "photo-2",
            url:
                "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400",
          ),
        ],
        aboutMe:
            "Based on our chat, you seem like a curious soul who values authenticity. You're always looking for meaningful connections and you're not afraid to try new things. You have a playful sense of humor and enjoy discovering hidden gems.",
        interests: ["Travel", "Hiking", "Photography", "Cooking"],
        conversationStyleTitle: "Witty & Inquisitive",
        conversationStyleDescription:
            "You love clever banter and asking questions that make others think.",
      );

      if (_isDisposed) return;
      state = state.copyWith(data: mockData, isLoading: false);
    } catch (e) {
      debugPrint("ProfileSelfViewModel: Error loading profile - $e");
      if (_isDisposed) return;
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
