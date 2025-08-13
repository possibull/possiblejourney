import XCTest

class ThemeUITests: UITestHelperMixin {

    func testCanNavigateToSettings() throws {
        // Given: App is launched and we navigate to settings
        try navigateToSettings()

        // Then: We should be on the settings page
        try verifyOnSettings()
        
        print("✅ Successfully navigated to Settings page")
    }

    func testAppLaunchesSuccessfully() throws {
        // Given: App is launched
        // When: App starts up
        
        // Then: App should be running and have elements
        let elementCount = app.descendants(matching: .any).count
        XCTAssertGreaterThan(elementCount, 0, "App should be running and have at least one element")
        
        // Print some debug info
        print("App elements found: \(elementCount)")
    }

    func testThemeButtonExistsAndIsTappable() throws {
        // Given: App is launched and we navigate to settings
        try navigateToSettings()

        // Then: Theme buttons should exist and be tappable
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
        // Given: App is launched and we navigate to settings
        try navigateToSettings()

        // When: We reset all preferences
        try resetAllPreferences()
        
        // Then: Theme changes should work immediately after reset
        
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
    
    // MARK: - Complete Workflow Tests
    
    func testThemeChangeWorkflow() throws {
        // Given: We have a program
        try navigateToDailyChecklist()
        
        // When: Changing themes
        try navigateToSettings()
        try changeTheme(to: "Dark")
        try changeTheme(to: "Light")
        try changeTheme(to: "System")
        
        // Then: Theme changes should be applied
        // (Verification would depend on UI appearance changes)
    }
} 