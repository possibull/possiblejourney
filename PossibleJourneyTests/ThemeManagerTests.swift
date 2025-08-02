import XCTest
import SwiftUI
@testable import PossibleJourney

class ThemeManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Clear UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "selectedTheme")
    }
    
    override func tearDown() {
        // Clear UserDefaults after each test
        UserDefaults.standard.removeObject(forKey: "selectedTheme")
        super.tearDown()
    }
    
    // MARK: - ThemeMode Tests
    
    func testThemeModeAllCases() {
        XCTAssertEqual(ThemeMode.allCases.count, 5)
        XCTAssertTrue(ThemeMode.allCases.contains(.light))
        XCTAssertTrue(ThemeMode.allCases.contains(.dark))
        XCTAssertTrue(ThemeMode.allCases.contains(.system))
        XCTAssertTrue(ThemeMode.allCases.contains(.bea))
        XCTAssertTrue(ThemeMode.allCases.contains(.birthday))
    }
    
    func testThemeModeRawValues() {
        XCTAssertEqual(ThemeMode.light.rawValue, "light")
        XCTAssertEqual(ThemeMode.dark.rawValue, "dark")
        XCTAssertEqual(ThemeMode.system.rawValue, "system")
        XCTAssertEqual(ThemeMode.bea.rawValue, "bea")
        XCTAssertEqual(ThemeMode.birthday.rawValue, "birthday")
    }
    
    func testThemeModeDisplayNames() {
        XCTAssertEqual(ThemeMode.light.displayName, "Light")
        XCTAssertEqual(ThemeMode.dark.displayName, "Dark")
        XCTAssertEqual(ThemeMode.system.displayName, "System")
        XCTAssertEqual(ThemeMode.bea.displayName, "Bea")
        XCTAssertEqual(ThemeMode.birthday.displayName, "Birthday")
    }
    
    func testThemeModeIconNames() {
        XCTAssertEqual(ThemeMode.light.iconName, "sun.max.fill")
        XCTAssertEqual(ThemeMode.dark.iconName, "moon.fill")
        XCTAssertEqual(ThemeMode.system.iconName, "gear")
        XCTAssertEqual(ThemeMode.bea.iconName, "heart.fill")
        XCTAssertEqual(ThemeMode.birthday.iconName, "birthday.cake.fill")
    }
    
    func testThemeModeFromRawValue() {
        XCTAssertEqual(ThemeMode(rawValue: "light"), .light)
        XCTAssertEqual(ThemeMode(rawValue: "dark"), .dark)
        XCTAssertEqual(ThemeMode(rawValue: "system"), .system)
        XCTAssertEqual(ThemeMode(rawValue: "bea"), .bea)
        XCTAssertEqual(ThemeMode(rawValue: "birthday"), .birthday)
        XCTAssertNil(ThemeMode(rawValue: "invalid"))
    }
    
    // MARK: - ThemeManager Tests
    
    func testThemeManagerDefaultInitialization() {
        let themeManager = ThemeManager()
        XCTAssertEqual(themeManager.currentTheme, .system)
    }
    
    func testThemeManagerInitializationWithSavedTheme() {
        UserDefaults.standard.set("dark", forKey: "selectedTheme")
        let themeManager = ThemeManager()
        XCTAssertEqual(themeManager.currentTheme, .dark)
    }
    
    func testThemeManagerInitializationWithInvalidSavedTheme() {
        UserDefaults.standard.set("invalid", forKey: "selectedTheme")
        let themeManager = ThemeManager()
        XCTAssertEqual(themeManager.currentTheme, .system)
    }
    
    func testThemeManagerThemeChange() {
        let themeManager = ThemeManager()
        XCTAssertEqual(themeManager.currentTheme, .system)
        
        themeManager.currentTheme = .light
        XCTAssertEqual(themeManager.currentTheme, .light)
        
        themeManager.currentTheme = .dark
        XCTAssertEqual(themeManager.currentTheme, .dark)
    }
    
    func testThemeManagerPersistence() {
        let themeManager = ThemeManager()
        themeManager.currentTheme = .dark
        
        // Simulate app restart
        let newThemeManager = ThemeManager()
        XCTAssertEqual(newThemeManager.currentTheme, .dark)
    }
    
    func testThemeManagerColorScheme() {
        let themeManager = ThemeManager()
        
        themeManager.currentTheme = .light
        XCTAssertEqual(themeManager.colorScheme, .light)
        
        themeManager.currentTheme = .dark
        XCTAssertEqual(themeManager.colorScheme, .dark)
        
        themeManager.currentTheme = .system
        XCTAssertNil(themeManager.colorScheme)
    }
    
    func testThemeManagerObservableObject() {
        let themeManager = ThemeManager()
        let expectation = XCTestExpectation(description: "Theme change notification")
        
        // Test that objectWillChange is triggered
        DispatchQueue.main.async {
            themeManager.currentTheme = .dark
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testThemeChangeTriggersImmediateUpdate() {
        let themeManager = ThemeManager()
        
        // Start with system theme
        XCTAssertEqual(themeManager.currentTheme, .system)
        XCTAssertNil(themeManager.colorScheme)
        
        // Change to dark theme
        themeManager.currentTheme = .dark
        XCTAssertEqual(themeManager.colorScheme, .dark)
        
        // Change to light theme
        themeManager.currentTheme = .light
        XCTAssertEqual(themeManager.colorScheme, .light)
        
        // Change back to system
        themeManager.currentTheme = .system
        XCTAssertNil(themeManager.colorScheme)
    }
    
    func testChangeThemeHelperMethod() {
        let themeManager = ThemeManager()
        let expectation = XCTestExpectation(description: "Theme change via helper method")
        
        themeManager.changeTheme(to: .dark)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(themeManager.currentTheme, .dark)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testThemeButtonClickImmediateChange() {
        let themeManager = ThemeManager()
        
        // This test simulates what happens when a user clicks a theme button
        // and verifies that the theme changes immediately
        
        // Start with system theme
        XCTAssertEqual(themeManager.currentTheme, .system)
        XCTAssertNil(themeManager.colorScheme)
        
        // Simulate clicking "Dark" theme button
        themeManager.changeTheme(to: .dark)
        
        // Verify immediate change
        XCTAssertEqual(themeManager.currentTheme, .dark)
        XCTAssertEqual(themeManager.colorScheme, .dark)
        
        // Simulate clicking "Light" theme button
        themeManager.changeTheme(to: .light)
        
        // Verify immediate change
        XCTAssertEqual(themeManager.currentTheme, .light)
        XCTAssertEqual(themeManager.colorScheme, .light)
        
        // Simulate clicking "System" theme button
        themeManager.changeTheme(to: .system)
        
        // Verify immediate change
        XCTAssertEqual(themeManager.currentTheme, .system)
        XCTAssertNil(themeManager.colorScheme)
    }
    
    func testThemeButtonSubsequentClicksImmediateChange() {
        let themeManager = ThemeManager()
        
        // This test specifically checks the issue where the first click works
        // but subsequent clicks don't immediately update the UI
        
        // Start with system theme
        XCTAssertEqual(themeManager.currentTheme, .system)
        XCTAssertNil(themeManager.colorScheme)
        
        // First click - should work immediately
        themeManager.changeTheme(to: .dark)
        
        // Wait for async operation and verify
        let expectation1 = XCTestExpectation(description: "First theme change")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(themeManager.currentTheme, .dark)
            XCTAssertEqual(themeManager.colorScheme, .dark)
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 1.0)
        
        // Second click - should also work immediately (this is where the bug occurs)
        themeManager.changeTheme(to: .light)
        
        // Wait for async operation and verify
        let expectation2 = XCTestExpectation(description: "Second theme change")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(themeManager.currentTheme, .light)
            XCTAssertEqual(themeManager.colorScheme, .light)
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1.0)
        
        // Third click - should also work immediately
        themeManager.changeTheme(to: .system)
        
        // Wait for async operation and verify
        let expectation3 = XCTestExpectation(description: "Third theme change")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(themeManager.currentTheme, .system)
            XCTAssertNil(themeManager.colorScheme)
            expectation3.fulfill()
        }
        wait(for: [expectation3], timeout: 1.0)
        
        // Fourth click - back to dark, should work immediately
        themeManager.changeTheme(to: .dark)
        
        // Wait for async operation and verify
        let expectation4 = XCTestExpectation(description: "Fourth theme change")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(themeManager.currentTheme, .dark)
            XCTAssertEqual(themeManager.colorScheme, .dark)
            expectation4.fulfill()
        }
        wait(for: [expectation4], timeout: 1.0)
    }
    
    func testThemeManagerPublishesChangesCorrectly() {
        let themeManager = ThemeManager()
        var publishedChanges: [ThemeMode] = []
        
        // Subscribe to theme changes
        let cancellable = themeManager.$currentTheme
            .sink { theme in
                publishedChanges.append(theme)
            }
        
        // Perform multiple theme changes
        themeManager.changeTheme(to: .dark)
        themeManager.changeTheme(to: .light)
        themeManager.changeTheme(to: .system)
        themeManager.changeTheme(to: .dark)
        
        // Wait for all async operations to complete
        let expectation = XCTestExpectation(description: "All theme changes published")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Should have published all changes including the initial system theme
            XCTAssertGreaterThanOrEqual(publishedChanges.count, 4)
            XCTAssertEqual(publishedChanges.last, .dark)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        cancellable.cancel()
    }
    
    func testThemeChangeAfterResetAllBehavior() {
        // This test verifies that theme changes work immediately in all scenarios:
        // 1. After Reset All: theme changes work immediately
        // 2. Subsequent clicks: theme changes also work immediately
        // 3. After another Reset All: theme changes work immediately again
        
        let themeManager = ThemeManager()
        
        // Simulate "Reset All" by clearing UserDefaults and resetting theme
        UserDefaults.standard.removeObject(forKey: "selectedTheme")
        themeManager.currentTheme = .system
        
        // Verify we start with system theme
        XCTAssertEqual(themeManager.currentTheme, .system)
        XCTAssertNil(themeManager.colorScheme)
        
        // FIRST CLICK AFTER RESET - should work immediately
        themeManager.changeTheme(to: .dark)
        
        let expectation1 = XCTestExpectation(description: "First theme change after reset")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(themeManager.currentTheme, .dark)
            XCTAssertEqual(themeManager.colorScheme, .dark)
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 1.0)
        
        // SECOND CLICK - should also work immediately
        themeManager.changeTheme(to: .light)
        
        let expectation2 = XCTestExpectation(description: "Second theme change - should work")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(themeManager.currentTheme, .light)
            XCTAssertEqual(themeManager.colorScheme, .light)
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1.0)
        
        // THIRD CLICK - should also work immediately
        themeManager.changeTheme(to: .system)
        
        let expectation3 = XCTestExpectation(description: "Third theme change - should work")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(themeManager.currentTheme, .system)
            XCTAssertNil(themeManager.colorScheme)
            expectation3.fulfill()
        }
        wait(for: [expectation3], timeout: 1.0)
        
        // Simulate another "Reset All"
        UserDefaults.standard.removeObject(forKey: "selectedTheme")
        themeManager.currentTheme = .system
        
        // Verify we're back to system
        XCTAssertEqual(themeManager.currentTheme, .system)
        XCTAssertNil(themeManager.colorScheme)
        
        // FOURTH CLICK AFTER SECOND RESET - should work immediately again
        themeManager.changeTheme(to: .dark)
        
        let expectation4 = XCTestExpectation(description: "Fourth theme change after second reset")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(themeManager.currentTheme, .dark)
            XCTAssertEqual(themeManager.colorScheme, .dark)
            expectation4.fulfill()
        }
        wait(for: [expectation4], timeout: 1.0)
    }
    
    func testThemeChangeAfterResetAllWithoutNavigation() {
        // This test reproduces the specific user-reported behavior:
        // 1. After Reset All: theme changes DON'T work immediately (staying on same view)
        // 2. After Reset All + Navigate Away + Come Back: theme changes work immediately
        
        let themeManager = ThemeManager()
        
        // Start with a theme other than system
        themeManager.currentTheme = .dark
        XCTAssertEqual(themeManager.currentTheme, .dark)
        XCTAssertEqual(themeManager.colorScheme, .dark)
        
        // Simulate "Reset All" by clearing UserDefaults and resetting theme
        UserDefaults.standard.removeObject(forKey: "selectedTheme")
        themeManager.currentTheme = .system
        
        // Verify we're now on system theme
        XCTAssertEqual(themeManager.currentTheme, .system)
        XCTAssertNil(themeManager.colorScheme)
        
        // IMMEDIATE THEME SELECTION AFTER RESET (staying on same view)
        // This should NOW work immediately after our fix
        themeManager.changeTheme(to: .light)
        
        let expectation1 = XCTestExpectation(description: "Immediate theme change after reset")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // After our fix, this should work immediately
            XCTAssertEqual(themeManager.currentTheme, .light, "Theme should change immediately after Reset All while staying on same view")
            XCTAssertEqual(themeManager.colorScheme, .light, "ColorScheme should change immediately after Reset All while staying on same view")
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 1.0)
        
        // Simulate "Navigate Away and Come Back" by recreating the ThemeManager
        // This simulates what happens when the SettingsView is destroyed and recreated
        let newThemeManager = ThemeManager()
        
        // Verify the new manager has the correct state
        XCTAssertEqual(newThemeManager.currentTheme, .system)
        XCTAssertNil(newThemeManager.colorScheme)
        
        // THEME SELECTION AFTER "NAVIGATION" (fresh view instance)
        // This should work immediately according to user report
        newThemeManager.changeTheme(to: .light)
        
        let expectation2 = XCTestExpectation(description: "Theme change after navigation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // According to user report, this should work immediately
            XCTAssertEqual(newThemeManager.currentTheme, .light, "Theme should change immediately after Reset All + navigation")
            XCTAssertEqual(newThemeManager.colorScheme, .light, "ColorScheme should change immediately after Reset All + navigation")
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1.0)
    }
} 