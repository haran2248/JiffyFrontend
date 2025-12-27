/// Centralized route path definitions for the app.
///
/// This file serves as the single source of truth for all route paths.
/// Use these constants instead of hardcoding route strings throughout the app.
class AppRoutes {
  // Root and main navigation
  static const String root = '/';
  static const String home = '/home';

  // Onboarding flow
  static const String onboardingBasics = '/onboarding/basics';
  static const String onboardingCoPilotIntro = '/onboarding/co-pilot-intro';
  static const String onboardingProfileSetup = '/onboarding/profile-setup';
  static const String onboardingPermissions = '/onboarding/permissions';

  // Main app screens (home is defined above in root section)
  // static const String matches = '/matches';
  // static const String messages = '/messages';
  // static const String profile = '/profile';
  // static const String settings = '/settings';

  // Utility/debug screens
  static const String designSystem = '/design-system';
}

/// Route parameters used in dynamic routes.
///
/// Example: '/user/:userId' -> RouteParams.userId
class RouteParams {
  static const String userId = 'userId';
  static const String matchId = 'matchId';
  static const String messageId = 'messageId';
}

/// Query parameters used in routes.
///
/// Example: '/matches?filter=active' -> QueryParams.filter
class QueryParams {
  static const String filter = 'filter';
  static const String tab = 'tab';
  static const String returnTo = 'returnTo';
}
