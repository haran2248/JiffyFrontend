/// Centralized route path definitions for the app.
///
/// This file serves as the single source of truth for all route paths.
/// Use these constants instead of hardcoding route strings throughout the app.
class AppRoutes {
  // Root and main navigation
  static const String root = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String matches = '/matches';

  // Onboarding flow
  static const String onboardingBasics = '/onboarding/basics';
  static const String onboardingCoPilotIntro = '/onboarding/co-pilot-intro';
  static const String onboardingProfileSetup = '/onboarding/profile-setup';
  static const String onboardingPermissions = '/onboarding/permissions';
  static const String phoneVerification = '/onboarding/phone-verification';
  static const String otpVerification = '/onboarding/otp-verification';

  // Main app screens (home is defined above in root section)
  static const String profileView = '/profile/:userId';
  static const String profileSelf = '/profile/self';
  static const String profileCurated = '/onboarding/profile-curated';
  static const String discover = '/discover';
  static const String chat = '/chat/:userId';
  // static const String settings = '/settings';

  // Utility/debug screens
  static const String designSystem = '/design-system';
}

/// Route names used in go_router configuration.
///
/// These correspond to the 'name' parameter in GoRoute definitions.
/// Use these when calling pushNamed, replaceNamed, or goNamed.
class RouteNames {
  static const String basics = 'basics';
  static const String coPilotIntro = 'co-pilot-intro';
  static const String profileSetup = 'profile-setup';
  static const String permissions = 'permissions';
  static const String home = 'home';
  static const String profileView = 'profile-view';
  static const String profileSelf = 'profile-self';
  static const String profileCurated = 'profile-curated';
  static const String phoneVerification = 'phone-verification';
  static const String otpVerification = 'otp-verification';
  static const String discover = 'discover';
  static const String chat = 'chat';
  static const String matches = 'matches';
  static const String designSystem = 'design-system';
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
