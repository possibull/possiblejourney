#!/bin/bash

# Simple auto-commit script
# Usage: ./commit.sh

timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# Check if there are any changes
if ! git diff --quiet; then
    echo "Changes detected at $timestamp"
    
    # Stage all changes
    git add .
    
    # Get list of changed files for commit message
    changed_files=$(git diff --cached --name-only | head -5 | tr '\n' ' ')
    
    # Create commit message
    commit_msg="Auto-commit: $timestamp - $changed_files"
    
    # Commit changes
    git commit -m "$commit_msg"
    
    echo "✅ Auto-committed: $commit_msg"
else
    echo "No changes to commit"
fi 