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

**Note:** We use `dependency_overrides` in `pubspec.yaml` to force `riverpod: 3.1.0`, which is required by `riverpod_generator 4.0.0` (it generates code that uses `handleCreate` from riverpod 3.1.0). This is necessary because `riverpod_annotation 3.0.3` pins `riverpod: 3.0.3`, but the generator expects 3.1.0.

