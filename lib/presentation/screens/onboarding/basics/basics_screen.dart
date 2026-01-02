import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/navigation/navigation_service.dart';
import 'package:jiffy/core/navigation/app_routes.dart';
import 'package:jiffy/core/services/service_providers.dart';
import 'package:jiffy/core/config/image_size_config.dart';
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
          onPressed: formData.currentStep > 1
              ? viewModel.previousStep
              : () => context.popRoute(),
        ),
        title: Text(formData.currentStep == 1 ? "Basics" : "A little more"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            ProgressBar(currentStep: 2, totalSteps: 4),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: formData.currentStep == 1
                    ? NamePhotoStep(
                        firstName: formData.firstName,
                        photoUrl: formData.photoUrl,
                        onFirstNameChanged: viewModel.updateFirstName,
                        onPhotoTap: () async {
                          try {
                            final photoUploadService =
                                ref.read(photoUploadServiceProvider);
                            final imageFile =
                                await photoUploadService.pickAndCropImage(
                              aspectRatio:
                                  ImageSizeConfig.profilePhotoAspectRatio,
                              width: ImageSizeConfig.profilePhotoSize,
                              height: ImageSizeConfig.profilePhotoSize,
                            );

                            if (imageFile != null && context.mounted) {
                              // TODO: Upload image to server and get URL
                              // For now, store the file path
                              viewModel.updatePhoto(imageFile.path);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Photo selected successfully!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else if (imageFile == null && context.mounted) {
                              // Permission denied or user cancelled
                              // The service will have opened settings if permanently denied
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Photo access is required. Please enable it in Settings if needed.'),
                                  duration: Duration(seconds: 4),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Error selecting photo: ${e.toString()}'),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
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
                            context.pushRoute(AppRoutes.onboardingCoPilotIntro);
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
