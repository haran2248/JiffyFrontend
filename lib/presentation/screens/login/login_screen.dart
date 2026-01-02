import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/auth/auth_viewmodel.dart';
import '../../../core/config/signin_toggle_provider.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/services/phone_verification_service.dart';
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

  /// Handle post-login navigation based on phone verification status.
  Future<void> _handlePostLoginNavigation(
    BuildContext context,
    WidgetRef ref,
    String? userId,
  ) async {
    if (userId == null) {
      // No user ID means not authenticated - stay on login screen
      debugPrint('LoginScreen: No userId, cannot proceed with navigation');
      return;
    }

    try {
      final service = ref.read(phoneVerificationServiceProvider);
      final isVerified = await service.isPhoneVerified(uid: userId);

      if (!context.mounted) return;

      if (isVerified) {
        debugPrint('LoginScreen: Phone already verified, skipping to basics');
        context.goToRoute(AppRoutes.onboardingBasics);
      } else {
        debugPrint('LoginScreen: Phone not verified, going to verification');
        context.goToRoute(AppRoutes.phoneVerification);
      }
    } catch (e) {
      debugPrint('LoginScreen: Error checking verification status: $e');
      // On error, go to verification to be safe
      if (context.mounted) {
        context.goToRoute(AppRoutes.phoneVerification);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    // Watch the sign-in toggle config from Firestore
    final signinToggleAsync = ref.watch(signinToggleConfigProvider);
    final signinToggle = signinToggleAsync.value ?? const SigninToggleConfig();

    // Listen for auth state changes and navigate
    // Navigate when user is authenticated and not loading
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.isAuthenticated && !(previous?.isAuthenticated ?? false)) {
        // User just authenticated - check phone verification status
        _handlePostLoginNavigation(context, ref, next.userId);
      }
    });

    // Check if already authenticated (e.g., returning user with persisted session)
    if (authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handlePostLoginNavigation(context, ref, authState.userId);
      });
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Branding section (logo + tagline)
              const LoginBranding(),

              const Spacer(flex: 3),

              // Error message display
              if (authState.errorMessage != null)
                LoginErrorMessage(
                  message: authState.errorMessage!,
                  onDismiss: () => authViewModel.clearError(),
                ),

              // Sign-in buttons
              Column(
                children: [
                  // Google Sign-In button
                  if (signinToggle.google)
                    SocialSignInButton(
                      text: 'Sign in with Google',
                      icon: const FaIcon(
                        FontAwesomeIcons.google,
                        size: 20,
                      ),
                      isLoading: authState.isGoogleLoading,
                      onTap: () async {
                        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
                          HapticFeedback.mediumImpact();
                        }
                        await authViewModel.signInWithGoogle();
                      },
                    ),

                  if (signinToggle.google && signinToggle.apple)
                    const SizedBox(height: 16),

                  // Apple Sign-In button (iOS only)
                  if (signinToggle.apple && !kIsWeb && Platform.isIOS)
                    SocialSignInButton(
                      text: 'Sign in with Apple',
                      icon: const FaIcon(
                        FontAwesomeIcons.apple,
                        size: 22,
                        color: Colors.white,
                      ),
                      isDark: true,
                      isLoading: authState.isAppleLoading,
                      onTap: () async {
                        HapticFeedback.mediumImpact();
                        await authViewModel.signInWithApple();
                      },
                    ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 400.ms)
                  .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 400.ms),

              const SizedBox(height: 24),

              // Terms text
              const LoginTermsText(),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
