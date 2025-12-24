# JiffyFrontend Setup Guide

This guide will help you set up the JiffyFrontend Flutter project on your local machine and run it on iOS and Android emulators.

## Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

1. **Flutter SDK** (>=3.0.0)
   - Download from: https://docs.flutter.dev/get-started/install
   - Verify installation: `flutter doctor`
   - Add Flutter to your PATH

2. **Dart SDK** (included with Flutter)

3. **For Android Development:**
   - Android Studio: https://developer.android.com/studio
   - Android SDK (installed via Android Studio)
   - Android Emulator (set up via Android Studio)
   - Accept Android licenses: `flutter doctor --android-licenses`

4. **For iOS Development (macOS only):**
   - Xcode (latest version from Mac App Store)
   - Xcode Command Line Tools: `xcode-select --install`
   - CocoaPods: `sudo gem install cocoapods`
   - iOS Simulator (included with Xcode)

5. **IDE (Optional but recommended):**
   - VS Code with Flutter extension, or
   - Android Studio with Flutter plugin

## Setup Steps

### 1. Clone the Repository

```bash
cd /path/to/your/workspace
git clone <repository-url>
cd jiffy/JiffyFrontend
```

### 2. Verify Flutter Installation

```bash
flutter doctor
```

This will check your Flutter installation and show any missing dependencies. Fix any issues before proceeding.

### 3. Install Flutter Dependencies

```bash
flutter pub get
```

This installs all the dependencies listed in `pubspec.yaml`.

### 4. iOS Setup (macOS only)

Navigate to the iOS directory and install CocoaPods dependencies:

```bash
cd ios
pod install
cd ..
```

**Note:** If you encounter issues with `pod install`, ensure:
- CocoaPods is installed: `pod --version`
- You're in the `ios` directory
- Xcode is properly installed

### 5. Android Setup

The Android configuration is already set up. However, you may need to:

1. Create a `local.properties` file in `android/` directory (if it doesn't exist):
   ```bash
   # android/local.properties
   sdk.dir=/path/to/your/Android/sdk
   flutter.sdk=/path/to/your/flutter
   ```

   Flutter usually generates this automatically, but you can create it manually if needed.

2. Accept Android licenses (if not already done):
   ```bash
   flutter doctor --android-licenses
   ```

## Running the App

### On Android Emulator

1. **Start Android Emulator:**
   - Open Android Studio
   - Go to Tools → Device Manager
   - Create a new virtual device if needed
   - Start the emulator

   Or via command line:
   ```bash
   emulator -avd <emulator_name>
   ```

2. **Verify device is connected:**
   ```bash
   flutter devices
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

   Or specify Android explicitly:
   ```bash
   flutter run -d <android_device/emulator_id>
   ```

### On iOS Simulator (macOS only)

1. **Start iOS Simulator:**
   - Open Xcode
   - Go to Xcode → Open Developer Tool → Simulator
   - Or via command line:
     ```bash
     open -a Simulator
     ```

2. **Verify device is connected:**
   ```bash
   flutter devices
   ```

3. **Run the app:**
   ```bash
   flutter run -d <ios_device/emulator_id>
   ```

   Or if only iOS simulator is available:
   ```bash
   flutter run
   ```

## Development Commands

### Hot Reload
While the app is running, press `r` in the terminal to hot reload, or `R` for hot restart.

### Build Commands

**Android:**
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

**iOS:**
```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

### Clean Build
If you encounter build issues:
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..  # For iOS
flutter run
```

## Troubleshooting

### Common Issues

1. **"Unable to find the Xcode project" error:**
   ```bash
   cd ios
   pod install
   cd ..
   ```
   If this doesn't work, regenerate iOS files:
   ```bash
   flutter create --platforms=ios .
   ```

2. **CocoaPods installation issues:**
   ```bash
   sudo gem install cocoapods
   pod repo update
   cd ios && pod install && cd ..
   ```

3. **Android build errors:**
   - Ensure Android SDK is properly installed
   - Check `android/local.properties` has correct paths
   - Accept all Android licenses: `flutter doctor --android-licenses`

4. **"No devices found" error:**
   - For Android: Ensure emulator is running or device is connected via USB with USB debugging enabled
   - For iOS: Ensure simulator is running or device is connected and trusted

5. **Flutter doctor issues:**
   Run `flutter doctor -v` for detailed information about what needs to be fixed.

### iOS-Specific Issues

- **Code signing errors:** Open the project in Xcode and configure signing:
  ```bash
  open ios/Runner.xcworkspace
  ```
  Then go to Runner target → Signing & Capabilities → Select your team

- **Pod install warnings:** These are typically harmless, but if you want to fix them, ensure the xcconfig files include CocoaPods configs (already done in this project).

### Android-Specific Issues

- **Gradle build errors:** Try:
  ```bash
  cd android
  ./gradlew clean
  cd ..
  flutter clean
  flutter pub get
  flutter run
  ```

- **SDK version errors:** Check `android/app/build.gradle` for correct `compileSdk` and `minSdk` versions.

## Project Structure

```
JiffyFrontend/
├── lib/
│   └── main.dart          # Main application entry point
├── android/               # Android platform-specific files
├── ios/                   # iOS platform-specific files
├── pubspec.yaml          # Flutter dependencies and configuration
└── analysis_options.yaml # Linting rules
```

## Next Steps

After successfully running the app:

1. Explore the code in `lib/main.dart`
2. Add your own screens and features
3. Install additional packages via `pubspec.yaml`
4. Configure app icons and splash screens
5. Set up Firebase or other services as needed

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Flutter API Reference](https://api.flutter.dev/)

## Getting Help

If you encounter issues not covered here:

1. Run `flutter doctor -v` to diagnose setup issues
2. Check Flutter documentation
3. Search Flutter GitHub issues
4. Ask in Flutter community forums

