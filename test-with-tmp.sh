#!/bin/bash

# test-with-tmp.sh - Run UI tests with temporary file error handling and auto-commit
# This script mirrors build-with-tmp.sh but for testing instead of building

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create temporary directory for logs
TMP_DIR=$(mktemp -d)
LOG_FILE="$TMP_DIR/test.log"
ERROR_LOG="$TMP_DIR/errors.log"
WARNING_LOG="$TMP_DIR/warnings.log"

echo -e "${BLUE}🧪 Starting UI tests with temporary logging...${NC}"
echo -e "${BLUE}📁 Log directory: $TMP_DIR${NC}"

# Function to cleanup on exit
cleanup() {
    echo -e "${BLUE}🧹 Cleaning up temporary files...${NC}"
    rm -rf "$TMP_DIR"
}

# Set trap to cleanup on script exit
trap cleanup EXIT

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check for errors and warnings
check_logs() {
    local exit_code=$1
    
    # Check for errors
    if grep -i "error:" "$LOG_FILE" > "$ERROR_LOG" 2>/dev/null; then
        echo -e "${RED}❌ Errors found:${NC}"
        cat "$ERROR_LOG"
        echo ""
    fi
    
    # Check for warnings
    if grep -i "warning:" "$LOG_FILE" > "$WARNING_LOG" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Warnings found:${NC}"
        cat "$WARNING_LOG"
        echo ""
    fi
    
    return $exit_code
}

# Start logging
log "Starting UI test run"
log "Command: xcodebuild test -scheme PossibleJourney -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' $*"

# Run the test command with all arguments passed to this script
if xcodebuild test -scheme PossibleJourney -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' "$@" 2>&1 | tee -a "$LOG_FILE"; then
    echo -e "${GREEN}✅ Tests completed successfully!${NC}"
    log "Tests completed successfully"
    
    # Check for any errors or warnings in the logs
    check_logs 0
    
    # Auto-commit on success
    echo -e "${BLUE}💾 Auto-committing successful test run...${NC}"
    if ./auto-commit.sh "UI tests passed successfully"; then
        echo -e "${GREEN}✅ Changes committed successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Auto-commit failed, but tests passed${NC}"
    fi
    
    exit 0
else
    echo -e "${RED}❌ Tests failed!${NC}"
    log "Tests failed"
    
    # Check for any errors or warnings in the logs
    check_logs 1
    
    echo -e "${YELLOW}📁 Check logs in: $TMP_DIR${NC}"
    echo -e "${YELLOW}📄 Full log: $LOG_FILE${NC}"
    echo -e "${YELLOW}❌ Errors: $ERROR_LOG${NC}"
    echo -e "${YELLOW}⚠️  Warnings: $WARNING_LOG${NC}"
    
    exit 1
fi 