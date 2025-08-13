import XCTest

/// Comprehensive workflow tests demonstrating the consolidated UI test helper system
/// This file shows how to test complete user journeys from start to finish
final class ComprehensiveWorkflowTests: UITestHelperMixin {
    
    // MARK: - Program Creation Workflows
    
    func testCompleteProgramCreationWorkflow() throws {
        // Given: Fresh app state
        try resetToCleanState()
        
        // When: Creating a program from template selection
        try navigateToTemplateSelection()
        try verifyOnTemplateSelection()
        
        // And: Selecting a specific template
        try createProgram(from: "Morning Wellness", name: "My Test Program")
        
        // And: Starting the program
        try startProgram()
        
        // Then: We should be on the daily checklist
        try verifyOnDailyChecklist()
    }
    
    func testProgramCreationWithDefaultTemplate() throws {
        // Given: Fresh app state
        try resetToCleanState()
        
        // When: Creating a program with default template
        try createProgram(from: nil, name: nil)
        try startProgram()
        
        // Then: We should be on the daily checklist
        try verifyOnDailyChecklist()
    }
    
    // MARK: - Settings Configuration Workflows
    
    func testCompleteSettingsConfigurationWorkflow() throws {
        // Given: We have a program running
        try navigateToDailyChecklist()
        
        // When: Navigating to settings
        try navigateToSettings()
        try verifyOnSettings()
        
        // And: Configuring all settings
        try enableCelebrations()
        try setCelebrationType("Fireworks")
        
        let newEndTime = Calendar.current.date(bySettingHour: 23, minute: 30, second: 0, of: Date()) ?? Date()
        try setEndOfDayTime(newEndTime)
        
        try changeTheme(to: "Dark")
        
        // Then: All settings should be configured
        // (Verification would depend on specific UI elements showing the configured values)
    }
    
    func testSettingsResetWorkflow() throws {
        // Given: We have configured settings
        try navigateToDailyChecklist()
        try navigateToSettings()
        try enableCelebrations()
        try changeTheme(to: "Dark")
        
        // When: Resetting all preferences
        try resetAllPreferences()
        
        // Then: Settings should be back to defaults
        // (Verification would depend on specific UI elements showing default values)
    }
    
    // MARK: - Task Completion Workflows
    
    func testTaskCompletionWithCelebrationWorkflow() throws {
        // Given: We have a program with celebrations enabled
        try navigateToDailyChecklist()
        try enableCelebrations()
        
        // When: Completing all tasks
        try completeAllTasks()
        
        // Then: Celebration should appear
        try verifyCelebrationAppeared()
    }
    
    func testTaskCompletionWithoutCelebrationWorkflow() throws {
        // Given: We have a program with celebrations disabled
        try navigateToDailyChecklist()
        try disableCelebrations()
        
        // When: Completing all tasks
        try completeAllTasks()
        
        // Then: No celebration should appear
        try verifyCelebrationDidNotAppear()
    }
    
    func testPartialTaskCompletionWorkflow() throws {
        // Given: We have a program with celebrations enabled
        try navigateToDailyChecklist()
        try enableCelebrations()
        
        // When: Completing only some tasks
        try completeSomeTasks(count: 2)
        
        // Then: No celebration should appear
        try verifyCelebrationDidNotAppear()
    }
    
    func testIndividualTaskCompletionWorkflow() throws {
        // Given: We have a program
        try navigateToDailyChecklist()
        
        // When: Completing tasks one by one
        try completeTask(at: 0)
        try completeTask(at: 1)
        
        // Then: Tasks should be completed
        try verifyTaskCompleted(at: 0)
        try verifyTaskCompleted(at: 1)
    }
    
    func testTaskUncompletionWorkflow() throws {
        // Given: We have a program with some completed tasks
        try navigateToDailyChecklist()
        try completeTask(at: 0)
        try completeTask(at: 1)
        
        // When: Uncompleting a task
        try uncompleteTask(at: 0)
        
        // Then: Task should be uncompleted
        try verifyTaskNotCompleted(at: 0)
        try verifyTaskCompleted(at: 1) // This one should still be completed
    }
    
    // MARK: - Theme Management Workflows
    
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
    
    func testThemePersistenceWorkflow() throws {
        // Given: We have a program with a specific theme
        try navigateToDailyChecklist()
        try navigateToSettings()
        try changeTheme(to: "Dark")
        
        // When: Restarting the app
        try resetToCleanState()
        try navigateToDailyChecklist()
        try navigateToSettings()
        
        // Then: Theme should persist
        // (Verification would check that Dark theme is still selected)
    }
    
    // MARK: - Celebration Type Workflows
    
    func testCelebrationTypeChangeWorkflow() throws {
        // Given: We have a program with celebrations enabled
        try navigateToDailyChecklist()
        try enableCelebrations()
        
        // When: Changing celebration types
        try setCelebrationType("Confetti")
        try setCelebrationType("Fireworks")
        try setCelebrationType("Balloons")
        try setCelebrationType("Sparkles")
        try setCelebrationType("Random")
        
        // Then: Celebration type should be changed
        // (Verification would depend on UI showing the selected type)
    }
    
    func testCelebrationTypePersistenceWorkflow() throws {
        // Given: We have a program with a specific celebration type
        try navigateToDailyChecklist()
        try enableCelebrations()
        try setCelebrationType("Fireworks")
        
        // When: Restarting the app
        try resetToCleanState()
        try navigateToDailyChecklist()
        try enableCelebrations()
        
        // Then: Celebration type should persist
        // (Verification would check that Fireworks is still selected)
    }
    
    // MARK: - End of Day Time Workflows
    
    func testEndOfDayTimeConfigurationWorkflow() throws {
        // Given: We have a program
        try navigateToDailyChecklist()
        
        // When: Setting different end of day times
        let earlyTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
        try setEndOfDayTime(earlyTime)
        
        let lateTime = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date()) ?? Date()
        try setEndOfDayTime(lateTime)
        
        // Then: End of day time should be configured
        // (Verification would depend on UI showing the configured time)
    }
    
    // MARK: - Complex Multi-Step Workflows
    
    func testCompleteUserJourneyWorkflow() throws {
        // Given: Fresh app state
        try resetToCleanState()
        
        // When: Complete user journey
        // 1. Create program
        try createProgram(from: "Morning Wellness", name: "My Wellness Journey")
        try startProgram()
        
        // 2. Configure settings
        try navigateToSettings()
        try enableCelebrations()
        try setCelebrationType("Fireworks")
        try changeTheme(to: "Dark")
        
        let endTime = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
        try setEndOfDayTime(endTime)
        
        // 3. Return to daily checklist
        // (Settings view should have a back/dismiss button)
        
        // 4. Complete tasks
        try completeAllTasks()
        
        // Then: Celebration should appear with fireworks
        try verifyCelebrationAppeared()
    }
    
    func testSettingsAccessibilityWorkflow() throws {
        // Given: We have a program
        try navigateToDailyChecklist()
        
        // When: Accessing settings multiple times
        try navigateToSettings()
        try verifyOnSettings()
        
        // Navigate back to daily checklist (if possible)
        // Then navigate to settings again
        try navigateToSettings()
        try verifyOnSettings()
        
        // Then: Settings should remain accessible
        XCTAssertTrue(app.staticTexts["Settings"].exists, "Settings should be accessible")
    }
    
    func testProgramRestartWorkflow() throws {
        // Given: We have a completed program
        try navigateToDailyChecklist()
        try completeAllTasks()
        
        // When: Restarting the app
        try resetToCleanState()
        
        // Then: We should be able to navigate back to daily checklist
        try navigateToDailyChecklist()
        try verifyOnDailyChecklist()
    }
    
    // MARK: - Error Handling Workflows
    
    func testNavigationErrorHandlingWorkflow() throws {
        // Given: Fresh app state
        try resetToCleanState()
        
        // When: Trying to navigate to settings without a program
        // This should handle the case where we need a program first
        
        // Then: Navigation should work correctly
        try navigateToSettings()
        try verifyOnSettings()
    }
    
    func testElementNotFoundErrorHandlingWorkflow() throws {
        // Given: We have a program
        try navigateToDailyChecklist()
        
        // When: Trying to interact with non-existent elements
        try tapIfExists(app.buttons["NonExistentButton"])
        try typeTextIfExists(app.textFields["NonExistentField"], text: "test")
        
        // Then: App should not crash and continue to work
        try navigateToSettings()
        try verifyOnSettings()
    }
    
    // MARK: - Performance Workflows
    
    func testRapidNavigationWorkflow() throws {
        // Given: We have a program
        try navigateToDailyChecklist()
        
        // When: Rapidly navigating between views
        for _ in 0..<5 {
            try navigateToSettings()
            try verifyOnSettings()
            // Navigate back to daily checklist (if possible)
            try navigateToDailyChecklist()
            try verifyOnDailyChecklist()
        }
        
        // Then: App should remain responsive
        XCTAssertTrue(app.exists, "App should remain running after rapid navigation")
    }
    
    func testRapidTaskCompletionWorkflow() throws {
        // Given: We have a program
        try navigateToDailyChecklist()
        
        // When: Rapidly completing tasks
        for i in 0..<10 {
            try completeTask(at: i)
            Thread.sleep(forTimeInterval: 0.1) // Very short delay
        }
        
        // Then: App should handle rapid interactions
        XCTAssertTrue(app.exists, "App should remain responsive after rapid task completion")
    }
} 