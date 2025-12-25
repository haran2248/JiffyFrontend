import 'package:flutter/material.dart';
import '../../../../widgets/input.dart';
import '../../../../widgets/date_picker_field.dart';
import '../../../../widgets/option_picker_field.dart';

class BasicsForm extends StatelessWidget {
  final String? firstName;
  final DateTime? selectedDateOfBirth;
  final String? selectedGender;
  final ValueChanged<String?>? onFirstNameChanged;
  final ValueChanged<DateTime?>? onDateOfBirthChanged;
  final ValueChanged<String?>? onGenderChanged;

  const BasicsForm({
    super.key,
    this.firstName,
    this.selectedDateOfBirth,
    this.selectedGender,
    this.onFirstNameChanged,
    this.onDateOfBirthChanged,
    this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ThemedInput(
          label: "First Name",
          placeholder: "Jane",
          // onChanged: onFirstNameChanged, // TODO: Add onChanged to Input widget
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          child: Text(
            "This is how it will appear on your profile",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
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
