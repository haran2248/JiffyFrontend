# Jiffy Frontend Linter Guidelines

> **🤖 LLMs: Jump to ["For LLMs: Quick Reference"](#-for-llms-quick-reference) section for critical rules and patterns.**

This document provides comprehensive guidelines for writing code that passes `flutter analyze` without warnings or errors. Follow these patterns to reduce review cycles and ensure code quality.

**Related Documents:**
- `DEVELOPMENT_GUIDELINES.md` - Architecture, patterns, and project structure
- `DESIGN_SYSTEM.md` - Design tokens and visual guidelines

**Focus of this document:** Code syntax, deprecation fixes, linter rules, and quick fixes.

---

## 🤖 For LLMs: Quick Reference

**Read this section first when generating Flutter code for this project.**

### Critical Rules (Must Follow)
1. **Color Opacity**: Always use `color.withValues(alpha: 0.5)` NOT `color.withOpacity(0.5)`
2. **ColorScheme**: Always use `const ColorScheme.dark()` NOT `ColorScheme.dark()`
3. **ColorScheme Property**: Use `surfaceContainerHighest` NOT `surfaceVariant`
4. **Colors in Widgets**: Use `Theme.of(context).colorScheme.primary` NOT `AppColors.primaryRaspberry`
5. **Const Constructors**: Add `const` when all parameters are compile-time constants
6. **Platform Code**: Always guard with `if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))`
7. **No Hide Imports**: Never use `hide WidgetName` - rename the widget instead
8. **Print Statements**: Use `debugPrint()` NOT `print()`
9. **Variables**: Use `final` instead of `var` when value doesn't change

### Quick Code Patterns

**Color with Opacity:**
```dart
// ❌ WRONG
Colors.white.withOpacity(0.2)
// ✅ CORRECT
Colors.white.withValues(alpha: 0.2)
```

**ColorScheme:**
```dart
// ❌ WRONG
ColorScheme.dark().copyWith(surfaceVariant: color)
// ✅ CORRECT
const ColorScheme.dark().copyWith(surfaceContainerHighest: color)
```

**Colors in Widgets:**
```dart
// ❌ WRONG
Container(color: AppColors.primaryRaspberry)
// ✅ CORRECT
Container(color: Theme.of(context).colorScheme.primary)
```

**Platform Guards:**
```dart
// ❌ WRONG
HapticFeedback.lightImpact()
// ✅ CORRECT
if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
  HapticFeedback.lightImpact();
}
```

**Const Usage:**
```dart
// ❌ WRONG
EdgeInsets.all(16)
// ✅ CORRECT
const EdgeInsets.all(16)
```

### Before Generating Code
- Check for `withOpacity` usage → replace with `withValues(alpha:)`
- Check for `surfaceVariant` → replace with `surfaceContainerHighest`
- Check for missing `const` on constructors
- Check for `AppColors` in widgets → replace with `colorScheme`
- Check for unguarded platform code

**For detailed examples and edge cases, see sections below.**

---

## Table of Contents
1. [Deprecation Fixes](#deprecation-fixes)
2. [Code Style Rules](#code-style-rules)
3. [Flutter-Specific Patterns](#flutter-specific-patterns)
4. [Common Issues & Solutions](#common-issues--solutions)
5. [Pre-Commit Checklist](#pre-commit-checklist)

---

## Deprecation Fixes

> **See ["For LLMs: Quick Reference"](#-for-llms-quick-reference) section above for critical deprecation patterns and code examples.**

### Additional Context

**Common Locations for Opacity Fixes:**
- BoxShadow colors
- Border colors
- Splash/highlight colors
- Text opacity
- Container backgrounds with opacity

**Why These Changes?**
- `withValues()` provides better precision and avoids floating-point errors
- Material 3 updated color scheme semantics for better consistency
- `const` constructors improve performance and enable compile-time optimization

---

## Code Style Rules

> **See ["For LLMs: Quick Reference"](#-for-llms-quick-reference) section above for critical code style rules (print/debugPrint, final/var).**

### Additional Style Notes

**Quotes:** This project uses double quotes for consistency with Flutter conventions (single quotes are disabled in `analysis_options.yaml`).

**Why These Rules?**
- `debugPrint()` is throttled and prevents performance issues in production
- `final` prevents accidental reassignment and makes intent clear

---

## Flutter-Specific Patterns

> **See ["For LLMs: Quick Reference"](#-for-llms-quick-reference) section above for color usage patterns and code examples.**

### Additional Notes

**Exception:** `AppColors` is acceptable ONLY in `app_theme.dart` for theme configuration.

**For architecture patterns and design system guidelines, see `DEVELOPMENT_GUIDELINES.md`.**

---

### 2. Const Widgets (Performance & Linter)

**✅ Use const when possible**
```dart
const SizedBox(height: 16)
const EdgeInsets.all(20)
const Text('Static text')
const Icon(Icons.home)
```

**Benefits:**
- Better performance (widgets are reused)
- Clearer intent (value won't change)
- Compile-time optimization

**When NOT to use const:**
- When using `Theme.of(context)` or other runtime values
- When widget depends on instance variables
- When using `Builder` or context-dependent widgets

---

### 3. Import Organization

**✅ Good Order**
```dart
// 1. Dart core
import 'dart:io';
import 'dart:ui';

// 2. Flutter packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages
import 'package:flutter_animate/flutter_animate.dart';

// 4. Project imports (relative)
import '../../core/theme/app_colors.dart';
import '../widgets/button.dart';
```

**Rules:**
- Group imports by type
- Use relative imports for project files
- **Never use `hide` imports** - rename widgets instead (see `DEVELOPMENT_GUIDELINES.md` for naming conventions)

---

## Common Issues & Solutions

### Issue 1: Missing `onPrimary` in ColorScheme

**Problem:**
```
Button text color uses Colors.white but should use colorScheme.onPrimary
```

**Solution:**
```dart
// In app_theme.dart
colorScheme: const ColorScheme.light(
  primary: AppColors.primaryRaspberry,
  onPrimary: AppColors.textPrimary, // ← Add this
  // ...
)

// In widget
Color _getTextColor(BuildContext context) {
  return Theme.of(context).colorScheme.onPrimary; // ← Use this
}
```

---

### Issue 2: Animation Timers in Tests

**Problem:**
```
A Timer is still pending even after the widget tree was disposed.
```

**Solution:**
```dart
// Use pump() instead of pumpAndSettle() for animated widgets
await tester.tap(find.text('Button'));
await tester.pump(); // ← Not pumpAndSettle()

// This is expected with flutter_animate - timers are harmless
```

**Why?** `flutter_animate` creates continuous animations. `pump()` processes events without waiting for animations to complete.

---

### Issue 3: Platform-Specific Code

> **See ["For LLMs: Quick Reference"](#-for-llms-quick-reference) section above for platform guard code pattern.**

**For more on platform code patterns, see `DEVELOPMENT_GUIDELINES.md` section 6.**

---

### Issue 4: Generated Files

> **See ["For LLMs: Quick Reference"](#-for-llms-quick-reference) section in `DEVELOPMENT_GUIDELINES.md` for generated files rules.**

**If you see manual edits, revert them immediately.**

**For more on generated files, see `DEVELOPMENT_GUIDELINES.md` section 6.**

---

## Pre-Commit Checklist

Before committing code, run these checks:

### 1. Run Flutter Analyze
```bash
flutter analyze
```

**Expected Output:**
```
Analyzing JiffyFrontend...
No issues found! (ran in X.Xs)
```

**If issues found:**
- Fix all `deprecated_member_use` warnings
- Fix all `prefer_const_constructors` warnings
- Fix all errors

### 2. Check for Common Patterns

**Search for deprecated patterns:**
```bash
# Find withOpacity usage
grep -r "\.withOpacity(" lib/

# Find surfaceVariant usage
grep -r "surfaceVariant" lib/

# Find hide imports (should be none)
grep -r "hide " lib/
```

### 3. Verify Tests Pass
```bash
flutter test
```

**Note:** Timer warnings from `flutter_animate` are expected and harmless.

### 4. Quick Fix Commands

**Auto-fix const issues:**
```bash
dart fix --apply
```

**This will automatically fix:**
- Missing const constructors
- Some style issues
- Simple deprecations

---

## AI Code Generation Guidelines

> **See ["For LLMs: Quick Reference"](#-for-llms-quick-reference) section at the top of this document for all critical patterns and code examples.**

**When generating code with AI, reference the LLM section which contains:**
- All critical rules and patterns
- Before/after code examples
- Pre-generation checklist
- Quick reference patterns

---

## Linter Configuration

The project uses `analysis_options.yaml` with the following enabled rules:

### Enabled Rules
- `prefer_const_constructors` - Enforces const constructors
- `prefer_const_literals_to_create_immutables` - Const for immutable collections
- `prefer_final_fields` - Use final for fields that don't change
- `prefer_final_locals` - Use final for local variables that don't change
- `avoid_print` - Use `debugPrint` instead of `print`
- `avoid_unnecessary_containers` - Prefer SizedBox or other widgets
- `use_key_in_widget_constructors` - Require keys in constructors
- `prefer_is_empty` / `prefer_is_not_empty` - Better null/empty checks

### Deprecation Warnings
Deprecation warnings (like `withOpacity`, `surfaceVariant`) are automatically detected by the analyzer. They appear as `info` level warnings and should always be fixed.

**To see all enabled rules:**
```bash
cat analysis_options.yaml
```

---

## Additional Resources

- [Flutter Lints Documentation](https://dart.dev/lints)
- [Flutter Analysis Options](https://dart.dev/guides/language/analysis-options)
- [Material 3 Color System](https://m3.material.io/styles/color/the-color-system/color-roles)
- [Flutter Deprecation Guide](https://docs.flutter.dev/release/breaking-changes)

---

## Questions?

If you encounter a linter warning not covered here:
1. Check the error message for the rule name
2. Search [Dart Lints](https://dart.dev/lints) for the rule
3. Update this document with the solution
4. Share with the team

**Remember:** The goal is zero warnings from `flutter analyze`. Every warning is a potential issue that should be addressed.

