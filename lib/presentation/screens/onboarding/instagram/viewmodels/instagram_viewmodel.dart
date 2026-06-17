import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/instagram_state.dart';
import 'package:jiffy/core/services/waitlist_service.dart';
import 'package:jiffy/core/auth/auth_viewmodel.dart';

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
      
      final authState = ref.read(authViewModelProvider);
      if (authState.isAuthenticated && authState.userId != null) {
        final isWaitlisted = await ref.read(waitlistServiceProvider.notifier).notifyWaitlisted(
          authState.userId!,
          instagramHandle: state.handle,
          instagramFollowerCount: followers,
        );
        state = state.copyWith(isSaving: false, isWaitlisted: isWaitlisted);
        return true;
      }
      
      state = state.copyWith(isSaving: false, isWaitlisted: true);
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
