#!/bin/bash

# Build script with temporary file error handling
# Usage: ./build-with-tmp.sh [scheme] [configuration]

# Set default values
SCHEME=${1:-"PossibleJourney"}
CONFIGURATION=${2:-"Debug"}
PROJECT_NAME="PossibleJourney"

# Create temporary directory for build artifacts
TMP_DIR="/tmp/possiblejourney-build-$(date +%Y%m%d-%H%M%S)"
BUILD_LOG="$TMP_DIR/build.log"
ERROR_LOG="$TMP_DIR/errors.log"
WARNING_LOG="$TMP_DIR/warnings.log"
SUCCESS_LOG="$TMP_DIR/success.log"

echo "🚀 Starting build with temporary file logging..."
echo "📁 Temporary directory: $TMP_DIR"
echo "📋 Scheme: $SCHEME"
echo "⚙️  Configuration: $CONFIGURATION"

# Create temporary directory
mkdir -p "$TMP_DIR"

# Function to clean up temporary files
cleanup() {
    echo "🧹 Cleaning up old temporary files..."
    # Keep logs for 24 hours, then clean up
    find /tmp -name "possiblejourney-build-*" -type d -mtime +1 -exec rm -rf {} \; 2>/dev/null || true
    echo "📁 Current build logs preserved in: $TMP_DIR"
}

# Function to display build results
show_results() {
    echo ""
    echo "📊 BUILD RESULTS:"
    echo "=================="
    
    if [ -f "$SUCCESS_LOG" ]; then
        echo "✅ BUILD SUCCESSFUL"
        echo "📄 Success log: $SUCCESS_LOG"
    fi
    
    if [ -f "$ERROR_LOG" ] && [ -s "$ERROR_LOG" ]; then
        echo "❌ BUILD ERRORS FOUND"
        echo "📄 Error log: $ERROR_LOG"
        echo ""
        echo "🔍 LAST 10 ERRORS:"
        echo "------------------"
        tail -10 "$ERROR_LOG"
    fi
    
    if [ -f "$WARNING_LOG" ] && [ -s "$WARNING_LOG" ]; then
        echo "⚠️  BUILD WARNINGS FOUND"
        echo "📄 Warning log: $WARNING_LOG"
        echo ""
        echo "🔍 LAST 10 WARNINGS:"
        echo "---------------------"
        tail -10 "$WARNING_LOG"
    fi
    
    echo ""
    echo "📁 All logs available in: $TMP_DIR"
    echo "💡 To view full logs:"
    echo "   cat $BUILD_LOG"
    echo "   cat $ERROR_LOG"
    echo "   cat $WARNING_LOG"
}

# Set up trap to clean up on exit
trap cleanup EXIT

# Build the project with detailed logging
echo "🔨 Building $PROJECT_NAME.xcodeproj..."
echo "⏰ Build started at: $(date)"

# Build command with comprehensive logging
xcodebuild \
    -project "$PROJECT_NAME.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "platform=iOS Simulator,name=iPhone 16" \
    build \
    2>&1 | tee "$BUILD_LOG"

# Capture build result
BUILD_EXIT_CODE=${PIPESTATUS[0]}

# Parse build log for errors and warnings
echo "🔍 Analyzing build log..."

# Extract errors (lines containing "error:")
grep -i "error:" "$BUILD_LOG" > "$ERROR_LOG" 2>/dev/null || true

# Extract warnings (lines containing "warning:")
grep -i "warning:" "$BUILD_LOG" > "$WARNING_LOG" 2>/dev/null || true

# Create success log if build succeeded
if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "✅ Build completed successfully at $(date)" > "$SUCCESS_LOG"
    echo "📱 App built successfully!" >> "$SUCCESS_LOG"
    echo "🎯 Target: $SCHEME" >> "$SUCCESS_LOG"
    echo "⚙️  Configuration: $CONFIGURATION" >> "$SUCCESS_LOG"
else
    echo "❌ Build failed with exit code: $BUILD_EXIT_CODE" > "$ERROR_LOG"
fi

# Show results
show_results

# Exit with build result
exit $BUILD_EXIT_CODE 