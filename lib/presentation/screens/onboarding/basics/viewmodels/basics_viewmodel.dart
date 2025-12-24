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

  bool get isFormValid => state.isValid;
}
