#!/bin/bash

# Quick App Runner - assumes app is already built
# Just installs and launches the app on iPhone 16 Pro Max simulator

set -e  # Exit on any error

# Configuration
BUNDLE_ID="com.mrpossible.PossibleJourney"

echo "⚡ Quick App Runner"
echo "==================="

# Find the built app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "PossibleJourney.app" -path "*/Debug-iphonesimulator/*" | grep -v "Index.noindex" | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ Error: Could not find built app. Please run './scripts/run-app.sh' first to build the app."
    exit 1
fi

echo "📦 Found app at: $APP_PATH"

# Boot simulator if not already running
echo "🔧 Ensuring iPhone 16 Pro Max simulator is booted..."
xcrun simctl boot "iPhone 16 Pro Max" 2>/dev/null || echo "Simulator already booted"

# Install the app
echo "📲 Installing app on simulator..."
xcrun simctl install "iPhone 16 Pro Max" "$APP_PATH"

# Launch the app
echo "🎯 Launching PossibleJourney..."
LAUNCH_RESULT=$(xcrun simctl launch "iPhone 16 Pro Max" "$BUNDLE_ID")

echo "✅ App launched successfully! (PID: $LAUNCH_RESULT)"
echo "🎉 PossibleJourney is now running on iPhone 16 Pro Max simulator!"
