#!/bin/bash

# Simple auto-commit script with descriptive comments
# Usage: ./commit.sh

timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# Check if there are any changes (including untracked files)
if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
    echo "Changes detected at $timestamp"
    
    # Stage all changes (including untracked files)
    git add .
    
    # Get list of changed files for commit message
    changed_files=$(git diff --cached --name-only | head -5 | tr '\n' ' ')
    
    # Debug: Print the changed files
    echo "DEBUG: Changed files: '$changed_files'"
    
    # Generate descriptive comment based on file types and changes
    comment=""
    
    # Check each file individually for better pattern matching
    has_view_swift=false
    has_viewmodel_swift=false
    has_model_swift=false
    has_swift=false
    has_xcodeproj=false
    has_md=false
    has_sh=false
    has_json=false
    
    # Convert space-separated string to array and check each file
    IFS=' ' read -ra file_array <<< "$changed_files"
    for file in "${file_array[@]}"; do
        echo "DEBUG: Checking file: '$file'"
        if [[ "$file" == *".swift" ]]; then
            has_swift=true
            echo "DEBUG: Swift file detected: '$file'"
            if [[ "$file" == *"View.swift" ]]; then
                has_view_swift=true
                echo "DEBUG: View.swift pattern matched for: '$file'"
            elif [[ "$file" == *"ViewModel.swift" ]]; then
                has_viewmodel_swift=true
                echo "DEBUG: ViewModel.swift pattern matched for: '$file'"
            elif [[ "$file" == *"Model.swift" ]]; then
                has_model_swift=true
                echo "DEBUG: Model.swift pattern matched for: '$file'"
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
        echo "DEBUG: View.swift files detected"
        comment="UI improvements and view updates"
    elif [ "$has_viewmodel_swift" = true ]; then
        echo "DEBUG: ViewModel.swift files detected"
        comment="View model logic updates"
    elif [ "$has_model_swift" = true ]; then
        echo "DEBUG: Model.swift files detected"
        comment="Data model changes"
    elif [ "$has_swift" = true ]; then
        echo "DEBUG: Other Swift files detected"
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
    
    echo "DEBUG: Selected comment: '$comment'"
    
    # Create commit message with timestamp, comment, and files
    commit_msg="Auto-commit: $timestamp - $comment - $changed_files"
    
    # Commit changes
    git commit -m "$commit_msg"
    
    echo "✅ Auto-committed: $commit_msg"
else
    echo "No changes to commit"
fi 