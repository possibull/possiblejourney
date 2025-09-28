#!/bin/bash

# PossibleJourney App Runner Script
# Builds and runs the app on iPhone 16 Pro Max simulator

set -e  # Exit on any error

# Configuration
SCHEME="PossibleJourney"
DESTINATION="platform=iOS Simulator,name=iPhone 16 Pro Max"
BUNDLE_ID="com.mrpossible.PossibleJourney"

echo "🚀 PossibleJourney App Runner"
echo "================================"

# Check if we're in the right directory
if [ ! -f "PossibleJourney.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Please run this script from the PossibleJourney project root directory"
    exit 1
fi

echo "📱 Building app for iPhone 16 Pro Max simulator..."

# Build the app
xcodebuild -project PossibleJourney.xcodeproj \
           -scheme "$SCHEME" \
           -destination "$DESTINATION" \
           build

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful!"

# Find the built app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "PossibleJourney.app" -path "*/Debug-iphonesimulator/*" | grep -v "Index.noindex" | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ Error: Could not find built app"
    exit 1
fi

echo "📦 Found app at: $APP_PATH"

# Boot simulator if not already running
echo "🔧 Ensuring iPhone 16 Pro Max simulator is booted..."
xcrun simctl boot "iPhone 16 Pro Max" 2>/dev/null || echo "Simulator already booted"

# Install the app
echo "📲 Installing app on simulator..."
xcrun simctl install "iPhone 16 Pro Max" "$APP_PATH"

if [ $? -ne 0 ]; then
    echo "❌ Installation failed!"
    exit 1
fi

echo "✅ App installed successfully!"

# Launch the app
echo "🎯 Launching PossibleJourney..."
LAUNCH_RESULT=$(xcrun simctl launch "iPhone 16 Pro Max" "$BUNDLE_ID")

if [ $? -ne 0 ]; then
    echo "❌ Launch failed!"
    exit 1
fi

echo "✅ App launched successfully! (PID: $LAUNCH_RESULT)"
echo ""
echo "🎉 PossibleJourney is now running on iPhone 16 Pro Max simulator!"
echo "💡 You can now test the new threshold rule functionality:"
echo "   • Navigate to Program Templates → Create Custom Template"
echo "   • Add a task and set it to 'Growth' type"
echo "   • Select 'Threshold (75 Hard)' from Progress Rule Type"
echo "   • Enter examples like: pages >= 10, duration >= 45, caffeine <= 200"
