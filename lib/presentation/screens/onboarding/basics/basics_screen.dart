import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/button.dart';
import '../../../widgets/progress_bar.dart';
import 'viewmodels/basics_viewmodel.dart';
import 'widgets/name_photo_step.dart';
import 'widgets/vitals_step.dart';

class BasicsScreen extends ConsumerWidget {
  const BasicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(basicsViewModelProvider.notifier);
    final formData = ref.watch(basicsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: AppColors.textPrimary,
          onPressed: formData.currentStep > 1
              ? viewModel.previousStep
              : () => Navigator.of(context).pop(),
        ),
        title: Text(formData.currentStep == 1 ? "Basics" : "A little more"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            ProgressBar(currentStep: formData.currentStep, totalSteps: 2),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: formData.currentStep == 1
                    ? NamePhotoStep(
                        firstName: formData.firstName,
                        onFirstNameChanged: viewModel.updateFirstName,
                        onPhotoTap: () {
                          // TODO: Implement photo picker
                          viewModel.updatePhoto(null);
                        },
                      )
                    : VitalsStep(
                        selectedDateOfBirth: formData.dateOfBirth,
                        selectedGender: formData.gender,
                        onDateOfBirthChanged: viewModel.updateDateOfBirth,
                        onGenderChanged: viewModel.updateGender,
                      ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(24),
                child: Button(
                  text: "Continue",
                  onTap: (formData.currentStep == 1
                          ? viewModel.isStep1Valid
                          : viewModel.isStep2Valid)
                      ? () {
                          if (formData.currentStep == 1) {
                            viewModel.nextStep();
                          } else {
                            // TODO: Navigate to next onboarding feature
                            debugPrint('Final Basics Form: $formData');
                          }
                        }
                      : () {},
                )),
          ],
        ),
      ),
    );
  }
}
