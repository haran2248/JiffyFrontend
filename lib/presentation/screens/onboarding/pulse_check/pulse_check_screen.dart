import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/navigation/app_routes.dart';
import 'package:jiffy/core/navigation/navigation_service.dart';
import 'package:jiffy/core/theme/app_colors.dart';
import 'package:jiffy/presentation/widgets/button.dart';
import 'package:jiffy/presentation/widgets/progress_bar.dart';
import 'viewmodels/pulse_check_viewmodel.dart';

class PulseCheckScreen extends ConsumerWidget {
  const PulseCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pulseCheckViewModelProvider);
    final viewModel = ref.read(pulseCheckViewModelProvider.notifier);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Pulse Check'),
        actions: [
          TextButton(
            onPressed: () =>
                context.pushRoute(AppRoutes.onboardingCoPilotIntro),
            child: Text(
              'Skip',
              style: TextStyle(
                color: AppColors.primaryRaspberry,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ProgressBar(currentStep: 5, totalSteps: 5),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading: "Select your aura."
                    RichText(
                      text: TextSpan(
                        style: textTheme.displaySmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        children: const [
                          TextSpan(text: 'Select your '),
                          TextSpan(
                            text: 'aura.',
                            style: TextStyle(
                              color: AppColors.primaryRaspberry,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                    const SizedBox(height: 8),

                    Text(
                      'Pick at least one from each section.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 80.ms),

                    const SizedBox(height: 32),

                    // Categories
                    if (state.isLoadingCategories)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (state.error != null && state.categories.isEmpty)
                      _ErrorRetry(
                        message: state.error!,
                        onRetry: viewModel.fetchCategories,
                      )
                    else
                      ...state.categories.asMap().entries.map((entry) {
                        final i = entry.key;
                        final category = entry.value;
                        return _CategorySection(
                          category: category,
                          selectedIds: state.selectedOptionIds,
                          onToggle: viewModel.toggleOption,
                          animationDelay: Duration(milliseconds: 100 + i * 80),
                        );
                      }),
                  ],
                ),
              ),
            ),

            // Selected count + CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                children: [
                  // Counter chip
                  AnimatedSwitcher(
                    duration: 200.ms,
                    child: state.selectedOptionIds.isNotEmpty
                        ? Padding(
                            key: ValueKey(state.selectedOptionIds.length),
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              state.canProceed
                                  ? '${state.selectedOptionIds.length} selected ✓'
                                  : '${state.selectedOptionIds.length} selected — pick one from each section',
                              style: TextStyle(
                                color: state.canProceed
                                    ? AppColors.primaryRaspberry
                                    : colors.onSurface.withValues(alpha: 0.5),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // DOUBLE DOWN button
                  Opacity(
                    opacity: state.canProceed ? 1.0 : 0.4,
                    child: Button(
                      text: 'Double Down',
                      isLoading: state.isSaving,
                      onTap: state.canProceed
                          ? () async {
                              final success = await viewModel.saveSelections();
                              if (success && context.mounted) {
                                context.pushRoute(
                                    AppRoutes.onboardingCoPilotIntro);
                              }
                            }
                          : () {},
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Page dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(2, (i) {
                      final isActive = i == 0;
                      return AnimatedContainer(
                        duration: 250.ms,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryRaspberry
                              : colors.onSurface.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category section widget
// ---------------------------------------------------------------------------

class _CategorySection extends StatelessWidget {
  final dynamic category; // ChipCategory
  final Set<String> selectedIds;
  final void Function(String) onToggle;
  final Duration animationDelay;

  const _CategorySection({
    required this.category,
    required this.selectedIds,
    required this.onToggle,
    required this.animationDelay,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with pink left border
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primaryRaspberry,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                category.title.toUpperCase(),
                style: textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
            ],
          ).animate(delay: animationDelay).fadeIn(duration: 300.ms),

          const SizedBox(height: 14),

          // Chips wrap
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: category.options.map<Widget>((option) {
              final isSelected = selectedIds.contains(option.id);
              return _ChipTile(
                label: option.label,
                isSelected: isSelected,
                onTap: () => onToggle(option.id),
                delay: animationDelay + 60.ms,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual chip tile
// ---------------------------------------------------------------------------

class _ChipTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration delay;

  const _ChipTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primaryRaspberry : AppColors.surfacePlum,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryRaspberry
                : AppColors.surfacePlumLight,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryRaspberry.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ).animate(delay: delay).fadeIn(duration: 300.ms).scale(
            begin: const Offset(0.92, 0.92),
            end: const Offset(1, 1),
            duration: 250.ms,
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error + Retry widget
// ---------------------------------------------------------------------------

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
