import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jiffy/presentation/screens/design_system_page.dart';
import 'package:jiffy/presentation/screens/home/home_screen.dart';
import 'package:jiffy/presentation/screens/login/login_screen.dart';
import 'package:jiffy/presentation/screens/splash/splash_screen.dart';
import 'package:jiffy/presentation/screens/onboarding/basics/basics_screen.dart';
import 'package:jiffy/presentation/screens/onboarding/co_pilot_intro/co_pilot_intro_screen.dart';
import 'package:jiffy/presentation/screens/onboarding/permissions/permissions_screen.dart';
import 'package:jiffy/presentation/screens/onboarding/profile_setup/profile_setup_screen.dart';
import 'package:jiffy/presentation/screens/onboarding/preferences/preferred_gender_screen.dart';
import 'package:jiffy/presentation/screens/onboarding/preferences/relationship_goals_screen.dart';
import 'package:jiffy/presentation/screens/profile/profile_view_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';
import 'package:jiffy/presentation/screens/profile/models/profile_data.dart';
import 'package:jiffy/presentation/screens/discover/discover_screen.dart';
import 'package:jiffy/presentation/screens/profile_self/profile_self_screen.dart';
import 'package:jiffy/presentation/screens/profile_curated/profile_curated_screen.dart';
import 'package:jiffy/presentation/screens/phone_verification_ui/phone_number_screen.dart';
import 'package:jiffy/presentation/screens/phone_verification_ui/otp_verification_screen.dart';
import 'package:jiffy/presentation/screens/matches/matches_screen.dart';
import 'package:jiffy/presentation/screens/stories/story_viewer_screen.dart';
import 'package:jiffy/presentation/screens/stories/story_creation_screen.dart';
import 'package:jiffy/presentation/screens/stories/models/story_models.dart';
import '../auth/auth_viewmodel.dart';
import '../auth/auth_state.dart';
import 'app_routes.dart';

part 'app_router.g.dart';

/// Main router provider that configures all routes in the app.
///
/// This router defines the complete screen graph and navigation structure.
/// Use [appRouterProvider] to access the router instance in your widgets.
@riverpod
GoRouter appRouter(Ref ref) {
  // Watch auth state for redirect logic
  final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    // Redirect based on authentication state
    redirect: (context, state) {
      final isAuthUnknown = authState.status == AuthStatus.unknown;
      final isAuthenticated = authState.isAuthenticated;
      final currentPath = state.uri.path;

      // Define route categories
      final isOnSplash = currentPath == AppRoutes.splash;
      final isOnLogin = currentPath == AppRoutes.login;

      // If auth state is unknown (loading), show splash screen
      if (isAuthUnknown) {
        return isOnSplash ? null : AppRoutes.splash;
      }

      // If not authenticated, redirect to login (unless already there)
      if (!isAuthenticated) {
        return isOnLogin ? null : AppRoutes.login;
      }

      // If authenticated and on splash/login, redirect to home
      // (LoginScreen will handle further navigation based on onboarding status)
      if (isAuthenticated && isOnSplash) {
        return AppRoutes.login;
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Root redirect
      GoRoute(
        path: AppRoutes.root,
        redirect: (context, state) => AppRoutes.splash,
      ),

      // Splash screen - shown while checking auth state
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
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

      // Phone verification flow (after Google Auth, before Profile Setup)
      GoRoute(
        path: AppRoutes.phoneVerification,
        name: RouteNames.phoneVerification,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PhoneNumberScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        name: RouteNames.otpVerification,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OtpVerificationScreen(),
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
        path: AppRoutes.onboardingPreferredGender,
        name: 'preferred-gender',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PreferredGenderScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingRelationshipGoals,
        name: 'relationship-goals',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RelationshipGoalsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
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
      // Profile Curated (Review & Finalize) - curated profile review screen
      GoRoute(
        path: AppRoutes.profileCurated,
        name: RouteNames.profileCurated,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileCuratedScreen(),
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
      GoRoute(
        path: AppRoutes.matches,
        name: 'matches',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MatchesScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      GoRoute(
        path: AppRoutes.chat,
        name: RouteNames.chat,
        pageBuilder: (context, state) {
          final userId = state.pathParameters['userId'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          final userName = extra?['name'] ?? 'Chat';
          final userImage = extra?['image'];
          final promptText = extra?['promptText'];

          // Defensive handling: if userId is missing, show error screen
          if (userId.isEmpty) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: Scaffold(
                body: Center(
                  child: Text(
                    'User ID not provided',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            );
          }

          return CustomTransitionPage(
            key: state.pageKey,
            child: ChatScreen(
              otherUserId: userId,
              otherUserName: userName,
              otherUserImage: userImage,
              promptText: promptText,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),

      // Story screens
      GoRoute(
        path: AppRoutes.storyViewer,
        name: RouteNames.storyViewer,
        pageBuilder: (context, state) {
          // Safely extract extra data, falling back to null if type is incorrect
          final extra = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null;

          // Safely extract stories list, validating type
          List<Story>? stories;
          if (extra != null && extra['stories'] is List) {
            try {
              final storiesList = extra['stories'] as List;
              // Validate that all items are Story instances
              if (storiesList.every((item) => item is Story)) {
                stories = storiesList.cast<Story>();
              }
            } catch (_) {
              // Type mismatch, stories remains null
            }
          }

          // Safely extract indices with type validation
          int initialStoryIndex = 0;
          if (extra != null && extra['initialStoryIndex'] != null) {
            final value = extra['initialStoryIndex'];
            if (value is int) {
              initialStoryIndex = value;
            } else if (value is num) {
              initialStoryIndex = value.toInt();
            }
            // If value is not a number, defaults to 0
          }

          int initialContentIndex = 0;
          if (extra != null && extra['initialContentIndex'] != null) {
            final value = extra['initialContentIndex'];
            if (value is int) {
              initialContentIndex = value;
            } else if (value is num) {
              initialContentIndex = value.toInt();
            }
            // If value is not a number, defaults to 0
          }

          if (stories == null || stories.isEmpty) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: Scaffold(
                body: Center(
                  child: Text(
                    'No stories to display',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            );
          }

          return CustomTransitionPage(
            key: state.pageKey,
            child: StoryViewerScreen(
              stories: stories,
              initialStoryIndex: initialStoryIndex,
              initialContentIndex: initialContentIndex,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.storyCreation,
        name: RouteNames.storyCreation,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const StoryCreationScreen(),
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
