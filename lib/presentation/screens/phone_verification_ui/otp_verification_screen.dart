import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/navigation_service.dart';
import 'viewmodels/phone_verification_viewmodel.dart';
import 'widgets/verification_icon_card.dart';
import 'widgets/otp_input_boxes.dart';
import 'widgets/info_notice_card.dart';
import 'widgets/resend_code_text.dart';
import 'widgets/verification_primary_button.dart';

/// OTP verification screen for entering the 6-digit code.
///
/// Verifies the OTP code via API.
/// Navigation: Back → Phone Number Screen, Forward → Profile Setup
class OtpVerificationScreen extends ConsumerWidget {
  const OtpVerificationScreen({super.key});

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

    // Format phone number for display
    final displayPhone =
        state.phoneNumber.isNotEmpty ? state.phoneNumber : '+91 98765 43210';

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

                    // Shield icon card (green)
                    const VerificationIconCard(
                      icon: Icons.verified_user,
                      backgroundColor: Color(0xFF4CAF50), // Green
                      iconColor: Colors.white,
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Enter Verification Code',
                      style: textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle with masked phone
                    RichText(
                      text: TextSpan(
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'We sent a 4-digit code to '),
                          TextSpan(
                            text: displayPhone,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // OTP input boxes
                    Center(
                      child: OtpInputBoxes(
                        onCompleted: (code) {
                          viewModel.updateOtpCode(code);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Resend code text with countdown
                    Center(
                      child: state.resendCountdown > 0
                          ? ResendCodeText(seconds: state.resendCountdown)
                          : GestureDetector(
                              onTap: state.canResend
                                  ? () => viewModel.resendCode()
                                  : null,
                              child: Text(
                                'Resend Code',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),

                    // Tip info card
                    const InfoNoticeCard(
                      emoji: '💡',
                      text:
                          'Tip: Check your messages app. The code usually arrives within 30 seconds.',
                    ),
                  ],
                ),
              ),
            ),

            // Bottom sticky button
            Padding(
              padding: const EdgeInsets.all(24),
              child: VerificationPrimaryButton(
                text: 'Verify & Continue',
                isEnabled: state.canVerifyOtp,
                isLoading: state.isVerifyingOtp,
                onTap: () async {
                  final success = await viewModel.verifyOtp();
                  if (success && context.mounted) {
                    context.pushRoute(AppRoutes.onboardingBasics);
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
