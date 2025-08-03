#!/bin/bash

# Build script with temporary file error handling and auto-commit
# Usage: ./build-with-tmp.sh [scheme] [configuration] [commit_comment]
# Example: ./build-with-tmp.sh PossibleJourney Debug "Fixed theme selection bug"

# Set default values
SCHEME=${1:-"PossibleJourney"}
CONFIGURATION=${2:-"Debug"}
COMMIT_COMMENT=${3:-""}
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
    
    # Get commit comment from command line argument or use auto-generated
    user_comment="$COMMIT_COMMENT"
    
    # Call auto-commit script after successful build
    echo "🔀 Running auto-commit script after successful build..."
    if [ -f "./auto-commit.sh" ]; then
        # Create a temporary script that calls auto-commit with user comment or auto-generated
        cat > /tmp/auto-commit-build.sh << EOF
#!/bin/bash
# Temporary auto-commit script for build success

# Function to commit changes with build-specific message
commit_build_changes() {
    local timestamp=\$(date '+%Y-%m-%d %H:%M:%S')
    
    # Check if there are any changes
    if ! git diff --quiet || ! git diff --cached --quiet || [ -n "\$(git ls-files --others --exclude-standard)" ]; then
        echo "Changes detected at \$timestamp"
        
        # Stage all changes
        git add .
        
        # Get list of changed files for commit message
        local changed_files=\$(git diff --cached --name-only | head -5 | tr '\n' ' ')
        
        # Use user comment if provided, otherwise auto-generate
        local comment=""
        if [ -n "$user_comment" ]; then
            comment="$user_comment"
        else
            # Auto-generate comment based on file types (similar to auto-commit.sh logic)
            local has_view_swift=false
            local has_viewmodel_swift=false
            local has_model_swift=false
            local has_swift=false
            local has_xcodeproj=false
            local has_md=false
            local has_sh=false
            local has_json=false
            
            # Check each file type
            IFS=' ' read -ra file_array <<< "\$changed_files"
            for file in "\${file_array[@]}"; do
                if [[ "\$file" == *".swift" ]]; then
                    has_swift=true
                    if [[ "\$file" == *"View"*".swift" ]]; then
                        has_view_swift=true
                    elif [[ "\$file" == *"ViewModel"*".swift" ]]; then
                        has_viewmodel_swift=true
                    elif [[ "\$file" == *"Model"*".swift" ]]; then
                        has_model_swift=true
                    fi
                elif [[ "\$file" == *".xcodeproj" ]]; then
                    has_xcodeproj=true
                elif [[ "\$file" == *".md" ]]; then
                    has_md=true
                elif [[ "\$file" == *".sh" ]]; then
                    has_sh=true
                elif [[ "\$file" == *".json" ]]; then
                    has_json=true
                fi
            done
            
            # Generate comment based on detected file types
            if [ "\$has_view_swift" = true ]; then
                comment="UI improvements and view updates"
            elif [ "\$has_viewmodel_swift" = true ]; then
                comment="View model logic updates"
            elif [ "\$has_model_swift" = true ]; then
                comment="Data model changes"
            elif [ "\$has_swift" = true ]; then
                comment="Swift code updates"
            elif [ "\$has_xcodeproj" = true ]; then
                comment="Xcode project configuration changes"
            elif [ "\$has_md" = true ]; then
                comment="Documentation updates"
            elif [ "\$has_sh" = true ]; then
                comment="Script and automation updates"
            elif [ "\$has_json" = true ]; then
                comment="Configuration and data updates"
            else
                comment="General project updates"
            fi
        fi
        
        # Create build-specific commit message
        local commit_msg="Build successful - \$timestamp - $SCHEME $CONFIGURATION - \$comment - \$changed_files"
        
        # Commit changes
        git commit -m "\$commit_msg"
        
        echo "✅ Auto-committed: \$commit_msg"
    else
        echo "⚠️  No changes to commit"
    fi
}

# Run the commit function
commit_build_changes
EOF
        
        # Make the temporary script executable and run it
        chmod +x /tmp/auto-commit-build.sh
        /tmp/auto-commit-build.sh
        
        # Clean up temporary script
        rm -f /tmp/auto-commit-build.sh
        
        echo "✅ Auto-commit completed after successful build"
        echo "✅ Auto-commit completed after successful build" >> "$SUCCESS_LOG"
    else
        echo "⚠️  auto-commit.sh not found, skipping auto-commit"
        echo "⚠️  auto-commit.sh not found, skipping auto-commit" >> "$SUCCESS_LOG"
    fi
else
    echo "❌ Build failed with exit code: $BUILD_EXIT_CODE" > "$ERROR_LOG"
fi

# Show results
show_results

# Exit with build result
exit $BUILD_EXIT_CODE 