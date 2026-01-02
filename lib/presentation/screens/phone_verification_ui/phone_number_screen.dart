import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/navigation_service.dart';
import 'viewmodels/phone_verification_viewmodel.dart';
import 'widgets/verification_icon_card.dart';
import 'widgets/phone_input_row.dart';
import 'widgets/info_notice_card.dart';
import 'widgets/verification_primary_button.dart';

/// Phone number entry screen for verification flow.
///
/// Collects user's phone number and sends verification code via API.
/// Navigation: Back → Login, Forward → OTP Verification
class PhoneNumberScreen extends ConsumerWidget {
  const PhoneNumberScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final viewModel = ref.read(phoneVerificationViewModelProvider.notifier);
    final state = ref.watch(phoneVerificationViewModelProvider);

    // Listen for errors
    ref.listen(phoneVerificationViewModelProvider, (previous, next) {
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => context.popRoute(),
                        icon: Icon(
                          Icons.arrow_back,
                          color: colorScheme.onSurface,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Phone icon card with gradient
                    VerificationIconCard(
                      icon: Icons.phone,
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      iconColor: Colors.white,
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Verify Your Phone',
                      style: textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      "We'll send you a verification code to make sure it's really you. Standard message rates may apply.",
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Phone Number label
                    Text(
                      'Phone Number',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Phone input row
                    PhoneInputRow(
                      onChanged: (value) {
                        // Prepend country code if not already present
                        final fullNumber =
                            value.startsWith('+') ? value : '+91$value';
                        viewModel.updatePhoneNumber(fullNumber);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Privacy info card
                    const InfoNoticeCard(
                      emoji: '🔒',
                      text:
                          'Your phone number is kept private and secure. We only use it to verify your account and keep it safe.',
                    ),
                  ],
                ),
              ),
            ),

            // Bottom sticky button
            Padding(
              padding: const EdgeInsets.all(24),
              child: VerificationPrimaryButton(
                text: 'Send Verification Code',
                isEnabled: state.canSendOtp,
                isLoading: state.isSendingOtp,
                onTap: () async {
                  final success = await viewModel.sendVerificationCode();
                  if (success && context.mounted) {
                    context.pushRoute(AppRoutes.otpVerification);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
