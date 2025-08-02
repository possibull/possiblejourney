#!/bin/bash

# Helper script to show build errors from temporary files
# Usage: ./show-build-errors.sh [hours_back]

HOURS_BACK=${1:-24}

echo "🔍 Searching for build errors from the last $HOURS_BACK hours..."

# Find all build directories using ls instead of find
BUILD_DIRS=$(ls -d /tmp/possiblejourney-build-* 2>/dev/null | sort -r | head -10)

if [ -z "$BUILD_DIRS" ]; then
    echo "❌ No build directories found from the last $HOURS_BACK hours"
    echo "💡 Try running: ./build-with-tmp.sh"
    exit 1
fi

echo "📁 Found build directories:"
echo "$BUILD_DIRS" | head -5

echo ""
echo "📊 BUILD SUMMARY:"
echo "=================="

# Show summary of each build
for dir in $BUILD_DIRS; do
    echo ""
    echo "📂 $(basename "$dir")"
    echo "   Created: $(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$dir" 2>/dev/null || echo "Unknown")"
    
    if [ -f "$dir/success.log" ]; then
        echo "   ✅ Status: SUCCESS"
    elif [ -f "$dir/errors.log" ]; then
        echo "   ❌ Status: FAILED"
        echo "   🔍 Error count: $(wc -l < "$dir/errors.log" 2>/dev/null || echo "0")"
    else
        echo "   ⚠️  Status: UNKNOWN"
    fi
    
    if [ -f "$dir/warnings.log" ]; then
        echo "   ⚠️  Warning count: $(wc -l < "$dir/warnings.log" 2>/dev/null || echo "0")"
    fi
done

echo ""
echo "🔍 DETAILED ERROR ANALYSIS:"
echo "============================"

# Show detailed errors from the most recent build
LATEST_BUILD=$(echo "$BUILD_DIRS" | head -1)

if [ -n "$LATEST_BUILD" ]; then
    echo "📂 Latest build: $(basename "$LATEST_BUILD")"
    
    if [ -f "$LATEST_BUILD/errors.log" ] && [ -s "$LATEST_BUILD/errors.log" ]; then
        echo ""
        echo "❌ ERRORS:"
        echo "----------"
        cat "$LATEST_BUILD/errors.log"
    fi
    
    if [ -f "$LATEST_BUILD/warnings.log" ] && [ -s "$LATEST_BUILD/warnings.log" ]; then
        echo ""
        echo "⚠️  WARNINGS:"
        echo "-------------"
        cat "$LATEST_BUILD/warnings.log"
    fi
    
    if [ -f "$LATEST_BUILD/success.log" ]; then
        echo ""
        echo "✅ SUCCESS LOG:"
        echo "---------------"
        cat "$LATEST_BUILD/success.log"
    fi
fi

echo ""
echo "💡 USEFUL COMMANDS:"
echo "==================="
echo "• View full build log: cat $LATEST_BUILD/build.log"
echo "• View only errors: cat $LATEST_BUILD/errors.log"
echo "• View only warnings: cat $LATEST_BUILD/warnings.log"
echo "• Clean old build logs: find /tmp -name 'possiblejourney-build-*' -type d -mtime +1 -exec rm -rf {} \;"
echo "• Run new build: ./build-with-tmp.sh" 