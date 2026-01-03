import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jiffy/presentation/screens/onboarding/data/models/basic_details.dart';
import 'package:jiffy/presentation/screens/onboarding/data/models/desired_qualities.dart';
import 'package:jiffy/presentation/screens/onboarding/data/repository/onboarding_repository.dart';
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

      // Map UI model to DTO
      final gender = state.selectedGender!.label;

      await repo.saveUserInformation(BasicDetails(preferredGender: gender));

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
