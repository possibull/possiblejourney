# Automation Scripts for PossibleJourney

This directory contains scripts to automate development tasks including app building, running, and version management.

## Scripts Overview

### App Development Scripts

#### 1. `run-app.sh` (Full Build & Run)
**Use this for complete build and run cycle**

This script:
- Builds the app for iPhone 16 Pro Max simulator
- Installs the app on the simulator
- Launches the app
- Provides helpful testing instructions

**Usage:**
```bash
./scripts/run-app.sh
```

#### 2. `quick-run.sh` (Quick Run)
**Use this when app is already built**

This script:
- Finds the existing built app
- Installs and launches it on the simulator
- Much faster than full build

**Usage:**
```bash
./scripts/quick-run.sh
```

#### 3. `run-app` (Convenience Script)
**Simple alias for running the app**

**Usage:**
```bash
# Full build and run
./run-app

# Quick run (if already built)
./run-app quick
```

### Version Management Scripts

### 1. `update-version-json.sh` (Simple Local Update)
**Use this for quick updates without GitHub Actions**

This script:
- Reads the current version and build number from your Xcode project
- Creates/updates the `latest-version.json` file
- Commits and pushes the changes to GitHub

**Usage:**
```bash
# Update with current project version
./scripts/update-version-json.sh

# Update with specific version and build number
./scripts/update-version-json.sh 1.3 11
```

### 2. `release.sh` (GitHub Actions Workflow)
**Use this for automated releases with GitHub Actions**

This script:
- Creates a Git tag for the release
- Pushes the tag to GitHub
- Triggers the GitHub Action to automatically update `latest-version.json`

**Usage:**
```bash
# Create release with current project version
./scripts/release.sh

# Create release with specific version and build number
./scripts/release.sh 1.3 11
```

## GitHub Actions Workflow

The `.github/workflows/update-version.json` workflow automatically:
- Triggers when you push a tag starting with `v` (e.g., `v1.3.11`)
- Extracts version and build number from the tag
- Updates the `latest-version.json` file
- Commits and pushes the changes

## Recommended Workflow

1. **Build your app and increment version numbers** in Xcode
2. **Commit your changes** to Git
3. **Run the release script:**
   ```bash
   ./scripts/release.sh
   ```
4. **Monitor the GitHub Action** at: https://github.com/possibull/possiblejourney/actions

## Manual Alternative

If you prefer to update manually:
```bash
./scripts/update-version-json.sh
```

## Benefits

- ✅ **No more manual JSON updates**
- ✅ **Automatic version detection** from Xcode project
- ✅ **Consistent release process**
- ✅ **GitHub Actions automation**
- ✅ **Error checking and validation**

## Troubleshooting

**Script not found:**
```bash
chmod +x scripts/*.sh
```

**GitHub Action not working:**
- Check that the workflow file is in `.github/workflows/`
- Ensure you have write permissions to the repository
- Check the Actions tab on GitHub for error messages

**Tag already exists:**
- The script will warn you and ask for confirmation
- You can force push or create a new version 