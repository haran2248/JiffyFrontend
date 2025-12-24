# Jiffy Frontend Development Guidelines

This document outlines architectural standards, state management patterns, and testing strategies for Jiffy. Follow these guidelines to ensure consistency across features.

## 1. Feature-First Architecture

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

## 2. State Management (Riverpod)

We use **Riverpod** with **Code Generation**.

- **Notifiers**: Use `@riverpod` annotation on classes extending `_$[ClassName]`.
- **Immutable State**: Use `copyWith` for all state updates.
- **Validation**: Place validation logic (like `isFormValid`) inside the model class.

### Development Commands
- **Watch mode (re-build on save)**: 
  `dart run build_runner watch --delete-conflicting-outputs`
- **Single build**: 
  `dart run build_runner build --delete-conflicting-outputs`

## 3. UI & Design System

### Design Tokens
Always use tokens from `lib/core/theme/`:
- **Colors**: `AppColors.[ColorName]` (e.g., `primaryRaspberry`). **No hardcoded hex.**
- **Typography**: `Theme.of(context).textTheme.[StyleName]`.

### Shared Widgets
Reuse components from `lib/presentation/widgets/`:
- `Button`, `Input`, `Avatar`, `ProgressBar`, `ChatBubble`, `Chip`, `DatePickerField`, `OptionPickerField`.

## 4. Testing & Regression

### Test Commands
- **Run all tests**: `flutter test`
- **Run specific file**: `flutter test test/[file_name]_test.dart`
- **Re-install dependencies**: `flutter pub get`
- **Check for lints**: `flutter analyze`

### Widget Testing Standards
- **Feature Coverage**: Every feature folder should have a test in `test/`.
- **Full Flow Simulation**: Simulate user input, navigation, and validation.
- **Verification**: Verify both success and failure (disabled button) states.
- **Setup**: Always wrap test widgets with `ProviderScope`.

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

## 5. Deployment & Maintenance Checklist
- [ ] Run `flutter test` to ensure no regressions.
- [ ] Run `flutter analyze` to ensure no lint errors.
- [ ] Ensure `DEVELOPMENT_GUIDELINE.md` is followed for new features.
