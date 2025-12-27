# Scripts

## regenerate.sh

Main script to regenerate code and update dependencies. Use this after:
- Updating packages
- Switching branches  
- Modifying `@riverpod` annotated code

**Usage:**
```bash
./scripts/regenerate.sh
```

This script will:
1. Update Flutter dependencies (`flutter pub get`)
2. Regenerate code with build_runner
3. Update iOS CocoaPods dependencies

**Note:** We use `dependency_overrides` in `pubspec.yaml` to force `riverpod: 3.1.0`, which is required by `riverpod_generator 4.0.0`.

**Technical Details:**
- **Method signature:** `element.handleCreate(ref, build)` 
- **Location:** `$ClassProviderElement.handleCreate` in riverpod 3.1.0's `lib/src/core/provider/notifier_provider.dart`
- **Method definition:** `void handleCreate(Ref ref, CreatedT Function() created)`
- **Verification:** 
  - Generated code: Check any `.g.dart` file in `lib/presentation/screens/*/viewmodels/` - you'll see `element.handleCreate(ref, build)` in the `runBuild()` method (e.g., `home_viewmodel.g.dart` line 59)
  - Source code: The method exists in `riverpod 3.1.0` but not in `riverpod 3.0.3`

This override is necessary because `riverpod_annotation 3.0.3` pins `riverpod: 3.0.3`, while `riverpod_generator 4.0.0` expects riverpod 3.1.0. Once `riverpod_annotation 3.1.0` is released, this override can be removed.

