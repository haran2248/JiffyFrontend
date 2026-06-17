import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/navigation/navigation_service.dart';
import 'package:jiffy/core/navigation/app_routes.dart';
import 'package:jiffy/presentation/widgets/button.dart';
import 'package:jiffy/presentation/widgets/progress_bar.dart';
import 'package:jiffy/presentation/widgets/input.dart';
import 'viewmodels/instagram_viewmodel.dart';

class InstagramScreen extends ConsumerWidget {
  const InstagramScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(instagramViewModelProvider.notifier);
    final state = ref.watch(instagramViewModelProvider);
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Instagram"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ProgressBar(currentStep: 2, totalSteps: 6), // assuming we bump total steps
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Verify your reach.",
                      style: textTheme.displaySmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Jiffy is an exclusive community. Please share your Instagram details to see if you qualify.",
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ThemedInput(
                      label: "Instagram Handle",
                      placeholder: "@yourusername",
                      initialValue: state.handle,
                      onChanged: viewModel.updateHandle,
                    ),
                    const SizedBox(height: 24),
                    ThemedInput(
                      label: "Approximate Follower Count",
                      placeholder: "e.g. 1500",
                      initialValue: state.followersCount,
                      onChanged: viewModel.updateFollowersCount,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Button(
                text: "Continue",
                isLoading: state.isSaving,
                onTap: state.isValid
                    ? () async {
                        final success = await viewModel.saveInstagramDetails();
                        if (context.mounted) {
                          final currentState = ref.read(instagramViewModelProvider);
                          if (success) {
                            if (currentState.isWaitlisted) {
                              context.goToRoute(AppRoutes.onboardingWaitlist);
                            } else {
                              context.pushRoute(AppRoutes.onboardingProfessionalDetails);
                            }
                          } else if (currentState.error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(currentState.error!)),
                            );
                          }
                        }
                      }
                    : () {}, // disabled if invalid
              ),
            ),
          ],
        ),
      ),
    );
  }
}
