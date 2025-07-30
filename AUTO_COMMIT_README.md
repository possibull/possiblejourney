# Auto-Commit Setup

This project now has automatic commit functionality set up to always commit changes.

## Available Auto-Commit Methods

### 1. Git Alias (Recommended)
Run this command to auto-commit all changes:
```bash
git auto-commit
```

### 2. File Watcher Script
Start the auto-commit watcher that monitors file changes:
```bash
./auto-commit.sh
```
This will:
- Watch for file changes in the project
- Automatically stage and commit changes
- Show commit messages with timestamps
- Continue running until you press Ctrl+C

### 3. Pre-commit Hook
A git hook is installed that will automatically commit staged changes before each manual commit.

## How It Works

- **Git Alias**: Quick manual auto-commit with timestamp and file list
- **File Watcher**: Continuous monitoring using `fswatch` (macOS) or `inotifywait` (Linux)
- **Pre-commit Hook**: Automatic commits of staged changes before manual commits

## Commit Messages

Auto-commits use the format:
```
Auto-commit: YYYY-MM-DD HH:MM:SS - file1.swift file2.swift file3.swift
```

## Requirements

- **macOS**: `fswatch` (install with `brew install fswatch`)
- **Linux**: `inotifywait` (usually pre-installed)

## Stopping Auto-Commit

- **File Watcher**: Press `Ctrl+C` in the terminal running `./auto-commit.sh`
- **Git Alias**: No action needed (runs once per command)
- **Pre-commit Hook**: Remove `.git/hooks/pre-commit` file

## Manual Override

To make a manual commit instead of auto-commit:
```bash
git add .
git commit -m "Your custom message"
``` 