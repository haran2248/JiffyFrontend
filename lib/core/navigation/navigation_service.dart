import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigation service providing type-safe navigation methods.
/// 
/// This service wraps go_router's navigation methods with a clean API
/// and provides helper methods for common navigation patterns.
/// 
/// Usage:
/// ```dart
/// // In a widget with BuildContext
/// NavigationService.of(context).push(AppRoutes.onboardingCoPilotIntro);
/// NavigationService.of(context).replace(AppRoutes.onboardingPermissions);
/// NavigationService.of(context).go(AppRoutes.home);
/// ```
class NavigationService {
  final BuildContext context;

  const NavigationService(this.context);

  /// Get NavigationService from context
  static NavigationService of(BuildContext context) {
    return NavigationService(context);
  }

  /// Navigate to a new route (pushes a new route onto the stack).
  /// 
  /// Use this when you want to add a new screen to the navigation stack.
  void push(String route, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters}) {
    final location = _buildLocation(route, pathParameters, queryParameters);
    context.push(location);
  }

  /// Navigate to a named route.
  /// 
  /// Alternative to push using route names instead of paths.
  void pushNamed(String name, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters, Object? extra}) {
    context.pushNamed(
      name,
      pathParameters: pathParameters ?? {},
      queryParameters: queryParameters ?? {},
      extra: extra,
    );
  }

  /// Replace current route with a new one.
  /// 
  /// The current route is removed from the stack and replaced with the new route.
  void replace(String route, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters}) {
    final location = _buildLocation(route, pathParameters, queryParameters);
    context.pushReplacement(location);
  }

  /// Replace current route with a named route.
  void replaceNamed(String name, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters, Object? extra}) {
    context.pushReplacementNamed(
      name,
      pathParameters: pathParameters ?? {},
      queryParameters: queryParameters ?? {},
      extra: extra,
    );
  }

  /// Navigate to a route and clear the entire stack.
  /// 
  /// Use this for navigation after completing flows like onboarding.
  void go(String route, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters}) {
    final location = _buildLocation(route, pathParameters, queryParameters);
    context.go(location);
  }

  /// Navigate to a named route and clear the stack.
  void goNamed(String name, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters, Object? extra}) {
    context.goNamed(
      name,
      pathParameters: pathParameters ?? {},
      queryParameters: queryParameters ?? {},
      extra: extra,
    );
  }

  /// Pop the current route from the stack.
  /// 
  /// Returns true if a route was popped, false if there's nothing to pop.
  bool pop<T>([T? result]) {
    if (context.canPop()) {
      context.pop(result);
      return true;
    }
    return false;
  }

  /// Check if we can pop the current route.
  bool canPop() => context.canPop();

  /// Build location string with path and query parameters.
  String _buildLocation(
    String route,
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
  ) {
    String location = route;

    // Replace path parameters with proper URL encoding
    if (pathParameters != null && pathParameters.isNotEmpty) {
      // Sort by key length (longest first) to avoid partial replacements
      final sortedParams = pathParameters.entries.toList()
        ..sort((a, b) => b.key.length.compareTo(a.key.length));
      
      for (final entry in sortedParams) {
        final encodedValue = Uri.encodeComponent(entry.value);
        // Use word boundaries to avoid partial matches
        location = location.replaceAll(':${entry.key}', encodedValue);
      }
    }

    // Add query parameters, preserving existing ones
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final uri = Uri.parse(location);
      final queryMap = <String, String>{};
      
      // Preserve existing query parameters
      uri.queryParameters.forEach((key, value) {
        queryMap[key] = value;
      });
      
      // Add/override with new query parameters
      queryParameters.forEach((key, value) {
        queryMap[key] = value.toString();
      });
      
      location = uri.replace(queryParameters: queryMap).toString();
    }

    return location;
  }
}

/// Extension methods on BuildContext for convenient navigation.
/// 
/// Usage:
/// ```dart
/// // Simple navigation
/// context.pushRoute(AppRoutes.onboardingCoPilotIntro);
/// context.replaceRoute(AppRoutes.onboardingPermissions);
/// context.goToRoute(AppRoutes.home);
/// context.popRoute();
/// ```
extension NavigationExtension on BuildContext {
  /// Get NavigationService for this context
  NavigationService get navigation => NavigationService.of(this);

  /// Push a new route
  void pushRoute(String route, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters}) {
    NavigationService.of(this).push(route, pathParameters: pathParameters, queryParameters: queryParameters);
  }

  /// Replace current route
  void replaceRoute(String route, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters}) {
    NavigationService.of(this).replace(route, pathParameters: pathParameters, queryParameters: queryParameters);
  }

  /// Navigate and clear stack
  void goToRoute(String route, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters}) {
    NavigationService.of(this).go(route, pathParameters: pathParameters, queryParameters: queryParameters);
  }

  /// Pop current route
  bool popRoute<T>([T? result]) {
    return NavigationService.of(this).pop<T>(result);
  }
}

