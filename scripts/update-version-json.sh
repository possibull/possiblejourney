#!/bin/bash

# Script to copy latest-version.json from current branch to main and push only that file
# Usage: ./scripts/update-version-json.sh
# This script assumes latest-version.json already exists on the current branch

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

# Check if we're on a branch (not main)
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "main" ]; then
    print_error "This script should be run from a feature branch, not main"
    print_status "Please switch to your feature branch and run this script again"
    exit 1
fi

print_status "Current branch: ${CURRENT_BRANCH}"

# Check if latest-version.json exists on current branch
if [ ! -f "latest-version.json" ]; then
    print_error "latest-version.json not found on current branch"
    print_status "Please ensure latest-version.json exists on this branch before running this script"
    exit 1
fi

# Read version info from the current latest-version.json
VERSION=$(grep '"version"' latest-version.json | sed 's/.*"version": "//' | sed 's/".*//')
BUILD_NUMBER=$(grep '"build"' latest-version.json | sed 's/.*"build": //' | sed 's/,.*//')

print_status "Copying latest-version.json (version ${VERSION} build ${BUILD_NUMBER}) from ${CURRENT_BRANCH} to main"

# Stash any current changes to avoid conflicts
if ! git diff --quiet; then
    print_warning "Uncommitted changes detected, stashing them..."
    git stash push -m "Auto-stash before updating main branch"
    STASHED=true
else
    STASHED=false
fi

# Switch to main branch
print_status "Switching to main branch..."
git checkout main

# Copy latest-version.json from the feature branch
print_status "Copying latest-version.json from ${CURRENT_BRANCH}..."
git show "${CURRENT_BRANCH}:latest-version.json" > latest-version.json

# Add and commit only latest-version.json
print_status "Committing latest-version.json to main..."
git add latest-version.json
git commit -m "Update latest-version.json to version ${VERSION} build ${BUILD_NUMBER} from ${CURRENT_BRANCH}"

# Push only latest-version.json to main
print_status "Pushing latest-version.json to main branch..."
git push origin main

# Switch back to the original branch
print_status "Switching back to ${CURRENT_BRANCH}..."
git checkout "${CURRENT_BRANCH}"

# Restore stashed changes if any
if [ "$STASHED" = true ]; then
    print_status "Restoring stashed changes..."
    git stash pop
fi

print_success "latest-version.json has been successfully copied from ${CURRENT_BRANCH} to main and pushed!"
print_status "Your app will now detect version ${VERSION} build ${BUILD_NUMBER} as the latest version" 