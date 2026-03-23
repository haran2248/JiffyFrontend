import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jiffy/core/navigation/app_routes.dart';
import 'package:jiffy/core/navigation/navigation_service.dart';
import 'package:jiffy/core/theme/app_colors.dart';
import 'package:jiffy/presentation/widgets/button.dart';
import 'package:jiffy/presentation/widgets/progress_bar.dart';
import '../basics/viewmodels/basics_viewmodel.dart';

class ProfessionalDetailsScreen extends ConsumerWidget {
  const ProfessionalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(basicsViewModelProvider);
    final viewModel = ref.read(basicsViewModelProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.popRoute()),
        title: const Text('A little more'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ProgressBar(currentStep: 3, totalSteps: 5),
                    const SizedBox(height: 32),

                    // Heading
                    Text(
                      'Where do you belong?',
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                    const SizedBox(height: 8),

                    Text(
                      'College is required — work is optional.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 80.ms),

                    const SizedBox(height: 40),

                    // College field
                    _DetailsField(
                      label: 'College / University',
                      hint: 'Where did you study?',
                      icon: Icons.school_outlined,
                      initialValue: formData.college,
                      onChanged: viewModel.updateCollege,
                      delay: 150.ms,
                    ),

                    const SizedBox(height: 24),

                    // Work field (optional)
                    _DetailsField(
                      label: 'Work / Company (optional)',
                      hint: 'Where do you work?',
                      icon: Icons.work_outline_rounded,
                      initialValue: formData.work,
                      onChanged: viewModel.updateWork,
                      delay: 220.ms,
                    ),
                  ],
                ),
              ),
            ),

            // Pinned bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Opacity(
                opacity:
                    (formData.college?.trim().isNotEmpty ?? false) ? 1.0 : 0.4,
                child: Button(
                  text: 'Continue',
                  onTap: (formData.college?.trim().isNotEmpty ?? false)
                      ? () =>
                          context.pushRoute(AppRoutes.onboardingPreferredGender)
                      : () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Styled text field tile
// ---------------------------------------------------------------------------

class _DetailsField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final Duration delay;

  const _DetailsField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.delay,
    this.initialValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      style: TextStyle(color: colors.onSurface),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.primaryRaspberry),
        filled: true,
        fillColor: AppColors.surfacePlum,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.surfacePlumLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryRaspberry, width: 1.5),
        ),
        labelStyle: TextStyle(color: colors.onSurface.withValues(alpha: 0.6)),
        hintStyle: TextStyle(color: colors.onSurface.withValues(alpha: 0.35)),
      ),
    ).animate(delay: delay).fadeIn(duration: 350.ms).slideY(begin: 0.08);
  }
}
