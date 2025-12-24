import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/button.dart';
import '../../../widgets/progress_bar.dart';
import 'viewmodels/basics_viewmodel.dart';
import 'widgets/photo_upload_section.dart';
import 'widgets/basics_form.dart';

class BasicsScreen extends ConsumerWidget {
  const BasicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(basicsViewModelProvider.notifier);
    final formData = ref.watch(basicsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text("Basics"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ProgressBar(currentStep: 1, totalSteps: 3),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  PhotoUploadSection(
                    onTap: () {
                      // TODO: Implement photo picker
                      viewModel.updatePhoto(null);
                    },
                  ),
                  const SizedBox(height: 48),
                  BasicsForm(
                    firstName: formData.firstName,
                    selectedDateOfBirth: formData.dateOfBirth,
                    selectedGender: formData.gender,
                    onFirstNameChanged: viewModel.updateFirstName,
                    onDateOfBirthChanged: viewModel.updateDateOfBirth,
                    onGenderChanged: viewModel.updateGender,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Button(
                text: "Continue",
                onTap: formData.isValid
                    ? () {
                        // TODO: Navigate to next step
                        debugPrint('Form is valid');
                      }
                    : () {}, // Empty callback instead of null
              ),
            ),
          ],
        ),
      ),
    );
  }
}
