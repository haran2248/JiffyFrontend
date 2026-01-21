import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jiffy/presentation/screens/onboarding/data/models/basic_details.dart';
import 'package:jiffy/presentation/screens/onboarding/data/models/desired_qualities.dart';
import 'package:jiffy/presentation/screens/onboarding/data/repository/onboarding_repository.dart';
import 'package:jiffy/presentation/screens/onboarding/basics/viewmodels/basics_viewmodel.dart';
import '../models/preferences_state.dart';
import '../models/gender_preference.dart';
import '../models/relationship_goal.dart';

part 'preferences_viewmodel.g.dart';

@riverpod
class PreferencesViewModel extends _$PreferencesViewModel {
  @override
  PreferencesState build() {
    return const PreferencesState();
  }

  void selectGender(GenderPreference gender) {
    state = state.copyWith(selectedGender: gender);
  }

  void selectGoal(RelationshipGoal goal) {
    state = state.copyWith(selectedGoal: goal);
  }

  Future<bool> saveGenderPreferences() async {
    if (state.selectedGender == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(onboardingRepositoryProvider);

      // Get basics data from the BasicsViewModel
      final basicsData = ref.read(basicsViewModelProvider);

      // Map UI model to DTO - include all basics data along with preferred gender
      final preferredGender = state.selectedGender!.label;

      // First, upload the profile image if one was selected
      if (basicsData.photoUrl != null && basicsData.photoUrl!.isNotEmpty) {
        // Check if it's a local file path (not http/https)
        // This handles file://, content://, and path-based locals like /path/to/file
        final uri = Uri.parse(basicsData.photoUrl!);
        final isLocalUri = uri.scheme.isEmpty ||
            (uri.scheme != 'http' && uri.scheme != 'https');
        if (isLocalUri) {
          await repo.uploadProfileImage(
            basicsData.photoUrl!,
            name: basicsData.firstName,
          );
        }
      }

      // Then save the user information
      await repo.saveUserInformation(BasicDetails(
        name: basicsData.firstName,
        gender: basicsData.gender,
        birthDate: basicsData.dateOfBirth,
        preferredGender: preferredGender,
      ));

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> saveRelationshipGoal() async {
    if (state.selectedGoal == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(onboardingRepositoryProvider);
      // Map UI model to DTO
      // Assuming backend expects the title or enum name.
      // Goal enum has 'title' which is user facing.
      // Let's us the enum name or title. Using title for now based on DTO.
      await repo.saveDesiredQualities(
          DesiredQualities(lookingFor: state.selectedGoal!.title));

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}
