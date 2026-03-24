import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jiffy/presentation/screens/onboarding/data/models/basic_details.dart';
import 'package:jiffy/presentation/screens/onboarding/data/repository/onboarding_repository.dart';
import '../models/basics_form_data.dart';

part 'basics_viewmodel.g.dart';

@riverpod
class BasicsViewModel extends _$BasicsViewModel {
  @override
  BasicsFormData build() {
    return const BasicsFormData();
  }

  void updateFirstName(String? value) {
    state = state.copyWith(firstName: value, error: () => null);
  }

  void updateDateOfBirth(DateTime? value) {
    state = state.copyWith(dateOfBirth: value, error: () => null);
  }

  void updateGender(String? value) {
    state = state.copyWith(gender: value, error: () => null);
  }

  void updatePhoto(String? url) {
    state = state.copyWith(photoUrl: url, error: () => null);
  }

  void updateUniversity(String? value) {
    state = state.copyWith(university: value, error: () => null);
  }

  void updateGraduationYear(String? value) {
    state = state.copyWith(graduationYear: value, error: () => null);
  }

  void updateCompanyName(String? value) {
    state = state.copyWith(companyName: value, error: () => null);
  }

  void updateTitleCompany(String? value) {
    state = state.copyWith(titleCompany: value, error: () => null);
  }

  Future<bool> saveBasics() async {
    if (state.isSaving) return false;

    state = state.copyWith(isSaving: true, error: () => null);
    try {
      final repo = ref.read(onboardingRepositoryProvider);

      // Upload photo if local
      if (state.photoUrl != null && state.photoUrl!.isNotEmpty) {
        final uri = Uri.tryParse(state.photoUrl!);
        final isLocal =
            uri == null || (uri.scheme != 'http' && uri.scheme != 'https');
        if (isLocal) {
          await repo.uploadProfileImage(state.photoUrl!, name: state.firstName);
        }
      }

      // Save user info
      await repo.saveUserInformation(BasicDetails(
        name: state.firstName,
        gender: state.gender,
        birthDate: state.dateOfBirth,
        preferredGender: null, // Will be set in next step
      ));

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: () => 'Failed to save basics: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> saveProfessionalDetails() async {
    if (state.isSaving) return false;

    state = state.copyWith(isSaving: true, error: () => null);
    try {
      final repo = ref.read(onboardingRepositoryProvider);
      await repo.saveProfessionalDetails(
        state.university,
        state.graduationYear,
        state.companyName,
        state.titleCompany,
      );

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: () => 'Failed to save professional details: ${e.toString()}',
      );
      return false;
    }
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
      state.firstName != null &&
      state.firstName!.isNotEmpty &&
      state.photoUrl != null &&
      state.photoUrl!.isNotEmpty;

  bool get isStep2Valid =>
      state.dateOfBirth != null &&
      state.gender != null &&
      state.gender!.isNotEmpty;

  bool get isStep3Valid =>
      (state.university?.trim().isNotEmpty ?? false) &&
      (state.graduationYear?.trim().isNotEmpty ?? false);

  bool get isFormValid => isStep1Valid && isStep2Valid && isStep3Valid;
}
