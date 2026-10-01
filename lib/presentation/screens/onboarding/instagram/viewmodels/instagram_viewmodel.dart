import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/instagram_state.dart';
import 'package:jiffy/core/services/waitlist_service.dart';
import 'package:jiffy/core/auth/auth_viewmodel.dart';
import '../../basics/viewmodels/basics_viewmodel.dart';

part 'instagram_viewmodel.g.dart';

@riverpod
class InstagramViewModel extends _$InstagramViewModel {
  @override
  InstagramState build() {
    return InstagramState();
  }

  void updateHandle(String handle) {
    state = state.copyWith(handle: handle.trim(), error: null);
  }

  void updateFollowersCount(String count) {
    state = state.copyWith(followersCount: count.trim(), error: null);
  }

  Future<bool> saveInstagramDetails() async {
    if (!state.isValid) return false;

    state = state.copyWith(isSaving: true, error: null);

    try {
      final followers = int.tryParse(state.followersCount) ?? 0;
      final basicsGender = ref.read(basicsViewModelProvider).gender?.toLowerCase();
      final isWoman = basicsGender == 'woman' || basicsGender == 'female' || basicsGender == 'women';
      
      final authState = ref.read(authViewModelProvider);
      if (authState.isAuthenticated && authState.userId != null) {
        final backendWaitlisted = await ref.read(waitlistServiceProvider.notifier).notifyWaitlisted(
          authState.userId!,
          instagramHandle: state.handle,
          instagramFollowerCount: followers,
          gender: basicsGender,
        );

        // Women bypass the follower count restriction. Men require at least 1,000 followers.
        final isWaitlisted = isWoman ? false : (followers < 1000 ? true : backendWaitlisted);
        state = state.copyWith(isSaving: false, isWaitlisted: isWaitlisted);
        return true;
      }
      
      final isWaitlisted = isWoman ? false : (followers < 1000);
      state = state.copyWith(isSaving: false, isWaitlisted: isWaitlisted);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to verify Instagram details. Please try again.',
      );
      return false;
    }
  }
}
