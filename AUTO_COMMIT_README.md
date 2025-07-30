# Auto-Commit Setup

This project now has automatic commit functionality set up to always commit changes with descriptive comments.

## Available Auto-Commit Methods

### 1. Git Alias (Recommended)
Run this command to auto-commit all changes:
```bash
git auto-commit
```

### 2. Simple Manual Script
Run this command to auto-commit all changes:
```bash
./commit.sh
```

### 3. File Watcher Script (Continuous)
Start the auto-commit watcher that monitors file changes:
```bash
./auto-commit.sh
```
This will:
- Watch for file changes in the project
- Automatically stage and commit changes
- Show commit messages with timestamps and descriptive comments
- Continue running until you press Ctrl+C

## How It Works

- **Git Alias**: Quick manual auto-commit with timestamp, descriptive comment, and file list
- **Simple Script**: Manual auto-commit with timestamp, descriptive comment, and file list
- **File Watcher**: Continuous monitoring using `fswatch` (macOS) or polling fallback

## Commit Messages

Auto-commits now use the format:
```
Auto-commit: YYYY-MM-DD HH:MM:SS - [Descriptive Comment] - file1.swift file2.swift file3.swift
```

### Descriptive Comments

The system automatically generates descriptive comments based on file types:

- **View.swift files**: "UI improvements and view updates"
- **ViewModel.swift files**: "View model logic updates"
- **Model.swift files**: "Data model changes"
- **Other Swift files**: "Swift code updates"
- **Xcode project files**: "Xcode project configuration changes"
- **Markdown files**: "Documentation updates"
- **Shell scripts**: "Script and automation updates"
- **JSON files**: "Configuration and data updates"
- **Other files**: "General project updates"

## Requirements

- **macOS**: `fswatch` (install with `brew install fswatch`) for file watching
- **Fallback**: Works without fswatch using polling every 10 seconds

## Usage Examples

```bash
# Quick auto-commit with descriptive comment
git auto-commit

# Manual auto-commit with descriptive comment
./commit.sh

# Start continuous auto-commit with descriptive comments
./auto-commit.sh
```

## Example Commit Messages

```
Auto-commit: 2025-07-29 19:54:43 - UI improvements and view updates - ProgramTemplateSelectionView.swift
Auto-commit: 2025-07-29 19:54:01 - Script and automation updates - commit.sh auto-commit.sh
Auto-commit: 2025-07-29 19:53:29 - Documentation updates - AUTO_COMMIT_README.md
```

## Stopping Auto-Commit

- **File Watcher**: Press `Ctrl+C` in the terminal running `./auto-commit.sh`
- **Git Alias/Script**: No action needed (runs once per command)

## Manual Override

To make a manual commit instead of auto-commit:
```bash
git add .
git commit -m "Your custom message"
``` 