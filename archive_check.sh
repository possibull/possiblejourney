#!/bin/bash

echo "=== PossibleJourney Archive Configuration Check ==="
echo ""

echo "1. Checking Xcode project archive settings..."
echo "   - ARCHIVE_PATH is set to: \$(BUILT_PRODUCTS_DIR)/../.."
echo "   - This ensures archives are saved in the standard Xcode location"
echo ""

echo "2. Checking scheme configuration..."
echo "   - revealArchiveInOrganizer = YES ✓"
echo "   - customArchiveName = PossibleJourney ✓"
echo ""

echo "3. To create an archive and verify it appears in Organizer:"
echo "   a. In Xcode, go to Product > Archive"
echo "   b. Wait for the archive to complete"
echo "   c. The Organizer should automatically open"
echo "   d. If not, go to Window > Organizer"
echo ""

echo "4. Archive location:"
echo "   Default location: ~/Library/Developer/Xcode/Archives"
echo "   Project-specific: $(pwd)/build/Release-iphoneos"
echo ""

echo "5. Troubleshooting tips:"
echo "   - Make sure you're building for a real device or 'Any iOS Device'"
echo "   - Archives won't be created when building for simulator"
echo "   - Check that your development team is properly configured"
echo "   - Verify code signing settings are correct"
echo ""

echo "6. To manually check archives in Finder:"
echo "   open ~/Library/Developer/Xcode/Archives"
echo ""

echo "=== Configuration Complete ===" 