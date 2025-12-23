import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/avatar.dart';
import '../../widgets/button.dart';
import '../../widgets/input.dart';

class BasicsScreen extends StatelessWidget {
  const BasicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            // Progress Bar (Step 1 of 3)
            Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: AppColors.surfacePlum.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Photo Section
                  Center(
                    child: Column(
                      children: [
                        const Avatar(radius: 60),
                        const SizedBox(height: 16),
                        Text(
                          "Add your photo to get started",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Change Photo",
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.primaryRaspberry,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Form Fields
                  const Input(
                    label: "First Name",
                    placeholder: "Jane",
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    child: Text(
                      "This is how it will appear on your profile",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                  const Input(
                    label: "Age",
                    placeholder: "28",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  const Input(
                    label: "Gender",
                    placeholder: "Woman",
                    // Note: Ideally this would be a dropdown, but using Input as placeholder per plan
                  ),
                ],
              ),
            ),

            // Continue Button (Fixed at bottom)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Button(
                text: "Continue",
                onTap: () {
                  // TODO: Navigate to next step
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
