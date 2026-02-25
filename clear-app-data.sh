#!/bin/bash

echo "🧹 Clearing Flutter app data..."

# Clear Flutter build cache
echo "📦 Cleaning build cache..."
flutter clean

# Clear app data on connected device
echo "📱 Clearing app data on device..."
adb shell pm clear com.oroud.app 2>/dev/null || echo "   (Device not connected or app not installed)"

echo "✅ App data cleared!"
echo "🚀 Now run: flutter run"
