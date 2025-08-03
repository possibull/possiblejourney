#!/bin/bash

# Script to update latest-version.json in the main branch
# Usage: ./update-version.sh <version> <build> [release_notes]

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "latest-version.json" ]; then
    print_error "Please run this script from the project root directory (where latest-version.json exists)"
    exit 1
fi

# Check if we're on the main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    print_error "You must be on the main branch to update latest-version.json"
    print_error "Current branch: $CURRENT_BRANCH"
    print_error "Please run: git checkout main"
    exit 1
fi

# Check arguments
if [ $# -lt 2 ]; then
    print_error "Usage: $0 <version> <build> [release_notes]"
    print_error "Example: $0 1.5 12 \"Bug fixes and improvements\""
    exit 1
fi

VERSION=$1
BUILD=$2
RELEASE_NOTES=${3:-"Bug fixes and improvements"}

print_status "Updating latest-version.json..."
print_status "Version: $VERSION"
print_status "Build: $BUILD"
print_status "Release Notes: $RELEASE_NOTES"

# Create backup of current file
cp latest-version.json latest-version.json.backup

# Update the JSON file using jq if available, otherwise use sed
if command -v jq &> /dev/null; then
    print_status "Using jq to update JSON..."
    jq --arg version "$VERSION" \
       --arg build "$BUILD" \
       --arg notes "$RELEASE_NOTES" \
       --arg timestamp "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
       '.version = $version | .build = ($build | tonumber) | .releaseNotes = $notes | .lastUpdated = $timestamp' \
       latest-version.json > latest-version.json.tmp && mv latest-version.json.tmp latest-version.json
else
    print_warning "jq not found, using sed to update JSON (less reliable)..."
    
    # Update version
    sed -i.bak "s/\"version\": \"[^\"]*\"/\"version\": \"$VERSION\"/" latest-version.json
    
    # Update build
    sed -i.bak "s/\"build\": [0-9]*/\"build\": $BUILD/" latest-version.json
    
    # Update release notes (escape quotes)
    ESCAPED_NOTES=$(echo "$RELEASE_NOTES" | sed 's/"/\\"/g')
    sed -i.bak "s/\"releaseNotes\": \"[^\"]*\"/\"releaseNotes\": \"$ESCAPED_NOTES\"/" latest-version.json
    
    # Update timestamp
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    sed -i.bak "s/\"lastUpdated\": \"[^\"]*\"/\"lastUpdated\": \"$TIMESTAMP\"/" latest-version.json
    
    # Clean up backup files
    rm -f latest-version.json.bak
fi

# Verify the update
print_status "Verifying update..."
if [ -f latest-version.json ]; then
    print_success "latest-version.json updated successfully!"
    echo "--- Updated latest-version.json ---"
    cat latest-version.json
    echo "-----------------------------------"
else
    print_error "Failed to update latest-version.json"
    mv latest-version.json.backup latest-version.json
    exit 1
fi

# Commit and push the changes
print_status "Committing changes..."
git add latest-version.json
git commit -m "Update to version $VERSION build $BUILD: $RELEASE_NOTES"

print_status "Pushing to GitHub..."
git push origin main

print_success "Successfully updated latest-version.json to version $VERSION build $BUILD!"

# Clean up backup
rm -f latest-version.json.backup

print_status "Done! The main branch now contains the updated version information." 