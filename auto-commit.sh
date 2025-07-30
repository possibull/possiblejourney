#!/bin/bash

# Auto-commit script that watches for file changes and automatically commits them
# Usage: ./auto-commit.sh

echo "Starting auto-commit watcher..."
echo "Press Ctrl+C to stop"

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
        
        # Check for specific file types and generate appropriate comments
        if echo "$changed_files" | grep -q "\.swift$"; then
            if echo "$changed_files" | grep -q "View\.swift$"; then
                comment="UI improvements and view updates"
            elif echo "$changed_files" | grep -q "ViewModel\.swift$"; then
                comment="View model logic updates"
            elif echo "$changed_files" | grep -q "Model\.swift$"; then
                comment="Data model changes"
            else
                comment="Swift code updates"
            fi
        elif echo "$changed_files" | grep -q "\.xcodeproj$"; then
            comment="Xcode project configuration changes"
        elif echo "$changed_files" | grep -q "\.md$"; then
            comment="Documentation updates"
        elif echo "$changed_files" | grep -q "\.sh$"; then
            comment="Script and automation updates"
        elif echo "$changed_files" | grep -q "\.json$"; then
            comment="Configuration and data updates"
        else
            comment="General project updates"
        fi
        
        # Create commit message with timestamp, comment, and files
        local commit_msg="Auto-commit: $timestamp - $comment - $changed_files"
        
        # Commit changes
        git commit -m "$commit_msg"
        
        echo "✅ Auto-committed: $commit_msg"
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