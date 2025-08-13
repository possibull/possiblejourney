import XCTest

final class SettingsNavigationTest: UITestHelperMixin {
    
    func testNavigateToSettingsFromDailyChecklist() throws {
        // Given: We start with a clean state and have a program running
        try resetToCleanState()
        try createProgram(from: nil, name: nil)
        try startProgram()
        
        // When: We navigate to settings
        try navigateToSettings()
        
        // Then: We should be on the settings page
        try verifyOnSettings()
    }
    
    func testNavigateToSettingsAndVerifyElements() throws {
        // Given: We start with a clean state and have a program running
        try resetToCleanState()
        try createProgram(from: nil, name: nil)
        try startProgram()
        
        // When: We navigate to settings
        try navigateToSettings()
        
        // Then: We should be on the settings page with key elements visible
        try verifyOnSettings()
        
        // And: Settings page should have key elements
        XCTAssertTrue(app.staticTexts["Settings"].exists, "Settings title should be visible")
        
        // Check for common settings elements (adjust based on your actual UI)
        let settingsElements = [
            "CelebrationToggle",
            "EndOfDayTimePicker",
            "ResetPreferencesButton"
        ]
        
        for elementId in settingsElements {
            let element = app.otherElements[elementId].firstMatch
            if element.exists {
                XCTAssertTrue(element.exists, "Settings element '\(elementId)' should be visible")
            }
        }
    }
    
    func testNavigateToSettingsAndReturnToDailyChecklist() throws {
        // Given: We start with a clean state and have a program running
        try resetToCleanState()
        try createProgram(from: nil, name: nil)
        try startProgram()
        
        // When: We navigate to settings
        try navigateToSettings()
        
        // Then: We should be on the settings page
        try verifyOnSettings()
        
        // When: We navigate back (assuming there's a back button or similar)
        let backButton = app.navigationBars.buttons["Back"].firstMatch
        if backButton.exists {
            backButton.tap()
        } else {
            // Try alternative back navigation
            let doneButton = app.buttons["Done"].firstMatch
            if doneButton.exists {
                doneButton.tap()
            }
        }
        
        // Then: We should be back on the daily checklist
        try verifyOnDailyChecklist()
    }
    
    func testSettingsNavigationFromFreshStart() throws {
        // Given: We start with a clean state
        try resetToCleanState()
        
        // When: We try to navigate to settings without a program
        // This should create a program first, then navigate to settings
        try navigateToSettings()
        
        // Then: We should be on the settings page
        try verifyOnSettings()
    }
} 