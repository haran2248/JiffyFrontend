# Jiffy Frontend

Flutter frontend application for Jiffy AI app.

## Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (included with Flutter)
- Android Studio / Xcode (for emulators)
- Android SDK (for Android development)
- CocoaPods (for iOS development)

## Setup

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. For iOS, install CocoaPods dependencies:
   ```bash
   cd ios
   pod install
   cd ..
   ```

## Running the App

### Android Emulator
```bash
flutter run
```

Make sure you have an Android emulator running or device connected.

### iOS Simulator
```bash
flutter run -d ios
```

Make sure you have an iOS simulator available or device connected.

## Project Structure

- `lib/main.dart` - Main application entry point
- `android/` - Android platform-specific configuration
- `ios/` - iOS platform-specific configuration
