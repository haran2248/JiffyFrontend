import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/auth/auth_viewmodel.dart';
import '../../../core/config/signin_toggle_provider.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/services/phone_verification_service.dart';
import '../../../core/services/profile_service.dart';
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
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Flag to prevent duplicate navigations
  bool _hasNavigated = false;

  /// Handle post-login navigation based on phone verification and onboarding status.
  /// Returns true if navigation was initiated, false otherwise.
  Future<bool> _handlePostLoginNavigation(
    BuildContext context,
    WidgetRef ref,
    String? userId,
  ) async {
    if (userId == null) {
      // No user ID means not authenticated - stay on login screen
      debugPrint('LoginScreen: No userId, cannot proceed with navigation');
      return false;
    }

    try {
      // First, ensure user exists in backend (create if needed)
      // This handles the case where Firebase Auth has a session but MongoDB doesn't have the user
      final authRepo = ref.read(authRepositoryProvider);
      try {
        await authRepo.verifyTokenWithBackend();
        debugPrint('LoginScreen: User verified/created in backend');
      } catch (e) {
        debugPrint('LoginScreen: Backend verification failed: $e');
        // If backend verification fails, sign out and stay on login screen
        // This clears the stale Firebase session
        debugPrint('LoginScreen: Signing out stale session and staying on login');
        await authRepo.signOut();
        _hasNavigated = false;
        return false; // Stay on login screen
      }

      // Get the onboarding step the user needs to complete
      final profileService = ref.read(profileServiceProvider);
      final step = await profileService.getOnboardingStep(userId);

      if (!mounted) return false;

      if (step == null) {
        // User is fully onboarded - go directly to home
        debugPrint('LoginScreen: User fully onboarded, going to home');
        context.goToRoute(AppRoutes.home);
        return true;
      }

      // Check phone verification status
      final phoneService = ref.read(phoneVerificationServiceProvider);
      final isVerified = await phoneService.isPhoneVerified(uid: userId);

      if (!mounted) return false;

      // User exists but phone not verified
      if (!isVerified) {
        debugPrint('LoginScreen: Phone not verified, going to verification');
        context.goToRoute(AppRoutes.phoneVerification);
        return true;
      }

      // Phone is verified, route to the appropriate onboarding step
      if (step == 'basics') {
        debugPrint('LoginScreen: Phone verified, needs basics onboarding');
        context.goToRoute(AppRoutes.onboardingBasics);
      } else if (step == 'chat') {
        debugPrint('LoginScreen: Basics done, needs chat onboarding');
        // Check if user has already started chat onboarding (CONTEXT_STORED or ANSWERS_STORED)
        // If so, skip intro and go directly to profile setup
        final onboardingStatus = await profileService.getOnboardingStatus(userId);
        final hasStartedChat = onboardingStatus == 'CONTEXT_STORED' ||
            onboardingStatus == 'ANSWERS_STORED';
        
        if (hasStartedChat) {
          debugPrint('LoginScreen: User has already started chat onboarding (status: $onboardingStatus), going directly to profile setup');
          context.goToRoute(AppRoutes.onboardingProfileSetup);
        } else {
          debugPrint('LoginScreen: User needs to see co-pilot intro first (status: $onboardingStatus)');
          context.goToRoute(AppRoutes.onboardingCoPilotIntro);
        }
      } else {
        // Unknown step, default to basics
        debugPrint('LoginScreen: Unknown step "$step", defaulting to basics');
        context.goToRoute(AppRoutes.onboardingBasics);
      }
      return true;
    } catch (e) {
      debugPrint('LoginScreen: Error checking user status: $e');
      // On error, go to phone verification to be safe
      if (mounted) {
        context.goToRoute(AppRoutes.phoneVerification);
        return true;
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    // Watch the sign-in toggle config from Firestore
    final signinToggleAsync = ref.watch(signinToggleConfigProvider);
    final signinToggle = signinToggleAsync.value ?? const SigninToggleConfig();

    // Listen for auth state changes and navigate.
    // This handles both fresh sign-ins AND session restoration from Firebase.
    ref.listen(authViewModelProvider, (previous, next) {
      // Check if we effectively just finished authentication or loading
      final wasNotAuthenticated = !(previous?.isAuthenticated ?? false);
      final wasLoading = (previous?.isGoogleLoading ?? false) ||
          (previous?.isAppleLoading ?? false);

      // Trigger navigation if:
      // 1. We just became authenticated
      // 2. OR we finished a loading operation (e.g. Google Sign-In finished) and are authenticated
      // 3. AND we haven't already navigated
      if (next.isAuthenticated && (wasNotAuthenticated || wasLoading)) {
        debugPrint(
            'LoginScreen: Auth state change detected. Authenticated: ${next.isAuthenticated}, Was loading: $wasLoading');

        if (!_hasNavigated) {
          // Set flag before async call to prevent duplicate attempts,
          // but reset if navigation fails
          _hasNavigated = true;
          _handlePostLoginNavigation(context, ref, next.userId).then((success) {
            if (!success && mounted) {
              _hasNavigated = false;
            }
          });
        }
      }
    });

    // Check for existing session on initial build
    // Only schedule if we haven't navigated yet and conditions are met
    if (!_hasNavigated && authState.isAuthenticated && !authState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Double check inside callback to be safe
        if (!_hasNavigated && mounted) {
          debugPrint(
              'LoginScreen: Found existing authenticated session. Navigating...');
          // Set flag before async call to prevent duplicate attempts,
          // but reset if navigation fails
          _hasNavigated = true;
          _handlePostLoginNavigation(context, ref, authState.userId)
              .then((success) {
            if (!success && mounted) {
              _hasNavigated = false;
            }
          });
        }
      });
    }

    // If already authenticated, show loading state instead of login UI
    // This prevents the login screen from flashing while checking onboarding status
    if (authState.isAuthenticated || _hasNavigated) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Semantics(
          label: 'Loading, please wait',
          child: Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Circular loading indicator around the logo
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: colorScheme.primary.withValues(alpha: 0.6),
                      backgroundColor:
                          colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  // Jiffy logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
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
