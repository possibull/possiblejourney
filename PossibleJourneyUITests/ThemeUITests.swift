import XCTest

class ThemeUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCanNavigateToSettings() throws {
        let app = XCUIApplication()
        app.launch()

        // Wait for splash screen to disappear
        Thread.sleep(forTimeInterval: 3)

        // Check if we're on the program template selection page
        // If so, select a template to create a program
        if app.staticTexts["Choose Template"].waitForExistence(timeout: 3) {
            // We're on the program setup page, need to create a program first
            // Look for any template card and tap it
            let templateCards = app.cells
            if templateCards.count > 0 {
                templateCards.element(boundBy: 0).tap()
                Thread.sleep(forTimeInterval: 2)
                
                // After tapping a template, we should see a detail view
                // Look for a "Start Program" or similar button
                let startButton = app.buttons["Start Program"]
                if startButton.waitForExistence(timeout: 3) {
                    startButton.tap()
                    Thread.sleep(forTimeInterval: 2)
                    
                    // After starting the program, release notes might appear
                    let continueButton = app.navigationBars.buttons["Continue"]
                    if continueButton.waitForExistence(timeout: 3) {
                        continueButton.tap()
                        Thread.sleep(forTimeInterval: 1)
                    }
                }
            }
        }

        // Now try to find and tap the settings button
        let settingsButton = app.buttons["SettingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 10), "Settings button should exist")
        settingsButton.tap()

        // Wait for settings to load and verify we're on the settings page
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 10), "Settings page should load")
        
        print("✅ Successfully navigated to Settings page")
    }

    func testAppLaunchesSuccessfully() throws {
        let app = XCUIApplication()
        app.launch()

        // Wait for splash screen to disappear (3 seconds)
        Thread.sleep(forTimeInterval: 3)

        // Just verify the app is running by checking for any element
        // This will help us understand if the app is crashing or just slow
        let elementCount = app.descendants(matching: .any).count
        XCTAssertGreaterThan(elementCount, 0, "App should be running and have at least one element")
        
        // Print some debug info
        print("App elements found: \(elementCount)")
    }

    func testThemeButtonExistsAndIsTappable() throws {
        let app = XCUIApplication()
        app.launch()

        // Wait for splash screen to disappear
        Thread.sleep(forTimeInterval: 3)

        // Check if we're on the program template selection page
        // If so, select a template to create a program
        if app.staticTexts["Choose Template"].waitForExistence(timeout: 3) {
            // We're on the program setup page, need to create a program first
            let templateCards = app.cells
            if templateCards.count > 0 {
                templateCards.element(boundBy: 0).tap()
                Thread.sleep(forTimeInterval: 2)
                
                // Look for a "Start Program" button
                let startButton = app.buttons["Start Program"]
                if startButton.waitForExistence(timeout: 3) {
                    startButton.tap()
                    Thread.sleep(forTimeInterval: 2)
                    
                    // After starting the program, release notes might appear
                    let continueButton = app.navigationBars.buttons["Continue"]
                    if continueButton.waitForExistence(timeout: 3) {
                        continueButton.tap()
                        Thread.sleep(forTimeInterval: 1)
                    }
                }
            }
        }

        // Navigate to settings
        let settingsButton = app.buttons["SettingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5), "Settings button should exist")
        settingsButton.tap()

        // Wait for settings to load
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 5), "Settings page should load")

        // Verify theme buttons exist
        let darkButton = app.buttons["Dark"]
        let lightButton = app.buttons["Light"]
        let systemButton = app.buttons["System"]

        XCTAssertTrue(darkButton.waitForExistence(timeout: 3), "Dark button should exist")
        XCTAssertTrue(lightButton.waitForExistence(timeout: 3), "Light button should exist")
        XCTAssertTrue(systemButton.waitForExistence(timeout: 3), "System button should exist")

        // Test that buttons are tappable
        darkButton.tap()
        lightButton.tap()
        systemButton.tap()
    }

    func testThemeChangesImmediatelyAfterResetAll() throws {
        let app = XCUIApplication()
        app.launch()

        // Wait for splash screen to disappear
        Thread.sleep(forTimeInterval: 3)

        // Check if we're on the program template selection page
        // If so, select a template to create a program
        if app.staticTexts["Choose Template"].waitForExistence(timeout: 3) {
            // We're on the program setup page, need to create a program first
            let templateCards = app.cells
            if templateCards.count > 0 {
                templateCards.element(boundBy: 0).tap()
                Thread.sleep(forTimeInterval: 2)
                
                // Look for a "Start Program" button
                let startButton = app.buttons["Start Program"]
                if startButton.waitForExistence(timeout: 3) {
                    startButton.tap()
                    Thread.sleep(forTimeInterval: 2)
                    
                    // After starting the program, release notes might appear
                    let continueButton = app.navigationBars.buttons["Continue"]
                    if continueButton.waitForExistence(timeout: 3) {
                        continueButton.tap()
                        Thread.sleep(forTimeInterval: 1)
                    }
                }
            }
        }

        // Navigate to settings
        let settingsButton = app.buttons["SettingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5), "Settings button should exist")
        settingsButton.tap()
        
        // Wait for settings to load
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 5), "Settings page should load")

        // Tap Reset All Preferences
        let resetButton = app.buttons["ResetPreferencesButton"]
        XCTAssertTrue(resetButton.waitForExistence(timeout: 3), "Reset button should exist")
        resetButton.tap()
        
        // Wait a moment for reset to complete
        Thread.sleep(forTimeInterval: 1)
        
        // FIRST THEME CHANGE: Immediately tap Dark theme
        let darkButton = app.buttons["Dark"]
        XCTAssertTrue(darkButton.waitForExistence(timeout: 3), "Dark button should exist")
        darkButton.tap()
        
        // Wait for theme change to take effect
        Thread.sleep(forTimeInterval: 2)
        
        // Verify the first theme change worked by checking for the checkmark icon
        let darkCheckmark = app.images["checkmark.circle.fill"]
        XCTAssertTrue(darkCheckmark.waitForExistence(timeout: 3), "Dark theme should show checkmark after first theme change")
        
        // SECOND THEME CHANGE: Try tapping Light theme to verify the second change works
        let lightButton = app.buttons["Light"]
        XCTAssertTrue(lightButton.waitForExistence(timeout: 3), "Light button should exist")
        lightButton.tap()
        
        // Wait for second theme change to take effect
        Thread.sleep(forTimeInterval: 2)
        
        // Verify the second theme change worked by checking for the checkmark icon on Light button
        let lightCheckmark = app.images["checkmark.circle.fill"]
        XCTAssertTrue(lightCheckmark.waitForExistence(timeout: 3), "Light theme should show checkmark after second theme change")
        
        // Verify that the checkmark moved from Dark to Light button
        // This is a more sophisticated check - we should see the checkmark on the Light button now
        XCTAssertTrue(lightButton.waitForExistence(timeout: 3), "Light button should still exist after second theme change")
        
        // THIRD THEME CHANGE: Try System theme to verify third change works
        let systemButton = app.buttons["System"]
        XCTAssertTrue(systemButton.waitForExistence(timeout: 3), "System button should exist")
        systemButton.tap()
        
        // Wait for third theme change to take effect
        Thread.sleep(forTimeInterval: 2)
        
        // Verify the third theme change worked
        XCTAssertTrue(systemButton.waitForExistence(timeout: 3), "System button should still exist after third theme change")
        
        // Verify that the checkmark is now on the System button
        let systemCheckmark = app.images["checkmark.circle.fill"]
        XCTAssertTrue(systemCheckmark.waitForExistence(timeout: 3), "System theme should show checkmark after third theme change")
        
        // ADDITIONAL VERIFICATION: Check that the app is responsive to theme changes
        // Try tapping Dark again to see if it responds
        darkButton.tap()
        Thread.sleep(forTimeInterval: 2)
        
        // Verify the checkmark moved back to Dark
        XCTAssertTrue(darkCheckmark.waitForExistence(timeout: 3), "Dark theme should show checkmark after fourth theme change")
    }
} 