#!/bin/bash

# Script to automatically deploy PossibleJourney to App Store Connect
# Usage: ./scripts/deploy.sh [beta|release]

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
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Check if fastlane is installed
if ! command -v fastlane &> /dev/null; then
    print_error "Fastlane is not installed. Please install it first:"
    echo "brew install fastlane"
    exit 1
fi

# Get deployment type from argument
DEPLOY_TYPE=${1:-beta}

case $DEPLOY_TYPE in
    "beta")
        print_status "Deploying to TestFlight..."
        fastlane beta
        print_success "Successfully deployed to TestFlight!"
        ;;
    "release")
        print_warning "This will deploy to the App Store. Are you sure? (y/N)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            print_status "Deploying to App Store..."
            fastlane release
            print_success "Successfully deployed to App Store!"
        else
            print_status "Deployment cancelled"
            exit 0
        fi
        ;;
    "full")
        print_warning "This will increment build number and deploy to App Store. Are you sure? (y/N)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            print_status "Running full release process..."
            fastlane full_release
            print_success "Successfully completed full release process!"
        else
            print_status "Deployment cancelled"
            exit 0
        fi
        ;;
    *)
        print_error "Invalid deployment type. Use: beta, release, or full"
        echo "Usage: $0 [beta|release|full]"
        exit 1
        ;;
esac 