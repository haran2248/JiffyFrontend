import 'package:flutter/material.dart';
import '../../../../widgets/date_picker_field.dart';
import '../../../../widgets/option_picker_field.dart';

class VitalsStep extends StatelessWidget {
  final DateTime? selectedDateOfBirth;
  final String? selectedGender;
  final String? selectedCollege;
  final String? selectedWork;
  final ValueChanged<DateTime?>? onDateOfBirthChanged;
  final ValueChanged<String?>? onGenderChanged;
  final ValueChanged<String>? onCollegeChanged;
  final ValueChanged<String>? onWorkChanged;

  const VitalsStep({
    super.key,
    this.selectedDateOfBirth,
    this.selectedGender,
    this.selectedCollege,
    this.selectedWork,
    this.onDateOfBirthChanged,
    this.onGenderChanged,
    this.onCollegeChanged,
    this.onWorkChanged,
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
            "Other",
          ],
          onChanged: onGenderChanged,
        ),
        const SizedBox(height: 24),
        TextFormField(
          initialValue: selectedCollege,
          decoration: const InputDecoration(
            labelText: 'College/University (Optional)',
            hintText: 'Where did you study?',
          ),
          onChanged: onCollegeChanged,
        ),
        const SizedBox(height: 24),
        TextFormField(
          initialValue: selectedWork,
          decoration: const InputDecoration(
            labelText: 'Work/Company (Optional)',
            hintText: 'Where do you work?',
          ),
          onChanged: onWorkChanged,
        ),
      ],
    );
  }
}
