import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Assuming 1 out of 5 steps because basics is step 2-3 mostly
              const ProgressBar(currentStep: 1, totalSteps: 5),
              const SizedBox(height: 32),
              
              Text(
                'Got an invite?',
                style: textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 12),
              
              Text(
                'Enter your friend\'s referral code to unlock exclusive rewards.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
              
              const SizedBox(height: 40),
              
              ThemedInput(
                label: 'Referral Code (Optional)',
                placeholder: 'ENTER CODE',
                initialValue: state.code,
                onChanged: (val) => viewModel.updateCode(val.toUpperCase()),
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
              
              if (state.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(),
              ],
              
              const SizedBox(height: 32),
              
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                Button(
                  text: 'Apply & Continue',
                  onTap: state.code.trim().isEmpty
                      ? () {}
                      : () async {
                          final success = await viewModel.submitCode();
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Referral code applied successfully!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            context.pushRoute(
                              AppRoutes.onboardingBasics,
                              queryParameters: {'hideBackButton': 'true'},
                            );
                          }
                        },
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                
                const SizedBox(height: 16),
                
                Button(
                  text: 'Skip for now',
                  type: ButtonType.ghost,
                  onTap: () {
                    context.pushRoute(AppRoutes.onboardingBasics);
                  },
                ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
