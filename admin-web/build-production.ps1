# Production Build Script for Admin Web App
# Run this script in PowerShell to build a production-ready web app

Write-Host "🚀 Starting Admin Web App Production Build..." -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Test build first
Write-Host "🧪 Running development build test first..." -ForegroundColor Yellow
npm run dev -- --host --build 2>&1 | Out-Null

# Clean previous builds
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
if (Test-Path "dist") { Remove-Item -Path "dist" -Recurse -Force }
if (Test-Path "node_modules\.cache") { Remove-Item -Path "node_modules\.cache" -Recurse -Force }

# Install dependencies
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
npm ci --production=false

if ($LASTEXITCODE -eq 0) {
    # Run linting
    Write-Host "🔍 Running linting..." -ForegroundColor Yellow
    npm run lint

    if ($LASTEXITCODE -eq 0) {
        # Set production environment
        Write-Host "🔧 Setting production environment..." -ForegroundColor Yellow
        $env:NODE_ENV = "production"

        # Build for production
        Write-Host "🏗️  Building for production..." -ForegroundColor Yellow
        npm run build

        if ($LASTEXITCODE -eq 0) {
            # Check build size
            Write-Host "📊 Build completed successfully!" -ForegroundColor Green
            if (Test-Path "dist") {
                $size = (Get-ChildItem -Path "dist" -Recurse | Measure-Object -Property Length -Sum).Sum
                $sizeInMB = [Math]::Round($size / 1MB, 2)
                Write-Host "Build size: $sizeInMB MB" -ForegroundColor Cyan
            }

            Write-Host "✅ Production build completed!" -ForegroundColor Green
            Write-Host ""
            Write-Host "📁 Build output: dist/" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "🌐 Deploy to web server:" -ForegroundColor Yellow
            Write-Host "   1. Upload the 'dist' folder contents to your web server" -ForegroundColor White
            Write-Host "   2. Configure your web server for SPA routing" -ForegroundColor White
            Write-Host "   3. Set up SSL certificate" -ForegroundColor White
            Write-Host "   4. Configure CORS if needed" -ForegroundColor White
            Write-Host ""
            Write-Host "🔥 Firebase Hosting deployment:" -ForegroundColor Yellow
            Write-Host "   firebase deploy --only hosting" -ForegroundColor White
            Write-Host ""
            Write-Host "🔧 Debugging:" -ForegroundColor Yellow
            Write-Host "   - Check browser console for errors" -ForegroundColor White
            Write-Host "   - Debug panel will show Firebase connection status" -ForegroundColor White
            Write-Host "   - Check Network tab for failed requests" -ForegroundColor White
        } else {
            Write-Host "❌ Build failed!" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Linting failed. Fix linting errors first." -ForegroundColor Red
    }
} else {
    Write-Host "❌ Dependency installation failed!" -ForegroundColor Red
}