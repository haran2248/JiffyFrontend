import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jiffy/presentation/screens/design_system_page.dart';
import 'package:jiffy/presentation/screens/home/home_screen.dart';
import 'package:jiffy/presentation/screens/login/login_screen.dart';
import 'package:jiffy/presentation/screens/onboarding/basics/basics_screen.dart';
import 'package:jiffy/presentation/screens/onboarding/co_pilot_intro/co_pilot_intro_screen.dart';
import 'package:jiffy/presentation/screens/onboarding/permissions/permissions_screen.dart';
import 'package:jiffy/presentation/screens/onboarding/profile_setup/profile_setup_screen.dart';
import 'package:jiffy/presentation/screens/profile/profile_view_screen.dart';
import 'package:jiffy/presentation/screens/profile/models/profile_data.dart';
import 'package:jiffy/presentation/screens/discover/discover_screen.dart';
import 'package:jiffy/presentation/screens/profile_self/profile_self_screen.dart';
import 'app_routes.dart';

part 'app_router.g.dart';

/// Main router provider that configures all routes in the app.
///
/// This router defines the complete screen graph and navigation structure.
/// Use [appRouterProvider] to access the router instance in your widgets.
@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    // Start from login screen
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    routes: [
      // Root redirect
      GoRoute(
        path: AppRoutes.root,
        redirect: (context, state) => AppRoutes.login,
      ),

      // Login screen
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),

      // Onboarding flow - defines the user journey
      GoRoute(
        path: AppRoutes.onboardingBasics,
        name: 'basics',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const BasicsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingCoPilotIntro,
        name: 'co-pilot-intro',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CoPilotIntroScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingProfileSetup,
        name: 'profile-setup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileSetupScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingPermissions,
        name: 'permissions',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PermissionsScreen(),
        ),
      ),

      // Main app screens
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      // Profile Self (Editable View) - user's own profile
      // IMPORTANT: This must come BEFORE profileView to match correctly
      GoRoute(
        path: AppRoutes.profileSelf,
        name: RouteNames.profileSelf,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileSelfScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.profileView,
        name: 'profile-view',
        pageBuilder: (context, state) {
          final profile = state.extra as ProfileData?;
          if (profile == null) {
            // Fallback if no profile data provided
            return CustomTransitionPage(
              key: state.pageKey,
              child: Scaffold(
                body: Center(
                  child: Text(
                    'Profile not found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            );
          }
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProfileViewScreen(profile: profile),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.discover,
        name: 'discover',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DiscoverScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Utility screens
      GoRoute(
        path: AppRoutes.designSystem,
        name: 'design-system',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DesignSystemPage(),
        ),
      ),
    ],
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Custom page with transition support
class CustomTransitionPage<T> extends Page<T> {
  final Widget child;
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) transitionsBuilder;

  const CustomTransitionPage({
    required LocalKey key,
    required this.child,
    this.transitionsBuilder = _defaultTransitionsBuilder,
  }) : super(key: key);

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: transitionsBuilder,
    );
  }

  static Widget _defaultTransitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}
