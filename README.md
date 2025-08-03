# PossibleJourney - Main Branch

This is the main branch of the PossibleJourney repository. It contains only the version information file and update script.

## Contents

- `latest-version.json` - Contains the current app version, build number, and release notes
- `update-version.sh` - Script to update the version information

## Usage

### Updating Version Information

To update the version information in `latest-version.json`:

```bash
./update-version.sh <version> <build> [release_notes]
```

**Examples:**
```bash
# Update to version 1.5 build 12
./update-version.sh 1.5 12

# Update with custom release notes
./update-version.sh 1.5 12 "Bug fixes and performance improvements"
```

### Requirements

- Must be on the main branch
- Git must be configured with push access to origin
- Optional: `jq` for better JSON handling (falls back to `sed` if not available)

### What the script does

1. Validates you're on the main branch
2. Updates `latest-version.json` with new version, build, and release notes
3. Updates the timestamp to current UTC time
4. Commits and pushes the changes to GitHub
5. Provides colored output for easy reading

## Version File Format

The `latest-version.json` file contains:

```json
{
  "version": "1.5",
  "build": 11,
  "releaseNotes": "Critical Bug Fixes and Improvements...",
  "forceUpdate": false,
  "lastUpdated": "2025-08-02T21:45:00Z"
}
```

## Other Branches

- `2.0` - Main development branch with full source code
- `v1.5-build11` - Specific version branch with fixes
- Other feature and version branches as needed 