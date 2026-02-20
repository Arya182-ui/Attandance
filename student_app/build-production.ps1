# Production Build Script for Student App (Flutter)
# Run this script in PowerShell to build a production-ready APK

Write-Host "🚀 Starting Student App Production Build..." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Clean previous builds
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
flutter pub get

# Run tests
Write-Host "🧪 Running tests..." -ForegroundColor Yellow
flutter test

if ($LASTEXITCODE -eq 0) {
    # Build production APK
    Write-Host "📱 Building production APK..." -ForegroundColor Yellow
    flutter build apk --release --split-per-abi

    # Build App Bundle for Google Play
    Write-Host "📦 Building App Bundle for Google Play..." -ForegroundColor Yellow
    flutter build appbundle --release

    Write-Host "✅ Production build completed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📁 Build outputs:" -ForegroundColor Cyan
    Write-Host "   APK: build/app/outputs/flutter-apk/app-*.apk" -ForegroundColor White
    Write-Host "   Bundle: build/app/outputs/bundle/release/app-release.aab" -ForegroundColor White
    Write-Host ""
    Write-Host "⚠️  REMEMBER:" -ForegroundColor Red
    Write-Host "   1. Update android/app/build.gradle.kts with proper signing config" -ForegroundColor White
    Write-Host "   2. Test the APK on actual devices before deployment" -ForegroundColor White
    Write-Host "   3. Upload the App Bundle (.aab) to Google Play Console" -ForegroundColor White
} else {
    Write-Host "❌ Tests failed. Build aborted." -ForegroundColor Red
}