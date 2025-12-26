# Jiffy Frontend Development Guidelines

> **🤖 LLMs: Jump to ["For LLMs: Quick Reference"](#-for-llms-quick-reference) section for critical patterns and structure.**

This document outlines architectural standards, state management patterns, and testing strategies for Jiffy. Follow these guidelines to ensure consistency across features.

**Related Documents:**
- `LINTER_GUIDELINES.md` - Code quality, deprecation fixes, and linter rules
- `DESIGN_SYSTEM.md` - Design tokens, colors, and typography
- `lib/core/navigation/README.md` - Navigation framework documentation

---

## 🤖 For LLMs: Quick Reference

**Read this section first when generating Flutter code for this project.**

### Project Structure
- **Feature-based organization**: `lib/presentation/screens/[feature_name]/`
- **State Management**: Riverpod with code generation (`@riverpod` annotation)
- **Widgets**: Shared widgets in `lib/presentation/widgets/`, feature-specific in feature folder

### Critical Patterns

**1. Widget Naming:**
- ❌ Never name widgets same as Flutter widgets (`Card`, `Chip`, `Button`, `Input`)
- ✅ Use prefixes: `SystemCard`, `ThemedInput`, `CustomChip`
- ❌ Never use `hide WidgetName` imports
- ✅ Rename the widget instead

**2. Colors:**
- ❌ Never use `AppColors.*` directly in widgets
- ✅ Always use `Theme.of(context).colorScheme.*`
- ✅ `AppColors` only in `app_theme.dart` for theme configuration

**3. Interactive Widgets:**
- ❌ Never use `GestureDetector` for buttons
- ✅ Always use `Material` + `InkWell` for accessibility

**4. State Management:**
- Use `@riverpod` annotation on classes extending `_$[ClassName]`
- Use `copyWith` for all state updates
- Validation logic goes in model class

**5. Navigation:**
- ❌ Never use `Navigator.push/pop` directly
- ✅ Always use navigation extension methods: `context.pushRoute()`, `context.replaceRoute()`, `context.goToRoute()`, `context.popRoute()`
- ✅ Use route constants from `AppRoutes` class (never hardcode route strings)
- ✅ For modal bottom sheets, `Navigator.pop()` is acceptable (not routing)

**6. Testing:**
- Wrap test widgets with `ProviderScope`
- Use `pump()` not `pumpAndSettle()` for animated widgets
- Test both success and failure states

**7. Generated Files:**
- ❌ Never edit `GeneratedPluginRegistrant.java`
- ❌ Never edit `*.g.dart` or `*.freezed.dart` files
- ✅ Regenerate with `dart run build_runner build`

### Directory Structure Template
```
[feature_name]/
├── [feature_name]_screen.dart     # ConsumerWidget
├── viewmodels/
│   └── [feature_name]_viewmodel.dart   # @riverpod Notifier
├── models/
│   └── [feature_name]_form_data.dart   # Immutable state
└── widgets/
    └── [feature_name]_component.dart
```

### Before Generating Code
- Check widget names don't conflict with Flutter widgets
- Use `colorScheme` not `AppColors` in widgets
- Use `Material` + `InkWell` for interactive elements
- Use navigation extension methods (never `Navigator.push` directly)
- Guard platform-specific code
- Follow feature-first architecture

**For detailed patterns and examples, see sections below. Also check `LINTER_GUIDELINES.md` for code syntax rules.**

---

## 1. Navigation Framework

We use a **lightweight, type-safe navigation framework** built on `go_router` with a clear screen graph definition.

### Quick Navigation Guide

**Always use route constants from `AppRoutes` class:**
```dart
// ✅ Correct
context.pushRoute(AppRoutes.onboardingCoPilotIntro);
context.replaceRoute(AppRoutes.onboardingPermissions);
context.goToRoute(AppRoutes.home);
context.popRoute();

// ❌ Wrong - Never do this
Navigator.of(context).push(MaterialPageRoute(...));
context.push('/onboarding/co-pilot-intro'); // Don't hardcode strings
```

### Navigation Patterns

- **`pushRoute()`** - Add a new screen to the stack (user can go back)
- **`replaceRoute()`** - Swap current screen (no back navigation)
- **`goToRoute()`** - Navigate and clear entire stack (use after completing flows)
- **`popRoute()`** - Go back one screen

### Adding New Routes

1. **Define the route** in `lib/core/navigation/app_routes.dart`:
   ```dart
   static const String myNewScreen = '/my-new-screen';
   ```

2. **Add route configuration** in `lib/core/navigation/app_router.dart`:
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

3. **Regenerate router code**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Navigate to it**:
   ```dart
   context.pushRoute(AppRoutes.myNewScreen);
   ```

### Screen Graph

The complete screen graph is documented in `lib/core/navigation/SCREEN_GRAPH.md`. Current onboarding flow:

```
/onboarding/basics → /onboarding/co-pilot-intro → /onboarding/profile-setup → /onboarding/permissions → /home
```

### Documentation

- **Full Documentation**: See `lib/core/navigation/README.md` for detailed usage, route parameters, and advanced patterns
- **Screen Graph**: See `lib/core/navigation/SCREEN_GRAPH.md` for visual navigation structure

---

## 2. Feature-First Architecture

We organize code by feature. Each major feature resides in `lib/presentation/screens/[feature_name]/`.

### Directory Structure
```
[feature_name]/
├── [feature_name]_screen.dart     # Main UI entry (ConsumerWidget)
├── viewmodels/
│   └── [feature_name]_viewmodel.dart   # Logic & State (Riverpod Notifier)
├── models/
│   └── [feature_name]_form_data.dart   # Immutable state models
└── widgets/
    ├── [feature_name]_step_one.dart    # Private sub-widgets
    └── [feature_name]_component.dart
```

- **Avoid logic in UI**: Logic belongs in the ViewModel.
- **Encapsulate**: Keep feature-specific widgets in the local `widgets/` folder.

---

## 3. State Management (Riverpod)

We use **Riverpod** with **Code Generation**.

- **Notifiers**: Use `@riverpod` annotation on classes extending `_$[ClassName]`.
- **Immutable State**: Use `copyWith` for all state updates.
- **Validation**: Place validation logic (like `isFormValid`) inside the model class.

### Development Commands
- **Watch mode (re-build on save)**: 
  `dart run build_runner watch --delete-conflicting-outputs`
- **Single build**: 
  `dart run build_runner build --delete-conflicting-outputs`

---

## 4. UI & Design System

### Design Tokens
Always use semantic tokens from `Theme.of(context).colorScheme` for colors:
- ✅ **Preferred**: `Theme.of(context).colorScheme.primary` - for primary actions
- ✅ **Preferred**: `Theme.of(context).colorScheme.secondary` - for secondary actions
- ✅ **Preferred**: `Theme.of(context).colorScheme.surface` - for surfaces/cards
- ✅ **Preferred**: `Theme.of(context).colorScheme.onSurface` - for text on surfaces
- ✅ **Preferred**: `Theme.of(context).colorScheme.outline` - for borders/outlines
- ⚠️ **Fallback Only**: `AppColors.[ColorName]` - only in theme definitions (`app_theme.dart`) or when colorScheme doesn't provide the needed semantic color
- ❌ **Never**: Hardcoded hex colors (e.g., `Color(0xFFD81B60)`) in widget code
- **Typography**: Always use `Theme.of(context).textTheme.[StyleName]`.

**Why?** Using `colorScheme` ensures automatic light/dark mode support and theme consistency. `AppColors` should only be used in theme configuration.

**For detailed code patterns and examples, see `LINTER_GUIDELINES.md`.**

### Widget Naming Conventions
> **See ["For LLMs: Quick Reference"](#-for-llms-quick-reference) section above for widget naming rules and patterns.**

- **Shared Widgets**: Reuse components from `lib/presentation/widgets/`:
  - `Button`, `ThemedInput`, `SystemCard`, `Chip`, `Avatar`, `ProgressBar`, `ChatBubble`, `DatePickerField`, `OptionPickerField`.

### Accessibility Requirements
> **See ["For LLMs: Quick Reference"](#-for-llms-quick-reference) section above for interactive widget patterns (Material + InkWell).**

- **Semantic Labels**: Ensure all interactive elements have proper semantics for screen readers.
- **Minimum Tap Target**: 48x48dp minimum for all interactive elements.

---

## 5. Testing & Regression

### Test Commands
- **Run all tests**: `flutter test`
- **Run specific file**: `flutter test test/[file_name]_test.dart`
- **Re-install dependencies**: `flutter pub get`
- **Check for lints**: `flutter analyze` (see `LINTER_GUIDELINES.md`)

### Widget Testing Standards
- **Feature Coverage**: Every feature folder should have a test in `test/`.
- **Full Flow Simulation**: Simulate user input, navigation, and validation.
- **Verification**: Verify both success and failure (disabled button) states.
- **Setup**: Always wrap test widgets with `ProviderScope`.
- **Interactive Widget Tests**: Test button taps, form submissions, and loading states.

#### Example: Multi-step Flow Test Pattern
```dart
testWidgets('[Feature] multi-step flow test', (WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: JiffyApp()));
  await tester.pumpAndSettle();
  // 1. Verify Step 1
  expect(find.text('[Step 1 Title]'), findsOneWidget);
  
  // 2. Perform Interaction
  await tester.enterText(find.byType(TextField), 'Test Value');
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  // 3. Verify Navigation to Step 2
  expect(find.text('[Step 2 Title]'), findsOneWidget);
  
  // 4. Verify State Preservation
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
  expect(find.text('Test Value'), findsOneWidget); 
});
```

**Note:** For animation-related test issues, see `LINTER_GUIDELINES.md` section on "Animation Timers in Tests".

---

## 6. Dependency Management

### Adding Dependencies
- **Before Adding**: Verify the package is actually used in the codebase.
- **Check Usage**: Run `grep -r "package_name" lib/` to ensure it's referenced.
- **Remove Unused**: Regularly audit `pubspec.yaml` and remove unused dependencies.
- **Justification**: If keeping an unused dependency, document why in PR description.

### Common Dependencies
- **State Management**: `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator`
- **Animations**: `flutter_animate` (used for shimmer effects)
- **Fonts**: `google_fonts` (for custom typography)
- **Avoid**: Adding dependencies "just in case" - add when actually needed.

---

## 7. Generated Files & Platform Code

### Never Edit Generated Files
- **Android**: `android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java` - This is auto-generated by Flutter. If you see manual edits, revert them.
- **iOS**: Xcode project files (`*.pbxproj`) - Only edit if you understand CocoaPods integration.
- **Build Runner**: Files with `*.g.dart` or `*.freezed.dart` - Regenerate with `dart run build_runner build`.

### Platform-Specific Code
> **See ["For LLMs: Quick Reference"](#-for-llms-quick-reference) section above for platform guard patterns.**

---

## 8. Theme Consistency

### ColorScheme Configuration
- **Light/Dark Themes**: Always define both `lightTheme` and `darkTheme` in `app_theme.dart`.
- **Required Fields**: Ensure `onPrimary`, `onSurface`, `onSecondary` are defined for proper contrast.
- **Semantic Colors**: Map `AppColors` to `ColorScheme` in theme definition only.
- **Verification**: Test widgets in both light and dark modes to ensure proper contrast.

### Theme Usage in Widgets
> **See ["For LLMs: Quick Reference"](#-for-llms-quick-reference) section above for color usage patterns.**

- **Theme Definition**: Use `AppColors.*` only in `app_theme.dart` to configure `ColorScheme`.
- **Never Mix**: Don't use `AppColors` directly in widget code when `colorScheme` provides the semantic color.

---

## 9. Code Quality & Linting

### Linter Guidelines
**Always refer to `LINTER_GUIDELINES.md` before writing code.** This document contains:
- Common deprecation fixes (`withOpacity` → `withValues`, etc.)
- Code style patterns
- Flutter-specific best practices
- Quick reference for AI code generation
- Detailed pre-commit linter checklist

### Running Linter Checks
```bash
# Check for issues
flutter analyze

# Auto-fix simple issues
dart fix --apply
```

**For complete linter rules and patterns, see `LINTER_GUIDELINES.md`.**

---

## 10. Incremental Development Safeguards

### Pre-Commit Checklist
Before committing changes, verify:
- [ ] `flutter analyze` passes with no errors or warnings (see `LINTER_GUIDELINES.md`)
- [ ] `flutter test` passes (all existing tests + new tests)
- [ ] No manual edits to generated files (`GeneratedPluginRegistrant.java`, `*.g.dart`)
- [ ] Widget names don't conflict with Flutter widgets (no `hide` imports needed)
- [ ] All interactive widgets use `Material` + `InkWell` (not `GestureDetector`)
- [ ] Navigation uses extension methods (`context.pushRoute()`) not `Navigator.push()` directly
- [ ] Route constants from `AppRoutes` are used (no hardcoded route strings)
- [ ] Platform-specific code is properly guarded (see `LINTER_GUIDELINES.md`)
- [ ] Colors use `colorScheme` (not `AppColors` directly) in widgets
- [ ] Unused dependencies removed from `pubspec.yaml`
- [ ] Tests added for new interactive widgets
- [ ] All deprecation warnings fixed (check `LINTER_GUIDELINES.md`)

### Breaking Change Prevention
- **Widget Renames**: If renaming a widget, update all imports and usages:
  ```bash
  # Find all usages
  grep -r "OldWidgetName" lib/
  # Update imports and instantiations
  ```
- **API Changes**: When changing widget APIs, update all usages and add migration notes.
- **Theme Changes**: Test in both light and dark modes after theme modifications.

---

## 11. Known Technical Debt (Incremental Fixes)

These items should be addressed incrementally during feature work:

- **Chip Widget**: Currently uses `hide Chip` import. Should be renamed to `SystemChip` or `ThemedChip` to avoid conflict.
- **Generated Files**: If `GeneratedPluginRegistrant.java` has manual edits, they should be reverted. Flutter tooling handles plugin registration automatically.

**Approach**: Fix these during related feature work, not as separate tasks. This prevents breaking changes and allows incremental improvements.

---

## 12. Deployment & Maintenance Checklist
- [ ] Run `flutter test` to ensure no regressions.
- [ ] Run `flutter analyze` to ensure no lint errors (see `LINTER_GUIDELINES.md`).
- [ ] Verify no generated files were manually edited.
- [ ] Check widget naming doesn't conflict with Flutter widgets (no `hide` imports).
- [ ] Verify accessibility (Material + InkWell for interactive widgets).
- [ ] Test in both light and dark themes.
- [ ] Remove unused dependencies from `pubspec.yaml`.
- [ ] Ensure `DEVELOPMENT_GUIDELINES.md` and `LINTER_GUIDELINES.md` are followed for new features.
- [ ] Review technical debt items and address during feature work.
- [ ] All deprecation warnings fixed (run `dart fix --apply` if needed).

---

## Additional Resources

- `LINTER_GUIDELINES.md` - Code quality and linter rules
- `DESIGN_SYSTEM.md` - Design tokens and visual guidelines
- `lib/core/navigation/README.md` - Navigation framework documentation
- `lib/core/navigation/SCREEN_GRAPH.md` - Visual screen graph
- [Flutter Riverpod Documentation](https://riverpod.dev/)
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [GoRouter Documentation](https://pub.dev/documentation/go_router/latest/)

