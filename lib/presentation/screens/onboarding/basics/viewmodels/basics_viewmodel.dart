import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/basics_form_data.dart';

part 'basics_viewmodel.g.dart';

@riverpod
class BasicsViewModel extends _$BasicsViewModel {
  @override
  BasicsFormData build() {
    return const BasicsFormData();
  }

  void updateFirstName(String? value) {
    state = state.copyWith(firstName: value);
  }

  void updateDateOfBirth(DateTime? value) {
    state = state.copyWith(dateOfBirth: value);
  }

  void updateGender(String? value) {
    state = state.copyWith(gender: value);
  }

  void updatePhoto(String? url) {
    state = state.copyWith(photoUrl: url);
  }

  void nextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  bool get isStep1Valid =>
      state.firstName != null && state.firstName!.isNotEmpty;

  bool get isStep2Valid =>
      state.dateOfBirth != null &&
      state.gender != null &&
      state.gender!.isNotEmpty;

  bool get isFormValid => isStep1Valid && isStep2Valid;
}
