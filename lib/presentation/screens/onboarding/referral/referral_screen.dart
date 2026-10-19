import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/navigation/navigation_service.dart';
import 'package:jiffy/core/navigation/app_routes.dart';
import 'package:jiffy/presentation/widgets/button.dart';
import 'package:jiffy/presentation/widgets/input.dart';
import 'package:jiffy/presentation/widgets/progress_bar.dart';
import 'viewmodels/referral_viewmodel.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  void _navigateToBasics(BuildContext context) {
    context.pushRoute(
      AppRoutes.onboardingBasics,
      queryParameters: {'hideBackButton': 'true'},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(referralViewModelProvider.notifier);
    final state = ref.watch(referralViewModelProvider);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.popRoute(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scrollable top content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ProgressBar(currentStep: 1, totalSteps: 5),
                    const SizedBox(height: 32),
                    Text(
                      'Got an invite code?',
                      style: textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                    const SizedBox(height: 12),
                    Text(
                      'Enter your invite code if you have one. This is optional.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                    const SizedBox(height: 40),

                    // Hide the field if already applied/set
                    if (state.isAlreadyApplied) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.green, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'Invite code applied',
                              style: textTheme.bodyLarge?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
                    ] else ...[
                      Semantics(
                        label: 'Got an invite code? Optional input field',
                        hint: 'Type your invite code and press done',
                        textField: true,
                        child: ThemedInput(
                          label: 'Got an invite code?',
                          placeholder: 'ENTER CODE (OPTIONAL)',
                          initialValue: state.code,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) async {
                            await viewModel.submitCode();
                          },
                          onChanged: (val) =>
                              viewModel.updateCode(val),
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                    ],

                    // Inline error feedback
                    if (state.error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        state.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(),
                    ],

                    // Inline success feedback
                    if (state.successMessage != null && !state.isAlreadyApplied) ...[
                      const SizedBox(height: 10),
                      Text(
                        state.successMessage!,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(),
                    ],
                  ],
                ),
              ),
            ),

            // Pinned bottom buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Button(
                          text: state.code.trim().isNotEmpty && !state.isAlreadyApplied
                              ? 'Apply & Continue'
                              : 'Continue',
                          onTap: () async {
                            if (state.code.trim().isNotEmpty &&
                                !state.isAlreadyApplied) {
                              await viewModel.submitCode();
                            }
                            if (context.mounted) {
                              // Never block continuing, proceed to onboarding basics
                              _navigateToBasics(context);
                            }
                          },
                        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                        const SizedBox(height: 16),
                        Button(
                          text: 'Skip for now',
                          type: ButtonType.ghost,
                          onTap: () {
                            _navigateToBasics(context);
                          },
                        ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

