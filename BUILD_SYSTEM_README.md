# Build and Commit System

This project now includes an enhanced build and commit system that automatically commits changes and uses temporary files for easy error retrieval.

## 🚀 Quick Start

### 1. Auto-Commit System
The existing `auto-commit.sh` script has been enhanced to:
- Automatically commit changes when files are modified
- Run build tests after Swift file changes
- Generate descriptive commit messages based on file types

```bash
# Start the auto-commit watcher
./auto-commit.sh
```

### 2. Build with Temporary File Logging
The new `build-with-tmp.sh` script provides:
- Comprehensive build logging to temporary files
- Separate error, warning, and success logs
- Easy error retrieval and analysis

```bash
# Build with temporary file logging
./build-with-tmp.sh

# Build with specific scheme and configuration
./build-with-tmp.sh PossibleJourney Release
```

### 3. Error Retrieval
The `show-build-errors.sh` script helps you:
- View build history and results
- Analyze errors and warnings
- Access detailed logs

```bash
# Show recent build errors
./show-build-errors.sh

# Show builds from last 12 hours
./show-build-errors.sh 12
```

## 📁 Temporary File Structure

Build logs are stored in `/tmp/possiblejourney-build-YYYYMMDD-HHMMSS/` with the following structure:

```
/tmp/possiblejourney-build-20250802-020505/
├── build.log      # Complete build output
├── errors.log     # Extracted error messages
├── warnings.log   # Extracted warning messages
└── success.log    # Success information (if build succeeded)
```

## 🔧 Script Details

### auto-commit.sh
- **Purpose**: Watches for file changes and automatically commits them
- **Features**:
  - File type detection for descriptive commit messages
  - Automatic build testing after Swift file changes
  - Integration with build-with-tmp.sh
- **Usage**: `./auto-commit.sh`

### build-with-tmp.sh
- **Purpose**: Builds the project with comprehensive logging
- **Features**:
  - Temporary file logging for easy error retrieval
  - Error and warning extraction
  - Build result analysis
  - Automatic cleanup of old logs (24+ hours)
- **Usage**: `./build-with-tmp.sh [scheme] [configuration]`

### show-build-errors.sh
- **Purpose**: Retrieves and displays build errors from temporary files
- **Features**:
  - Build history summary
  - Detailed error analysis
  - Warning display
  - Useful command suggestions
- **Usage**: `./show-build-errors.sh [hours_back]`

## 🎯 Workflow

1. **Start Development**:
   ```bash
   ./auto-commit.sh
   ```

2. **Make Changes**: Edit your Swift files

3. **Automatic Process**:
   - Changes are automatically committed
   - Build test runs if Swift files changed
   - Logs are saved to temporary files

4. **Check Results**:
   ```bash
   ./show-build-errors.sh
   ```

5. **Manual Build** (if needed):
   ```bash
   ./build-with-tmp.sh
   ```

## 📊 Error Analysis

The system provides several ways to analyze build issues:

### View Latest Build Results
```bash
./show-build-errors.sh
```

### View Specific Log Files
```bash
# Get the latest build directory
LATEST_BUILD=$(ls -d /tmp/possiblejourney-build-* | sort -r | head -1)

# View full build log
cat "$LATEST_BUILD/build.log"

# View only errors
cat "$LATEST_BUILD/errors.log"

# View only warnings
cat "$LATEST_BUILD/warnings.log"
```

### Clean Up Old Logs
```bash
# Remove logs older than 24 hours
find /tmp -name 'possiblejourney-build-*' -type d -mtime +1 -exec rm -rf {} \;
```

## 🔍 Troubleshooting

### Build Script Issues
- **No simulator found**: Update the simulator name in `build-with-tmp.sh`
- **Permission denied**: Ensure scripts are executable (`chmod +x *.sh`)
- **Find command issues**: The script uses `ls` instead of `find` for compatibility

### Auto-Commit Issues
- **No commits happening**: Check if `fswatch` is installed (macOS)
- **Build tests not running**: Ensure `build-with-tmp.sh` exists and is executable

### Error Retrieval Issues
- **No build directories found**: Run `./build-with-tmp.sh` first
- **Empty error logs**: Build may have succeeded (check `success.log`)

## 🛠️ Customization

### Change Simulator
Edit `build-with-tmp.sh` and update the destination:
```bash
-destination "platform=iOS Simulator,name=iPhone 16"
```

### Modify Log Retention
Edit the cleanup function in `build-with-tmp.sh`:
```bash
# Keep logs for 48 hours instead of 24
find /tmp -name "possiblejourney-build-*" -type d -mtime +2 -exec rm -rf {} \;
```

### Add Custom Build Configurations
Add new build targets to `build-with-tmp.sh`:
```bash
case "$CONFIGURATION" in
    "Debug") # existing code ;;
    "Release") # existing code ;;
    "Custom") # add custom configuration ;;
esac
```

## 📈 Benefits

1. **Automatic Version Control**: No more forgetting to commit changes
2. **Immediate Error Detection**: Build issues are caught right away
3. **Easy Debugging**: Temporary files make error analysis simple
4. **Build History**: Track build success/failure over time
5. **Clean Workflow**: Focus on coding, let automation handle the rest

## 🔄 Integration

This system integrates seamlessly with:
- **Xcode**: Use for development, scripts for automation
- **Git**: Automatic commits maintain version history
- **CI/CD**: Build logs can be used in continuous integration
- **Team Development**: Shared error analysis and build history 