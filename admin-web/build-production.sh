#!/bin/bash

# Production Build Script for Admin Web App
# Run this script to build a production-ready web app

echo "🚀 Starting Admin Web App Production Build..."
echo "============================================="

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf dist node_modules/.cache

# Install dependencies
echo "📦 Installing dependencies..."
npm ci --production=false

# Run linting
echo "🔍 Running linting..."
npm run lint

# Set production environment
echo "🔧 Setting production environment..."
export NODE_ENV=production

# Build for production
echo "🏗️  Building for production..."
npm run build

# Check build size
echo "📊 Analyzing build size..."
du -sh dist/*

echo "✅ Production build completed!"
echo ""
echo "📁 Build output: dist/"
echo ""
echo "🌐 Deploy to web server:"
echo "   1. Upload the 'dist' folder contents to your web server"
echo "   2. Configure your web server for SPA routing"
echo "   3. Set up SSL certificate" 
echo "   4. Configure CORS if needed"
echo ""
echo "🔥 Firebase Hosting deployment:"
echo "   firebase deploy --only hosting"