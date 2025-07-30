#!/bin/bash

# Auto-commit script that watches for file changes and automatically commits them
# Usage: ./auto-commit.sh

echo "Starting auto-commit watcher..."
echo "Press Ctrl+C to stop"

# Function to commit changes
commit_changes() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Check if there are any changes
    if ! git diff --quiet; then
        echo "Changes detected at $timestamp"
        
        # Stage all changes
        git add .
        
        # Get list of changed files for commit message
        local changed_files=$(git diff --cached --name-only | head -5 | tr '\n' ' ')
        
        # Create commit message
        local commit_msg="Auto-commit: $timestamp - $changed_files"
        
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