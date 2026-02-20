#!/bin/bash

# Production Build Script for Student App (Flutter)
# Run this script to build a production-ready APK

echo "🚀 Starting Student App Production Build..."
echo "========================================"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Run tests
echo "🧪 Running tests..."
flutter test

# Build production APK
echo "📱 Building production APK..."
flutter build apk --release --split-per-abi

# Build App Bundle for Google Play
echo "📦 Building App Bundle for Google Play..."
flutter build appbundle --release

echo "✅ Production build completed!"
echo ""
echo "📁 Build outputs:"
echo "   APK: build/app/outputs/flutter-apk/app-*.apk"
echo "   Bundle: build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "⚠️  REMEMBER:"
echo "   1. Update android/app/build.gradle.kts with proper signing config"
echo "   2. Test the APK on actual devices before deployment"
echo "   3. Upload the App Bundle (.aab) to Google Play Console"