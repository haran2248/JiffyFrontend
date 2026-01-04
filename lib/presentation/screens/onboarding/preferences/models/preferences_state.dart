import 'gender_preference.dart';
import 'relationship_goal.dart';

const _sentinel = Object();

class PreferencesState {
  final GenderPreference? selectedGender;
  final RelationshipGoal? selectedGoal;
  final bool isLoading;
  final String? errorMessage;

  const PreferencesState({
    this.selectedGender,
    this.selectedGoal,
    this.isLoading = false,
    this.errorMessage,
  });

  PreferencesState copyWith({
    GenderPreference? selectedGender,
    RelationshipGoal? selectedGoal,
    bool? isLoading,
    Object? errorMessage = _sentinel,
  }) {
    return PreferencesState(
      selectedGender: selectedGender ?? this.selectedGender,
      selectedGoal: selectedGoal ?? this.selectedGoal,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
