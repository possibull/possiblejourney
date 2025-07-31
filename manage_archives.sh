#!/bin/bash

echo "=== PossibleJourney Archive Management ==="
echo ""

# Check current archives in project directory
echo "1. Archives in project directory:"
find . -name "*.xcarchive" -type d -maxdepth 1 | while read archive; do
    echo "   - $(basename "$archive")"
done
echo ""

# Check archives in Xcode Organizer location
echo "2. Archives in Xcode Organizer:"
if [ -d ~/Library/Developer/Xcode/Archives ]; then
    find ~/Library/Developer/Xcode/Archives -name "*.xcarchive" -type d | while read archive; do
        echo "   - $(basename "$archive")"
    done
else
    echo "   No Xcode Archives directory found"
fi
echo ""

echo "3. To move project archives to Organizer:"
echo "   ./move_to_organizer.sh"
echo ""

echo "4. To create a new archive properly:"
echo "   a. In Xcode, select 'Any iOS Device' (not simulator)"
echo "   b. Go to Product > Archive"
echo "   c. Archive will automatically appear in Organizer"
echo ""

echo "5. Current archive locations:"
echo "   - Project directory: $(pwd)"
echo "   - Xcode Organizer: ~/Library/Developer/Xcode/Archives"
echo ""

echo "=== Archive Management Complete ===" 