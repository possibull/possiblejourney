#!/bin/bash

# Script to combine multiple releases into a single comprehensive release note
# Usage: ./scripts/combine-release-notes.sh [version] [build_number]
# Example: ./scripts/combine-release-notes.sh 1.3 13

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

# Get version and build number from arguments or current project
if [ $# -eq 2 ]; then
    VERSION=$1
    BUILD_NUMBER=$2
else
    # Extract current version from project.pbxproj
    VERSION=$(grep 'MARKETING_VERSION = ' PossibleJourney.xcodeproj/project.pbxproj | head -1 | sed 's/.*MARKETING_VERSION = //' | sed 's/;//')
    BUILD_NUMBER=$(grep 'CURRENT_PROJECT_VERSION = ' PossibleJourney.xcodeproj/project.pbxproj | head -1 | sed 's/.*CURRENT_PROJECT_VERSION = //' | sed 's/;//')
fi

print_status "Combining release notes for version ${VERSION} build ${BUILD_NUMBER}"

# Check if there are previous releases to combine
if [ -f "latest-version.json" ]; then
    print_status "Found existing latest-version.json, checking for previous releases..."
    
    # Read existing version info
    EXISTING_VERSION=$(grep '"version"' latest-version.json | sed 's/.*"version": "//' | sed 's/",//')
    EXISTING_BUILD=$(grep '"build"' latest-version.json | sed 's/.*"build": //' | sed 's/,//')
    
    if [ "$EXISTING_VERSION" = "$VERSION" ] && [ "$EXISTING_BUILD" -lt "$BUILD_NUMBER" ]; then
        print_status "Combining releases from build $EXISTING_BUILD to build $BUILD_NUMBER"
        
        # Create a comprehensive release note that covers multiple builds
        COMBINED_NOTES="Enhanced User Experience & Performance - Improved UI/UX design and visual consistency - Enhanced app performance and responsiveness - Additional bug fixes and stability improvements - Better mobile experience and accessibility - Optimized data handling and storage - Improved user workflow and navigation - Enhanced feature reliability and consistency - Continued app improvements and refinements - Multiple build updates and optimizations"
        
        # Create the latest-version.json with combined notes
        cat > latest-version.json << EOF
{
  "version": "${VERSION}",
  "build": ${BUILD_NUMBER},
  "releaseNotes": "${COMBINED_NOTES}",
  "forceUpdate": false,
  "lastUpdated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "releases": [
    {
      "version": "${VERSION}",
      "build": ${EXISTING_BUILD},
      "notes": "Enhanced User Experience & Performance - Improved UI/UX design and visual consistency - Enhanced app performance and responsiveness - Additional bug fixes and stability improvements - Better mobile experience and accessibility - Optimized data handling and storage - Improved user workflow and navigation - Enhanced feature reliability and consistency - Continued app improvements and refinements",
      "date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
      "features": [],
      "bugFixes": ["General stability improvements", "Performance optimizations"],
      "improvements": ["Enhanced UI/UX design", "Improved app responsiveness", "Better data handling"]
    },
    {
      "version": "${VERSION}",
      "build": ${BUILD_NUMBER},
      "notes": "Additional bug fixes and stability improvements - Better mobile experience and accessibility - Optimized data handling and storage - Improved user workflow and navigation - Enhanced feature reliability and consistency - Continued app improvements and refinements",
      "date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
      "features": [],
      "bugFixes": ["Additional stability improvements", "Accessibility enhancements"],
      "improvements": ["Better mobile experience", "Optimized data handling", "Improved user workflow"]
    }
  ],
  "combinedNotes": "${COMBINED_NOTES}"
}
EOF
    else
        print_status "Creating new release for version ${VERSION} build ${BUILD_NUMBER}"
        
        # Create standard release note for new version
        cat > latest-version.json << EOF
{
  "version": "${VERSION}",
  "build": ${BUILD_NUMBER},
  "releaseNotes": "Enhanced User Experience & Performance - Improved UI/UX design and visual consistency - Enhanced app performance and responsiveness - Additional bug fixes and stability improvements - Better mobile experience and accessibility - Optimized data handling and storage - Improved user workflow and navigation - Enhanced feature reliability and consistency - Continued app improvements and refinements",
  "forceUpdate": false,
  "lastUpdated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
    fi
else
    print_status "Creating initial release for version ${VERSION} build ${BUILD_NUMBER}"
    
    # Create initial release note
    cat > latest-version.json << EOF
{
  "version": "${VERSION}",
  "build": ${BUILD_NUMBER},
  "releaseNotes": "Enhanced User Experience & Performance - Improved UI/UX design and visual consistency - Enhanced app performance and responsiveness - Additional bug fixes and stability improvements - Better mobile experience and accessibility - Optimized data handling and storage - Improved user workflow and navigation - Enhanced feature reliability and consistency - Continued app improvements and refinements",
  "forceUpdate": false,
  "lastUpdated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
fi

print_success "Release notes combined and updated for version ${VERSION} build ${BUILD_NUMBER}!"
print_status "The app will now show a single comprehensive release note for all updates" 