import 'package:flutter/material.dart';
import '../../../../widgets/date_picker_field.dart';
import '../../../../widgets/option_picker_field.dart';

class VitalsStep extends StatelessWidget {
  final DateTime? selectedDateOfBirth;
  final String? selectedGender;
  final ValueChanged<DateTime?>? onDateOfBirthChanged;
  final ValueChanged<String?>? onGenderChanged;

  const VitalsStep({
    super.key,
    this.selectedDateOfBirth,
    this.selectedGender,
    this.onDateOfBirthChanged,
    this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DatePickerField(
          label: "Date of Birth",
          placeholder: "Select your date of birth",
          value: selectedDateOfBirth,
          maximumDate: DateTime.now(),
          minimumDate: DateTime(DateTime.now().year - 100),
          onChanged: onDateOfBirthChanged,
        ),
        const SizedBox(height: 24),
        OptionPickerField(
          label: "Gender",
          placeholder: "Select your gender",
          value: selectedGender,
          options: const [
            "Man",
            "Woman",
            "Non-binary",
            "Prefer not to say",
          ],
          onChanged: onGenderChanged,
        ),
      ],
    );
  }
}
