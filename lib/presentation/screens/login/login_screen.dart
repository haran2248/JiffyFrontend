import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/auth/auth_viewmodel.dart';
import '../../../core/config/signin_toggle_provider.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/navigation_service.dart';
import 'widgets/login_branding_widget.dart';
import 'widgets/login_error_message_widget.dart';
import 'widgets/login_terms_text_widget.dart';
import 'widgets/social_sign_in_button_widget.dart';

/// Login screen with Google and Apple Sign-In options.
///
/// Follows the "Midnight Luxe" design system:
/// - Premium, exclusive, warm aesthetic
/// - Deep Raspberry & Royal Violet gradient accents
/// - Midnight Plum background
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Watch the sign-in toggle config from Firestore
    final signinToggleAsync = ref.watch(signinToggleConfigProvider);
    final signinToggle =
        signinToggleAsync.valueOrNull ?? const SigninToggleConfig();

    // Listen for auth state changes and navigate
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.isAuthenticated && !(previous?.isAuthenticated ?? false)) {
        // User just authenticated - navigate to onboarding
        context.goToRoute(AppRoutes.onboardingBasics);
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo and branding
              const LoginBranding(),

              const Spacer(flex: 3),

              // Error message
              if (authState.errorMessage != null)
                LoginErrorMessage(
                  message: authState.errorMessage!,
                  onDismiss: () {
                    ref.read(authViewModelProvider.notifier).clearError();
                  },
                ),

              // Sign-in buttons
              _buildSignInButtons(context, ref, authState, signinToggle),

              const SizedBox(height: 32),

              // Terms and privacy
              const LoginTermsText(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButtons(
    BuildContext context,
    WidgetRef ref,
    authState,
    SigninToggleConfig signinToggle,
  ) {
    final isAnyLoading = authState.isLoading;

    // Determine if Apple sign-in should be shown:
    // 1. Must be on iOS (platform requirement)
    // 2. Must be enabled in Firestore config
    final showAppleSignIn = !kIsWeb && Platform.isIOS && signinToggle.apple;

    return Column(
      children: [
        // Google Sign-In button
        SocialSignInButton(
          text: 'Continue with Google',
          icon: const FaIcon(
            FontAwesomeIcons.google,
            size: 20,
            color: Color(0xFF4285F4),
          ),
          isLoading: authState.isGoogleLoading,
          isDisabled: isAnyLoading && !authState.isGoogleLoading,
          onTap: () async {
            if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
              HapticFeedback.lightImpact();
            }
            await ref.read(authViewModelProvider.notifier).signInWithGoogle();
          },
        ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(begin: 0.2),

        const SizedBox(height: 16),

        // Apple Sign-In button (iOS only + config enabled)
        if (showAppleSignIn)
          SocialSignInButton(
            text: 'Continue with Apple',
            icon: const Icon(Icons.apple, color: Colors.white, size: 24),
            isLoading: authState.isAppleLoading,
            isDisabled: isAnyLoading && !authState.isAppleLoading,
            isDark: true,
            onTap: () async {
              HapticFeedback.lightImpact();
              await ref.read(authViewModelProvider.notifier).signInWithApple();
            },
          )
              .animate()
              .fadeIn(delay: 700.ms, duration: 400.ms)
              .slideY(begin: 0.2),
      ],
    );
  }
}
