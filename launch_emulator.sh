#!/bin/bash

# Android Emulator Launcher for Certa-AI
# This script launches an Android emulator for testing the fraud detector

echo "📱 Launching Android Emulator for Certa-AI..."
echo "=============================================="
echo ""

# Add Flutter to PATH if not already there
if ! command -v flutter &> /dev/null; then
    export PATH="$PATH:/home/shyamsundar/flutter/bin"
fi

echo "🔍 Available Android Emulators:"
flutter emulators

echo ""
echo "🚀 Launching Medium Phone API 36.0 emulator..."
echo "This may take a few minutes on first launch..."
echo ""

flutter emulators --launch Medium_Phone_API_36.0

echo ""
echo "✅ Emulator launched! You can now run:"
echo "   flutter run"
echo ""
echo "📋 Next Steps:"
echo "1. Wait for emulator to fully boot"
echo "2. Run 'flutter run' to install the app"
echo "3. Grant SMS and notification permissions when prompted"
echo "4. Test fraud detection with sample messages"
echo ""
echo "🎉 Happy testing!"

