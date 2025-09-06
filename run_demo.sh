#!/bin/bash

# Certa-AI Demo Script
# This script helps you run the Certa-AI Notification Fraud Detector

echo "🚀 Certa-AI — Notification Fraud Detector"
echo "=========================================="
echo ""

# Add Flutter to PATH if not already there
if ! command -v flutter &> /dev/null; then
    echo "🔧 Adding Flutter to PATH..."
    export PATH="$PATH:/home/shyamsundar/flutter/bin"
    
    # Verify Flutter is now available
    if ! command -v flutter &> /dev/null; then
        echo "❌ Flutter still not found after adding to PATH"
        echo "Please ensure Flutter is installed at: /home/shyamsundar/flutter/bin/flutter"
        echo ""
        exit 1
    fi
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"
echo ""

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Not in the Certa-AI project directory"
    echo "Please run this script from the project root"
    exit 1
fi

echo "📱 Setting up Certa-AI..."
echo ""

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "✅ Dependencies installed"
echo ""

# Check for connected devices
echo "🔍 Checking for connected devices..."
flutter devices

echo ""
echo "📱 Android Emulators Available:"
flutter emulators

echo ""
echo "🎯 Ready to run!"
echo ""
echo "🚀 Quick Start Options:"
echo ""
echo "1️⃣  Launch Android Emulator:"
echo "   flutter emulators --launch Medium_Phone_API_36.0"
echo "   # or"
echo "   flutter emulators --launch Pixel_9_Pro_XL"
echo ""
echo "2️⃣  Run the App:"
echo "   flutter run"
echo ""
echo "3️⃣  Run on specific device:"
echo "   flutter run -d <device-id>"
echo ""
echo "📋 Setup Checklist:"
echo "  ⚠️  Android device/emulator needed (SMS/notifications don't work on desktop)"
echo "  ✅ SMS permission will be requested on first run"
echo "  ✅ Notification access must be enabled in Android Settings"
echo "  ✅ Internet connection for optional AI analysis"
echo ""
echo "🔒 Privacy Note:"
echo "  This app monitors SMS and notifications for fraud detection."
echo "  All analysis is done locally unless AI backend is configured."
echo "  No personal data is stored or transmitted without consent."
echo ""
echo "Happy coding! 🎉"
