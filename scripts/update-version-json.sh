#!/bin/bash

# Simple script to update latest-version.json and push to GitHub
# Usage: ./scripts/update-version-json.sh [version] [build_number]
# Example: ./scripts/update-version-json.sh 1.3 11

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Get version and build number from arguments or current project
if [ $# -eq 2 ]; then
    VERSION=$1
    BUILD_NUMBER=$2
else
    # Extract current version from project.pbxproj
    VERSION=$(grep 'MARKETING_VERSION = ' PossibleJourney.xcodeproj/project.pbxproj | head -1 | sed 's/.*MARKETING_VERSION = //' | sed 's/;//')
    BUILD_NUMBER=$(grep 'CURRENT_PROJECT_VERSION = ' PossibleJourney.xcodeproj/project.pbxproj | head -1 | sed 's/.*CURRENT_PROJECT_VERSION = //' | sed 's/;//')
fi

print_status "Updating latest-version.json for version ${VERSION} build ${BUILD_NUMBER}"

# Create the latest-version.json file
cat > latest-version.json << EOF
{
  "version": "${VERSION}",
  "build": ${BUILD_NUMBER},
  "releaseNotes": "Enhanced User Experience & Performance - Improved UI/UX design and visual consistency - Enhanced app performance and responsiveness - Additional bug fixes and stability improvements - Better mobile experience and accessibility - Optimized data handling and storage - Improved user workflow and navigation - Enhanced feature reliability and consistency - Continued app improvements and refinements",
  "forceUpdate": false,
  "lastUpdated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

# Add, commit, and push the changes
git add latest-version.json
git commit -m "Update latest-version.json to version ${VERSION} build ${BUILD_NUMBER}"
git push

print_success "latest-version.json has been updated and pushed to GitHub!"
print_status "Your app will now detect version ${VERSION} build ${BUILD_NUMBER} as the latest version" 