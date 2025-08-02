#!/bin/bash

# Auto-commit script that watches for file changes and automatically commits them
# Usage: ./auto-commit.sh

echo "Starting auto-commit watcher..."
echo "Press Ctrl+C to stop"

# Function to build and test after commit
build_after_commit() {
    local changed_files="$1"
    
    # Check if Swift files were changed
    if echo "$changed_files" | grep -q "\.swift"; then
        echo "🔨 Swift files changed, running build test..."
        
        # Run build with temporary file logging
        if [ -f "./build-with-tmp.sh" ]; then
            ./build-with-tmp.sh
            BUILD_RESULT=$?
            
            if [ $BUILD_RESULT -eq 0 ]; then
                echo "✅ Build test passed"
            else
                echo "❌ Build test failed - check logs in /tmp/possiblejourney-build-*"
            fi
        else
            echo "⚠️  build-with-tmp.sh not found, skipping build test"
        fi
    fi
}

# Function to commit changes
commit_changes() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Check if there are any changes (including untracked files)
    if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
        echo "Changes detected at $timestamp"
        
        # Stage all changes (including untracked files)
        git add .
        
        # Get list of changed files for commit message
        local changed_files=$(git diff --cached --name-only | head -5 | tr '\n' ' ')
        
        # Generate descriptive comment based on file types and changes
        local comment=""
        
        # Check each file individually for better pattern matching
        local has_view_swift=false
        local has_viewmodel_swift=false
        local has_model_swift=false
        local has_swift=false
        local has_xcodeproj=false
        local has_md=false
        local has_sh=false
        local has_json=false
        
        # Convert space-separated string to array and check each file
        IFS=' ' read -ra file_array <<< "$changed_files"
        for file in "${file_array[@]}"; do
            if [[ "$file" == *".swift" ]]; then
                has_swift=true
                # Check if file contains "View" and ends with ".swift"
                if [[ "$file" == *"View"*".swift" ]]; then
                    has_view_swift=true
                elif [[ "$file" == *"ViewModel"*".swift" ]]; then
                    has_viewmodel_swift=true
                elif [[ "$file" == *"Model"*".swift" ]]; then
                    has_model_swift=true
                fi
            elif [[ "$file" == *".xcodeproj" ]]; then
                has_xcodeproj=true
            elif [[ "$file" == *".md" ]]; then
                has_md=true
            elif [[ "$file" == *".sh" ]]; then
                has_sh=true
            elif [[ "$file" == *".json" ]]; then
                has_json=true
            fi
        done
        
        # Generate comment based on detected file types
        if [ "$has_view_swift" = true ]; then
            comment="UI improvements and view updates"
        elif [ "$has_viewmodel_swift" = true ]; then
            comment="View model logic updates"
        elif [ "$has_model_swift" = true ]; then
            comment="Data model changes"
        elif [ "$has_swift" = true ]; then
            comment="Swift code updates"
        elif [ "$has_xcodeproj" = true ]; then
            comment="Xcode project configuration changes"
        elif [ "$has_md" = true ]; then
            comment="Documentation updates"
        elif [ "$has_sh" = true ]; then
            comment="Script and automation updates"
        elif [ "$has_json" = true ]; then
            comment="Configuration and data updates"
        else
            comment="General project updates"
        fi
        
        # Create commit message with timestamp, comment, and files
        local commit_msg="Auto-commit: $timestamp - $comment - $changed_files"
        
        # Commit changes
        git commit -m "$commit_msg"
        
        echo "✅ Auto-committed: $commit_msg"
        
        # Run build test after successful commit
        build_after_commit "$changed_files"
    fi
}

# Initial commit of any existing changes
commit_changes

# Watch for file changes and commit automatically
while true; do
    # Wait for file changes (using fswatch on macOS)
    if command -v fswatch >/dev/null 2>&1; then
        # macOS - use fswatch
        fswatch -o . | while read f; do
            commit_changes
        done
    else
        # Fallback: check every 10 seconds
        sleep 10
        commit_changes
    fi
done 