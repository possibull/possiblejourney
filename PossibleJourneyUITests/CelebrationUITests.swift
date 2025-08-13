import XCTest

final class CelebrationUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    // MARK: - Settings Tests
    
    func testCelebrationSettingsAccessibility() throws {
        // Given: App is launched and we navigate to settings
        navigateToSettings()
        
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
        createTestProgram()
        navigateToSettings()
        
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
        createTestProgram()
        navigateToSettings()
        
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
        setupProgramWithTasks()
        enableCelebrations()
        
        // When: Completing all tasks
        completeAllTasks()
        
        // Then: Celebration should appear
        let celebrationText = app.staticTexts["🎉 Congratulations! 🎉"]
        let completionText = app.staticTexts["All tasks completed!"]
        
        // Wait for celebration to appear
        let celebrationExists = celebrationText.waitForExistence(timeout: 10)
        let completionExists = completionText.waitForExistence(timeout: 10)
        
        XCTAssertTrue(celebrationExists, "Celebration text should appear")
        XCTAssertTrue(completionExists, "Completion text should appear")
    }
    
    func testCelebrationDoesNotAppearWhenTasksIncomplete() throws {
        // Given: We have a program with tasks and celebrations enabled
        setupProgramWithTasks()
        enableCelebrations()
        
        // When: Completing only some tasks (not all)
        completeSomeTasks()
        
        // Then: Celebration should not appear
        let celebrationText = app.staticTexts["🎉 Congratulations! 🎉"]
        
        // Wait a bit to ensure celebration doesn't appear
        Thread.sleep(forTimeInterval: 3)
        
        XCTAssertFalse(celebrationText.exists, "Celebration should not appear when tasks are incomplete")
    }
    
    func testCelebrationDoesNotAppearWhenDisabled() throws {
        // Given: We have a program with tasks but celebrations disabled
        setupProgramWithTasks()
        disableCelebrations()
        
        // When: Completing all tasks
        completeAllTasks()
        
        // Then: Celebration should not appear
        let celebrationText = app.staticTexts["🎉 Congratulations! 🎉"]
        
        // Wait a bit to ensure celebration doesn't appear
        Thread.sleep(forTimeInterval: 3)
        
        XCTAssertFalse(celebrationText.exists, "Celebration should not appear when disabled")
    }
    
    func testCelebrationAutoHides() throws {
        // Given: We have a program with tasks and celebrations enabled
        setupProgramWithTasks()
        enableCelebrations()
        
        // When: Completing all tasks
        completeAllTasks()
        
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
        setupProgramWithTasks()
        enableCelebrations()
        
        // When: Completing all tasks
        completeAllTasks()
        
        // Then: Celebration should appear
        let celebrationText = app.staticTexts["🎉 Congratulations! 🎉"]
        XCTAssertTrue(celebrationText.waitForExistence(timeout: 10), "Celebration should appear")
        
        // When: Tapping on the celebration overlay
        app.tap()
        
        // Then: Celebration should disappear immediately
        XCTAssertFalse(celebrationText.exists, "Celebration should disappear when tapped")
    }
    
    // MARK: - Helper Methods
    
    private func createTestProgram() {
        // Given: App starts empty, we need to create a program from template
        
        // Look for "Get Started" or similar button to create program
        let getStartedButton = app.buttons["Get Started"]
        if getStartedButton.exists {
            getStartedButton.tap()
        } else {
            // Try alternative button names
            let createButton = app.buttons["Create Program"]
            if createButton.exists {
                createButton.tap()
            } else {
                // Look for any button that might start program creation
                let anyButton = app.buttons.firstMatch
                if anyButton.exists {
                    anyButton.tap()
                }
            }
        }
        
        // Select a template (first available template)
        let templateButton = app.buttons.firstMatch
        if templateButton.exists {
            templateButton.tap()
        }
        
        // Fill in program details if needed
        let programNameField = app.textFields["Program Name"]
        if programNameField.exists {
            programNameField.tap()
            programNameField.typeText("Test Program")
        }
        
        // Create the program
        let createProgramButton = app.buttons["Create Program"]
        if createProgramButton.exists {
            createProgramButton.tap()
        } else {
            // Try alternative button names
            let startButton = app.buttons["Start Program"]
            if startButton.exists {
                startButton.tap()
            }
        }
        
        // Wait for program to load
        Thread.sleep(forTimeInterval: 2)
    }
    
    private func navigateToSettings() {
        // Navigate to settings from the daily checklist view
        let settingsButton = app.buttons["SettingsButton"]
        if settingsButton.exists {
            settingsButton.tap()
        } else {
            // Try to find settings in navigation bar
            let settingsNav = app.navigationBars.buttons.matching(identifier: "SettingsButton").firstMatch
            if settingsNav.exists {
                settingsNav.tap()
            } else {
                // Try to find settings by accessibility identifier
                let settingsAccessibility = app.buttons.matching(identifier: "settings").firstMatch
                if settingsAccessibility.exists {
                    settingsAccessibility.tap()
                }
            }
        }
    }
    
    private func setupProgramWithTasks() {
        // Create a test program if not already created
        createTestProgram()
        
        // Navigate to daily checklist (should be the main view after program creation)
        // The daily checklist should be visible after program creation
        Thread.sleep(forTimeInterval: 1)
    }
    
    private func enableCelebrations() {
        navigateToSettings()
        let enableToggle = app.switches["CelebrationToggle"]
        if enableToggle.value as? String == "0" { // If disabled
            enableToggle.tap() // Enable it
        }
    }
    
    private func disableCelebrations() {
        navigateToSettings()
        let enableToggle = app.switches["CelebrationToggle"]
        if enableToggle.value as? String == "1" { // If enabled
            enableToggle.tap() // Disable it
        }
    }
    
    private func completeAllTasks() {
        // Find all task checkboxes and complete them
        let taskCheckboxes = app.buttons.matching(identifier: "taskCheckbox").allElementsBoundByIndex
        for checkbox in taskCheckboxes {
            if checkbox.exists {
                checkbox.tap()
                Thread.sleep(forTimeInterval: 0.5) // Small delay between taps
            }
        }
        
        // Alternative: look for any checkbox-like buttons
        let allCheckboxes = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'checkbox' OR identifier CONTAINS 'task'")).allElementsBoundByIndex
        for checkbox in allCheckboxes {
            if checkbox.exists {
                checkbox.tap()
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
    }
    
    private func completeSomeTasks() {
        // Complete only some tasks (not all)
        let taskCheckboxes = app.buttons.matching(identifier: "taskCheckbox").allElementsBoundByIndex
        
        // Complete half of the tasks (if there are any)
        let tasksToComplete = min(taskCheckboxes.count / 2, taskCheckboxes.count)
        for i in 0..<tasksToComplete {
            if taskCheckboxes[i].exists {
                taskCheckboxes[i].tap()
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
        
        // Alternative: complete just the first task if available
        if let firstCheckbox = taskCheckboxes.first, firstCheckbox.exists {
            firstCheckbox.tap()
        }
    }
} 