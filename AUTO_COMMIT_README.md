# Auto-Commit Setup

This project now has automatic commit functionality set up to always commit changes.

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
- Show commit messages with timestamps
- Continue running until you press Ctrl+C

## How It Works

- **Git Alias**: Quick manual auto-commit with timestamp and file list
- **Simple Script**: Manual auto-commit with timestamp and file list
- **File Watcher**: Continuous monitoring using `fswatch` (macOS) or polling fallback

## Commit Messages

Auto-commits use the format:
```
Auto-commit: YYYY-MM-DD HH:MM:SS - file1.swift file2.swift file3.swift
```

## Requirements

- **macOS**: `fswatch` (install with `brew install fswatch`) for file watching
- **Fallback**: Works without fswatch using polling every 10 seconds

## Usage Examples

```bash
# Quick auto-commit
git auto-commit

# Manual auto-commit
./commit.sh

# Start continuous auto-commit
./auto-commit.sh
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