#!/bin/bash

# Script to start working on a new version
# Usage: ./start-new-version.sh <major|minor|build>

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
if [ ! -f "PossibleJourney.xcodeproj/project.pbxproj" ]; then
    print_error "Please run this script from the project root directory (where PossibleJourney.xcodeproj exists)"
    exit 1
fi

# Check arguments
if [ $# -ne 1 ]; then
    print_error "Usage: $0 <major|minor|build>"
    print_error "Examples:"
    print_error "  $0 major    # 1.5 build 11 → 2.0 build 1"
    print_error "  $0 minor    # 1.5 build 11 → 1.6 build 1"
    print_error "  $0 build    # 1.5 build 11 → 1.5 build 12"
    exit 1
fi

VERSION_TYPE=$1

# Validate version type
if [[ ! "$VERSION_TYPE" =~ ^(major|minor|build)$ ]]; then
    print_error "Invalid version type. Use: major, minor, or build"
    exit 1
fi

# Get current version from main branch's latest-version.json
print_status "Reading current version from main branch's latest-version.json..."
git show main:latest-version.json > /tmp/latest-version.json

if command -v jq &> /dev/null; then
    CURRENT_VERSION=$(jq -r '.version' /tmp/latest-version.json)
    CURRENT_BUILD=$(jq -r '.build' /tmp/latest-version.json)
else
    CURRENT_VERSION=$(grep '"version"' /tmp/latest-version.json | sed 's/.*"version": "\([^"]*\)".*/\1/')
    CURRENT_BUILD=$(grep '"build"' /tmp/latest-version.json | sed 's/.*"build": \([0-9]*\).*/\1/')
fi

rm -f /tmp/latest-version.json

if [ -z "$CURRENT_VERSION" ] || [ -z "$CURRENT_BUILD" ]; then
    print_error "Could not read current version from main branch's latest-version.json"
    exit 1
fi

print_status "Current version: $CURRENT_VERSION build $CURRENT_BUILD"

# Parse current version
IFS='.' read -r MAJOR MINOR <<< "$CURRENT_VERSION"

# Calculate new version based on type
case $VERSION_TYPE in
    "major")
        NEW_MAJOR=$((MAJOR + 1))
        NEW_MINOR=0
        NEW_BUILD=1
        NEW_VERSION="${NEW_MAJOR}.${NEW_MINOR}"
        BRANCH_NAME="v${NEW_VERSION}-build${NEW_BUILD}"
        ;;
    "minor")
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$((MINOR + 1))
        NEW_BUILD=1
        NEW_VERSION="${NEW_MAJOR}.${NEW_MINOR}"
        BRANCH_NAME="v${NEW_VERSION}-build${NEW_BUILD}"
        ;;
    "build")
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$MINOR
        NEW_BUILD=$((CURRENT_BUILD + 1))
        NEW_VERSION="${NEW_MAJOR}.${NEW_MINOR}"
        BRANCH_NAME="v${NEW_VERSION}-build${NEW_BUILD}"
        ;;
esac

print_status "New version: $NEW_VERSION build $NEW_BUILD"
print_status "New branch name: $BRANCH_NAME"

# Check if branch already exists
if git show-ref --verify --quiet refs/heads/$BRANCH_NAME; then
    print_error "Branch $BRANCH_NAME already exists!"
    exit 1
fi

# Create new branch from current branch
CURRENT_BRANCH=$(git branch --show-current)
print_status "Creating new branch '$BRANCH_NAME' from '$CURRENT_BRANCH'..."

git checkout -b $BRANCH_NAME

# Update version in project file
print_status "Updating version in project file..."

# Update MARKETING_VERSION
sed -i.bak "s/MARKETING_VERSION = [^;]*;/MARKETING_VERSION = $NEW_VERSION;/g" PossibleJourney.xcodeproj/project.pbxproj

# Update CURRENT_PROJECT_VERSION
sed -i.bak "s/CURRENT_PROJECT_VERSION = [^;]*;/CURRENT_PROJECT_VERSION = $NEW_BUILD;/g" PossibleJourney.xcodeproj/project.pbxproj

# Clean up backup files
rm -f PossibleJourney.xcodeproj/project.pbxproj.bak

# Update latest-version.json if it exists
if [ -f "latest-version.json" ]; then
    print_status "Updating latest-version.json..."
    
    if command -v jq &> /dev/null; then
        jq --arg version "$NEW_VERSION" \
           --arg build "$NEW_BUILD" \
           --arg notes "New version $NEW_VERSION build $NEW_BUILD" \
           --arg timestamp "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
           '.version = $version | .build = ($build | tonumber) | .releaseNotes = $notes | .lastUpdated = $timestamp' \
           latest-version.json > latest-version.json.tmp && mv latest-version.json.tmp latest-version.json
    else
        # Update version
        sed -i.bak "s/\"version\": \"[^\"]*\"/\"version\": \"$NEW_VERSION\"/" latest-version.json
        
        # Update build
        sed -i.bak "s/\"build\": [0-9]*/\"build\": $NEW_BUILD/" latest-version.json
        
        # Update release notes
        sed -i.bak "s/\"releaseNotes\": \"[^\"]*\"/\"releaseNotes\": \"New version $NEW_VERSION build $NEW_BUILD\"/" latest-version.json
        
        # Update timestamp
        TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        sed -i.bak "s/\"lastUpdated\": \"[^\"]*\"/\"lastUpdated\": \"$TIMESTAMP\"/" latest-version.json
        
        # Clean up backup files
        rm -f latest-version.json.bak
    fi
fi

# Commit the version changes
print_status "Committing version changes..."
git add .
git commit -m "Start version $NEW_VERSION build $NEW_BUILD"

print_success "Successfully created new version branch!"
print_status "Current branch: $BRANCH_NAME"
print_status "New version: $NEW_VERSION build $NEW_BUILD"
print_status ""
print_status "Next steps:"
print_status "1. Make your changes to the code"
print_status "2. Test the changes"
print_status "3. Update release notes in latest-version.json"
print_status "4. Commit and push: git push origin $BRANCH_NAME"
print_status "5. When ready to deploy, use the deploy script" 