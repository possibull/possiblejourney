#!/bin/bash

echo "=== Moving Archives to Xcode Organizer ==="
echo ""

# Get current date for archive naming
CURRENT_DATE=$(date '+%m-%d-%y')
CURRENT_TIME=$(date '+%I.%M %p')

# Create today's directory if it doesn't exist
ARCHIVE_DIR="$HOME/Library/Developer/Xcode/Archives/$(date '+%Y-%m-%d')"
mkdir -p "$ARCHIVE_DIR"

# Find all xcarchive files in current directory
find . -name "*.xcarchive" -type d -maxdepth 1 | while read archive; do
    archive_name=$(basename "$archive")
    archive_base=$(echo "$archive_name" | sed 's/\.xcarchive$//')
    
    # Create new name with timestamp
    new_name="${archive_base} ${CURRENT_DATE}, ${CURRENT_TIME}.xcarchive"
    new_path="$ARCHIVE_DIR/$new_name"
    
    echo "Moving: $archive_name"
    echo "To: $new_name"
    
    # Copy to organizer location
    cp -R "$archive" "$new_path"
    
    if [ $? -eq 0 ]; then
        echo "✓ Successfully moved to Organizer"
    else
        echo "✗ Failed to move to Organizer"
    fi
    echo ""
done

echo "=== Archive Move Complete ==="
echo ""
echo "Now open Xcode and go to Window > Organizer to see your archives!" 