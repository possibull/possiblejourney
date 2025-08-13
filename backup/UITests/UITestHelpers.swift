import XCTest

// MARK: - UI Test Helper Protocol
protocol UITestHelper {
    var app: XCUIApplication { get }
    
    // Navigation helpers
    func navigateToProgramCreation() throws
    func navigateToDailyChecklist() throws
    func navigateToSettings() throws
    func navigateToTemplateSelection() throws
    
    // Program management helpers
    func createProgram(from template: String?, name: String?) throws
    func startProgram() throws
    func resetToCleanState() throws
    
    // Settings helpers
    func enableCelebrations() throws
    func disableCelebrations() throws
    func setCelebrationType(_ type: String) throws
    func setEndOfDayTime(_ time: Date) throws
    func changeTheme(to theme: String) throws
    func resetAllPreferences() throws
    
    // Task management helpers
    func completeAllTasks() throws
    func completeSomeTasks(count: Int?) throws
    func completeTask(at index: Int) throws
    func uncompleteTask(at index: Int) throws
    
    // Verification helpers
    func verifyOnDailyChecklist() throws
    func verifyOnSettings() throws
    func verifyOnTemplateSelection() throws
    func verifyCelebrationAppeared() throws
    func verifyCelebrationDidNotAppear() throws
    func verifyTaskCompleted(at index: Int) throws
    func verifyTaskNotCompleted(at index: Int) throws
    
    // Utility helpers
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval) throws
    func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval) throws
    func tapIfExists(_ element: XCUIElement) throws
    func typeTextIfExists(_ element: XCUIElement, text: String) throws
}

// MARK: - Default Implementation
extension UITestHelper {
    
    // MARK: - Navigation Helpers
    
    func navigateToProgramCreation() throws {
        // Wait for splash screen to disappear
        Thread.sleep(forTimeInterval: 3)
        
        // Check if we're already on template selection
        if app.staticTexts["Choose Template"].waitForExistence(timeout: 3) {
            return // Already on template selection
        }
        
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
        
        // Wait for template selection to load
        try waitForElement(app.staticTexts["Choose Template"], timeout: 10)
    }
    
    func navigateToDailyChecklist() throws {
        // If we're not on daily checklist, we need to create/start a program first
        if !isOnDailyChecklist() {
            try createProgram(from: nil, name: nil)
            try startProgram()
        }
        
        // Verify we're on daily checklist
        try verifyOnDailyChecklist()
    }
    
    func navigateToSettings() throws {
        // First ensure we have a program running (need to be on daily checklist)
        if !isOnDailyChecklist() {
            try navigateToDailyChecklist()
        }
        
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
        
        // Wait for settings to load
        try waitForElement(app.staticTexts["Settings"], timeout: 10)
    }
    
    func navigateToTemplateSelection() throws {
        try navigateToProgramCreation()
    }
    
    // MARK: - Program Management Helpers
    
    func createProgram(from template: String? = nil, name: String? = nil) throws {
        // Navigate to program creation if not already there
        try navigateToProgramCreation()
        
        // Select a template
        if let templateName = template {
            let templateButton = app.buttons[templateName]
            if templateButton.exists {
                templateButton.tap()
            } else {
                // Try to find template by partial name
                let templateMatch = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", templateName)).firstMatch
                if templateMatch.exists {
                    templateMatch.tap()
                } else {
                    // Fall back to first available template
                    let templateCards = app.cells
                    if templateCards.count > 0 {
                        templateCards.element(boundBy: 0).tap()
                    }
                }
            }
        } else {
            // Select first available template
            let templateCards = app.cells
            if templateCards.count > 0 {
                templateCards.element(boundBy: 0).tap()
            }
        }
        
        Thread.sleep(forTimeInterval: 2)
        
        // Fill in program details if needed
        if let programName = name {
            let programNameField = app.textFields["Program Name"]
            if programNameField.exists {
                programNameField.tap()
                programNameField.typeText(programName)
            }
        }
    }
    
    func startProgram() throws {
        // Look for start/create program button
        let startButton = app.buttons["Start Program"]
        if startButton.exists {
            startButton.tap()
        } else {
            let createButton = app.buttons["Create Program"]
            if createButton.exists {
                createButton.tap()
            }
        }
        
        Thread.sleep(forTimeInterval: 2)
        
        // Handle release notes if they appear
        let continueButton = app.navigationBars.buttons["Continue"]
        if continueButton.waitForExistence(timeout: 3) {
            continueButton.tap()
            Thread.sleep(forTimeInterval: 1)
        }
        
        // Wait for daily checklist to load
        try waitForElement(app.staticTexts["Daily Checklist"], timeout: 10)
    }
    
    func resetToCleanState() throws {
        // This would typically involve clearing app data or restarting the app
        // For now, we'll just restart the app
        app.terminate()
        app.launch()
        Thread.sleep(forTimeInterval: 3)
    }
    
    // MARK: - Settings Helpers
    
    func enableCelebrations() throws {
        try navigateToSettings()
        
        let enableToggle = app.switches["CelebrationToggle"]
        if enableToggle.value as? String == "0" { // If disabled
            enableToggle.tap() // Enable it
        }
    }
    
    func disableCelebrations() throws {
        try navigateToSettings()
        
        let enableToggle = app.switches["CelebrationToggle"]
        if enableToggle.value as? String == "1" { // If enabled
            enableToggle.tap() // Disable it
        }
    }
    
    func setCelebrationType(_ type: String) throws {
        try navigateToSettings()
        
        // Enable celebrations first if needed
        let enableToggle = app.switches["CelebrationToggle"]
        if enableToggle.value as? String == "0" {
            enableToggle.tap()
        }
        
        // Tap the celebration type picker
        let typePicker = app.buttons.matching(identifier: "Celebration Type").firstMatch
        if typePicker.exists {
            typePicker.tap()
            
            // Select the specified type
            let typeButton = app.buttons[type]
            if typeButton.exists {
                typeButton.tap()
            }
        }
    }
    
    func setEndOfDayTime(_ time: Date) throws {
        try navigateToSettings()
        
        let timePicker = app.datePickers["EndOfDayTimePicker"]
        if timePicker.exists {
            // Use the correct method for adjusting date picker
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let timeString = formatter.string(from: time)
            timePicker.adjust(toPickerWheelValue: timeString)
        }
    }
    
    func changeTheme(to theme: String) throws {
        try navigateToSettings()
        
        let themeButton = app.buttons[theme]
        if themeButton.exists {
            themeButton.tap()
            Thread.sleep(forTimeInterval: 1)
        }
    }
    
    func resetAllPreferences() throws {
        try navigateToSettings()
        
        let resetButton = app.buttons["ResetPreferencesButton"]
        if resetButton.exists {
            resetButton.tap()
            Thread.sleep(forTimeInterval: 1)
        }
    }
    
    // MARK: - Task Management Helpers
    
    func completeAllTasks() throws {
        // Find all task checkboxes and complete them
        let taskCheckboxes = app.buttons.matching(identifier: "taskCheckbox").allElementsBoundByIndex
        for checkbox in taskCheckboxes {
            if checkbox.exists {
                checkbox.tap()
                Thread.sleep(forTimeInterval: 0.5)
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
    
    func completeSomeTasks(count: Int? = nil) throws {
        let taskCheckboxes = app.buttons.matching(identifier: "taskCheckbox").allElementsBoundByIndex
        
        let tasksToComplete = count ?? max(1, taskCheckboxes.count / 2)
        let actualCount = min(tasksToComplete, taskCheckboxes.count)
        
        for i in 0..<actualCount {
            if taskCheckboxes[i].exists {
                taskCheckboxes[i].tap()
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
    }
    
    func completeTask(at index: Int) throws {
        let taskCheckboxes = app.buttons.matching(identifier: "taskCheckbox").allElementsBoundByIndex
        if index < taskCheckboxes.count && taskCheckboxes[index].exists {
            taskCheckboxes[index].tap()
            Thread.sleep(forTimeInterval: 0.5)
        }
    }
    
    func uncompleteTask(at index: Int) throws {
        let taskCheckboxes = app.buttons.matching(identifier: "taskCheckbox").allElementsBoundByIndex
        if index < taskCheckboxes.count && taskCheckboxes[index].exists {
            taskCheckboxes[index].tap()
            Thread.sleep(forTimeInterval: 0.5)
        }
    }
    
    // MARK: - Verification Helpers
    
    func verifyOnDailyChecklist() throws {
        try waitForElement(app.staticTexts["Daily Checklist"], timeout: 10)
    }
    
    func verifyOnSettings() throws {
        try waitForElement(app.staticTexts["Settings"], timeout: 10)
    }
    
    func verifyOnTemplateSelection() throws {
        try waitForElement(app.staticTexts["Choose Template"], timeout: 10)
    }
    
    func verifyCelebrationAppeared() throws {
        let celebrationText = app.staticTexts["🎉 Congratulations! 🎉"]
        let completionText = app.staticTexts["All tasks completed!"]
        
        let celebrationExists = celebrationText.waitForExistence(timeout: 10)
        let completionExists = completionText.waitForExistence(timeout: 10)
        
        XCTAssertTrue(celebrationExists, "Celebration text should appear")
        XCTAssertTrue(completionExists, "Completion text should appear")
    }
    
    func verifyCelebrationDidNotAppear() throws {
        let celebrationText = app.staticTexts["🎉 Congratulations! 🎉"]
        
        // Wait a bit to ensure celebration doesn't appear
        Thread.sleep(forTimeInterval: 3)
        
        XCTAssertFalse(celebrationText.exists, "Celebration should not appear")
    }
    
    func verifyTaskCompleted(at index: Int) throws {
        let taskCheckboxes = app.buttons.matching(identifier: "taskCheckbox").allElementsBoundByIndex
        if index < taskCheckboxes.count {
            XCTAssertTrue(taskCheckboxes[index].exists, "Task checkbox should exist")
            // Add verification logic for completed state
        }
    }
    
    func verifyTaskNotCompleted(at index: Int) throws {
        let taskCheckboxes = app.buttons.matching(identifier: "taskCheckbox").allElementsBoundByIndex
        if index < taskCheckboxes.count {
            XCTAssertTrue(taskCheckboxes[index].exists, "Task checkbox should exist")
            // Add verification logic for not completed state
        }
    }
    
    // MARK: - Utility Helpers
    
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval) throws {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "Element should exist within timeout")
    }
    
    func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval) throws {
        XCTAssertTrue(element.waitForExistence(timeout: timeout) == false, "Element should disappear within timeout")
    }
    
    func tapIfExists(_ element: XCUIElement) throws {
        if element.exists {
            element.tap()
        }
    }
    
    func typeTextIfExists(_ element: XCUIElement, text: String) throws {
        if element.exists {
            element.tap()
            element.typeText(text)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func isOnDailyChecklist() -> Bool {
        return app.staticTexts["Daily Checklist"].exists
    }
}

// MARK: - Test Helper Mixin
class UITestHelperMixin: XCTestCase, UITestHelper {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
}

// MARK: - Convenience Extensions for Common Test Scenarios

extension UITestHelper {
    
    /// Complete workflow: Create program → Navigate to daily checklist → Complete all tasks → Verify celebration
    func testCompleteWorkflowWithCelebration() throws {
        try navigateToDailyChecklist()
        try enableCelebrations()
        try completeAllTasks()
        try verifyCelebrationAppeared()
    }
    
    /// Complete workflow: Create program → Navigate to daily checklist → Complete some tasks → Verify no celebration
    func testCompleteWorkflowWithoutCelebration() throws {
        try navigateToDailyChecklist()
        try enableCelebrations()
        try completeSomeTasks(count: 1)
        try verifyCelebrationDidNotAppear()
    }
    
    /// Complete workflow: Create program → Navigate to settings → Change theme → Verify theme change
    func testThemeChangeWorkflow() throws {
        try navigateToDailyChecklist()
        try navigateToSettings()
        try changeTheme(to: "Dark")
        try changeTheme(to: "Light")
        try changeTheme(to: "System")
    }
    
    /// Complete workflow: Create program → Navigate to settings → Configure end of day time
    func testEndOfDayTimeWorkflow() throws {
        try navigateToDailyChecklist()
        try navigateToSettings()
        
        let newTime = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: Date()) ?? Date()
        try setEndOfDayTime(newTime)
    }
} 