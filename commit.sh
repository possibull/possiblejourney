#!/bin/bash

# Simple auto-commit script with descriptive comments
# Usage: ./commit.sh

timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# Check if there are any changes
if ! git diff --quiet; then
    echo "Changes detected at $timestamp"
    
    # Stage all changes
    git add .
    
    # Get list of changed files for commit message
    changed_files=$(git diff --cached --name-only | head -5 | tr '\n' ' ')
    
    # Generate descriptive comment based on file types and changes
    comment=""
    
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
    commit_msg="Auto-commit: $timestamp - $comment - $changed_files"
    
    # Commit changes
    git commit -m "$commit_msg"
    
    echo "✅ Auto-committed: $commit_msg"
else
    echo "No changes to commit"
fi 