#!/bin/bash

# Release script for PossibleJourney
# Usage: ./scripts/release.sh [version] [build_number]
# Example: ./scripts/release.sh 1.3 11

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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
    print_error "This script must be run from the PossibleJourney project root directory"
    exit 1
fi

# Get version and build number from arguments or current project
if [ $# -eq 2 ]; then
    VERSION=$1
    BUILD_NUMBER=$2
else
    # Extract current version from project.pbxproj
    VERSION=$(grep 'MARKETING_VERSION = ' PossibleJourney.xcodeproj/project.pbxproj | head -1 | sed 's/.*MARKETING_VERSION = //' | sed 's/;//')
    BUILD_NUMBER=$(grep 'CURRENT_PROJECT_VERSION = ' PossibleJourney.xcodeproj/project.pbxproj | head -1 | sed 's/.*CURRENT_PROJECT_VERSION = //' | sed 's/;//')
fi

FULL_VERSION="${VERSION}.${BUILD_NUMBER}"
TAG_NAME="v${FULL_VERSION}"

print_status "Preparing release for version ${FULL_VERSION}"

# Check if tag already exists
if git tag -l | grep -q "^${TAG_NAME}$"; then
    print_warning "Tag ${TAG_NAME} already exists!"
    read -p "Do you want to continue and force push? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Release cancelled"
        exit 1
    fi
fi

# Check if we have uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    print_warning "You have uncommitted changes. Please commit them first."
    git status --short
    exit 1
fi

# Create and push the tag
print_status "Creating tag ${TAG_NAME}..."
git tag -a "${TAG_NAME}" -m "Release version ${FULL_VERSION}"

print_status "Pushing tag to GitHub..."
git push origin "${TAG_NAME}"

print_success "Release tag ${TAG_NAME} has been created and pushed!"
print_status "GitHub Action will automatically update latest-version.json"
print_status "You can monitor the progress at: https://github.com/possibull/possiblejourney/actions"

# Optional: Open the GitHub Actions page
read -p "Open GitHub Actions page? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "https://github.com/possibull/possiblejourney/actions"
fi 