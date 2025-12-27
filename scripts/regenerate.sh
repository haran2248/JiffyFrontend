#!/bin/bash

# Regenerate code and update dependencies
# Use this after: updating packages, switching branches, or modifying @riverpod code

set -e

echo "🔄 Updating Flutter dependencies..."
flutter pub get

echo "🔨 Regenerating code..."
flutter pub run build_runner build --delete-conflicting-outputs

echo "📦 Updating iOS dependencies..."
cd ios
pod install
cd ..

echo "✅ Done! You can now run the app."

