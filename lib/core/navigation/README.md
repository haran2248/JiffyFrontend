# Navigation Framework

A lightweight, type-safe navigation framework for the Jiffy app with a clear screen graph definition.

## Overview

This navigation framework provides:
- **Centralized route definitions** - All routes defined in one place (`app_routes.dart`)
- **Clear screen graph** - Easy to visualize and understand the app flow
- **Type-safe navigation** - Use constants instead of magic strings
- **Developer-friendly API** - Simple extension methods on `BuildContext`
- **Riverpod integration** - Router configured as a Riverpod provider

## Architecture

```
lib/core/navigation/
├── app_routes.dart          # Route path constants
├── app_router.dart          # Router configuration & screen graph
├── navigation_service.dart  # Navigation utilities & extensions
└── README.md               # This file
```

## Screen Graph

```
/ (root)
├── /onboarding/basics              → BasicsScreen
│   └── → /onboarding/co-pilot-intro
│       └── → /onboarding/profile-setup
│           └── → /onboarding/permissions
│               └── → /home (after completion)
├── /home                           → HomeScreen (future)
└── /design-system                  → DesignSystemPage
```

## Usage

### Basic Navigation

```dart
import 'package:jiffy/core/navigation/navigation_service.dart';
import 'package:jiffy/core/navigation/app_routes.dart';

// Using extension methods (recommended)
context.pushRoute(AppRoutes.onboardingCoPilotIntro);
context.replaceRoute(AppRoutes.onboardingPermissions);
context.goToRoute(AppRoutes.home);
context.popRoute();

// Using NavigationService
NavigationService.of(context).push(AppRoutes.onboardingCoPilotIntro);
NavigationService.of(context).go(AppRoutes.home);
```

### Named Routes

```dart
// Using route names instead of paths
context.navigation.pushNamed('co-pilot-intro');
context.navigation.goNamed('home');
```

### Adding New Routes

1. **Define the route path** in `app_routes.dart`:
```dart
class AppRoutes {
  static const String myNewScreen = '/my-new-screen';
}
```

2. **Add route configuration** in `app_router.dart`:
```dart
GoRoute(
  path: AppRoutes.myNewScreen,
  name: 'my-new-screen',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: const MyNewScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ),
),
```

3. **Run build_runner** to regenerate router code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Navigate to it**:
```dart
context.pushRoute(AppRoutes.myNewScreen);
```

## Navigation Patterns

### Push (Add to stack)
Use when you want to navigate forward and allow back navigation:
```dart
context.pushRoute(AppRoutes.onboardingCoPilotIntro);
```

### Replace (Swap current screen)
Use when you want to replace the current screen (no back navigation):
```dart
context.replaceRoute(AppRoutes.onboardingPermissions);
```

### Go (Clear stack)
Use after completing flows like onboarding:
```dart
context.goToRoute(AppRoutes.home);
```

### Pop (Go back)
```dart
if (context.canPop()) {
  context.popRoute();
}
```

## Route Parameters

For dynamic routes with parameters:

1. Define in `app_routes.dart`:
```dart
static const String userProfile = '/user/:userId';
```

2. Configure in `app_router.dart`:
```dart
GoRoute(
  path: AppRoutes.userProfile,
  pageBuilder: (context, state) {
    final userId = state.pathParameters['userId']!;
    return CustomTransitionPage(
      key: state.pageKey,
      child: UserProfileScreen(userId: userId),
    );
  },
),
```

3. Navigate with parameters:
```dart
context.pushRoute('/user/123'); // or use pathParameters
```

## Query Parameters

```dart
context.pushRoute(
  AppRoutes.matches,
  queryParameters: {'filter': 'active', 'sort': 'date'},
);
```

Access in the route:
```dart
final filter = state.uri.queryParameters['filter'];
```

## Best Practices

1. **Always use route constants** from `AppRoutes` instead of hardcoded strings
2. **Use named routes** when possible for better refactoring support
3. **Clear the stack** (`go`) when completing major flows (onboarding, login)
4. **Push routes** for flow navigation that allows going back
5. **Replace routes** when you don't want the user to go back to the previous screen

## Integration with Riverpod

The router is provided as a Riverpod provider, so you can:

```dart
final router = ref.watch(appRouterProvider);
MaterialApp.router(
  routerConfig: router,
  // ...
)
```

## Testing

The navigation service can be easily mocked for testing:

```dart
class MockNavigationService extends NavigationService {
  MockNavigationService(super.context);
  // Override methods as needed
}
```

