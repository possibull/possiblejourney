import XCTest

final class CelebrationUITests: UITestHelperMixin {
    
    // MARK: - Settings Tests
    
    func testCelebrationSettingsAccessibility() throws {
        // Given: App is launched and we navigate to settings
        try navigateToSettings()
        
        // Then: Celebration settings should be accessible
        let celebrationCard = app.staticTexts["Celebration Settings"]
        XCTAssertTrue(celebrationCard.exists, "Celebration Settings card should be visible")
        
        let enableCelebrationsToggle = app.switches["CelebrationToggle"]
        XCTAssertTrue(enableCelebrationsToggle.exists, "Enable Celebrations toggle should be visible")
        
        let celebrationTypePicker = app.buttons.matching(identifier: "Celebration Type").firstMatch
        XCTAssertTrue(celebrationTypePicker.exists, "Celebration Type picker should be visible")
    }
    
    func testCelebrationSettingsToggle() throws {
        // Given: We have a program and we're in settings
        try navigateToSettings()
        
        let enableToggle = app.switches["CelebrationToggle"]
        
        // When: Toggling celebration on/off
        let initialValue = enableToggle.value as? String
        
        enableToggle.tap()
        
        // Then: Toggle value should change
        let newValue = enableToggle.value as? String
        XCTAssertNotEqual(initialValue, newValue, "Toggle value should change when tapped")
        
        // When: Toggling back
        enableToggle.tap()
        
        // Then: Should return to original state
        let finalValue = enableToggle.value as? String
        XCTAssertEqual(initialValue, finalValue, "Toggle should return to original state")
    }
    
    func testCelebrationTypeSelection() throws {
        // Given: We have a program and we're in settings with celebrations enabled
        try navigateToSettings()
        
        let enableToggle = app.switches["CelebrationToggle"]
        if enableToggle.value as? String == "0" { // If disabled
            enableToggle.tap() // Enable it
        }
        
        let typePicker = app.buttons.matching(identifier: "Celebration Type").firstMatch
        
        // When: Tapping the celebration type picker
        typePicker.tap()
        
        // Then: Should show celebration type options
        // Note: In a real test, we would verify the picker shows the expected options
        // This is a basic test to ensure the picker is tappable
        XCTAssertTrue(typePicker.exists, "Celebration type picker should be tappable")
    }
    
    // MARK: - Daily Checklist Tests
    
    func testCelebrationAppearsWhenAllTasksCompleted() throws {
        // Given: We have a program with tasks and celebrations enabled
        try navigateToDailyChecklist()
        try enableCelebrations()
        
        // When: Completing all tasks
        try completeAllTasks()
        
        // Then: Celebration should appear
        try verifyCelebrationAppeared()
    }
    
    func testCelebrationDoesNotAppearWhenTasksIncomplete() throws {
        // Given: We have a program with tasks and celebrations enabled
        try navigateToDailyChecklist()
        try enableCelebrations()
        
        // When: Completing only some tasks (not all)
        try completeSomeTasks()
        
        // Then: Celebration should not appear
        try verifyCelebrationDidNotAppear()
    }
    
    func testCelebrationDoesNotAppearWhenDisabled() throws {
        // Given: We have a program with tasks but celebrations disabled
        try navigateToDailyChecklist()
        try disableCelebrations()
        
        // When: Completing all tasks
        try completeAllTasks()
        
        // Then: Celebration should not appear
        try verifyCelebrationDidNotAppear()
    }
    
    func testCelebrationAutoHides() throws {
        // Given: We have a program with tasks and celebrations enabled
        try navigateToDailyChecklist()
        try enableCelebrations()
        
        // When: Completing all tasks
        try completeAllTasks()
        
        // Then: Celebration should appear
        let celebrationText = app.staticTexts["🎉 Congratulations! 🎉"]
        XCTAssertTrue(celebrationText.waitForExistence(timeout: 10), "Celebration should appear")
        
        // When: Waiting for auto-hide (5 seconds)
        Thread.sleep(forTimeInterval: 6)
        
        // Then: Celebration should disappear
        XCTAssertFalse(celebrationText.exists, "Celebration should auto-hide after 5 seconds")
    }
    
    func testCelebrationCanBeDismissedByTap() throws {
        // Given: We have a program with tasks and celebrations enabled
        try navigateToDailyChecklist()
        try enableCelebrations()
        
        // When: Completing all tasks
        try completeAllTasks()
        
        // Then: Celebration should appear
        let celebrationText = app.staticTexts["🎉 Congratulations! 🎉"]
        XCTAssertTrue(celebrationText.waitForExistence(timeout: 10), "Celebration should appear")
        
        // When: Tapping on the celebration overlay
        app.tap()
        
        // Then: Celebration should disappear immediately
        XCTAssertFalse(celebrationText.exists, "Celebration should disappear when tapped")
    }
    
    // MARK: - Complete Workflow Tests
    
    func testCompleteWorkflowWithCelebration() throws {
        try testCompleteWorkflowWithCelebration()
    }
    
    func testCompleteWorkflowWithoutCelebration() throws {
        try testCompleteWorkflowWithoutCelebration()
    }
} 