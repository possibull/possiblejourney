import XCTest

func launchAppWithReset() -> XCUIApplication {
    let app = XCUIApplication()
    app.launchArguments.append("--uitesting-reset")
    app.launch()
    return app
}

final class PossibleJourneyUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        // No need to clear UserDefaults here; handled by launch argument
    }

    func testAddTaskFlow() throws {
        let app = launchAppWithReset()
        app.addTask(title: "Read", description: "Read 10 pages")
        // Verify the task appears in the list
        let taskCell = app.staticTexts["Read"]
        XCTAssertTrue(taskCell.waitForExistence(timeout: 1))
    }

    func setupProgram(app: XCUIApplication, tasks: [(title: String, description: String)] = [("Read", "Read 10 pages"), ("Drink Water", "Drink 2L of water")], checkChecklist: Bool = true) {
        app.checkOnScreen(identifier: "ProgramSetupScreen", message: "Should start on Program Setup screen")
        for task in tasks {
            app.addTask(title: task.title, description: task.description)
        }
        app.saveProgram()
        if checkChecklist {
            app.checkOnScreen(identifier: "DailyChecklistScreen", message: "Should navigate to checklist after saving program")
        }
    }

    func testSaveProgramButtonExistsAndCanBeTapped() throws {
        let app = launchAppWithReset()
        setupProgram(app: app, tasks: [("Read", "Read 10 pages")])
        app.checkOnScreen(identifier: "DailyChecklistScreen", message: "Should navigate to checklist after saving program")
    }

    func testSaveProgramButtonDisabledWhenNoTasks() throws {
        let app = launchAppWithReset()
        let saveButton = app.buttons["Save Program"]
        XCTAssertTrue(saveButton.exists)
        XCTAssertFalse(saveButton.isEnabled)
    }

    func testSaveProgramNavigatesToDailyChecklist() throws {
        let app = launchAppWithReset()
        setupProgram(app: app)
    }

    func testProgramPersistsAndChecklistAppearsOnRelaunch() throws {
        let app = launchAppWithReset()
        // Verify we are on the Program Setup screen before adding a program
        app.checkOnScreen(identifier: "ProgramSetupScreen", message: "Should start on Program Setup screen")
        // First launch: create and save a program, navigate to checklist
        app.addProgramAndNavigateToChecklist()
        // Relaunch: check for checklist or setup screen using accessibility identifiers
        app.terminate()
        // On relaunch, do not use the reset argument
        app.launchArguments = []
        app.launch()
        print(app.debugDescription) // Print accessibility hierarchy after relaunch
        // Print all images and their accessibility identifiers
        let images = app.images.allElementsBoundByIndex
        for image in images {
            print("DEBUG: Image identifier: \(image.identifier), label: \(image.label)")
        }
        app.checkOnScreen(identifier: "DailyChecklistScreen", timeout: 5, message: "Should be on Daily Checklist screen after relaunch")
    }

    func testChecklistTaskCompletionPersistsAfterRelaunch() throws {
        let app = launchAppWithReset()
        // Use helper to set up program and tasks
        setupProgram(app: app, tasks: [
            (title: "Read", description: "Read 10 pages"),
            (title: "Drink Water", description: "Drink 2L of water")
        ], checkChecklist: true)
        enableDebugModeByTappingAllSwitches(in: app)
        // Tap Back button to return to checklist (before first debug prints)
        let backButton1 = app.buttons["Back"]
        if backButton1.exists {
            backButton1.tap()
        }
        // Get the task IDs from the debug label (while debug window is still visible)
        let debugTaskIDsBefore = app.staticTexts["TaskIDsDebug"].label
        print("DEBUG: TaskIDsDebug before relaunch: \(debugTaskIDsBefore)")
        // Print debug completed task IDs before relaunch
        let debugCompletedTaskIDsBefore = app.staticTexts["DebugCompletedTaskIDsLabel"].label
        print("DEBUG: CompletedTaskIDsDebug before relaunch: \(debugCompletedTaskIDsBefore)")
        // Minimize the debug window by tapping the spyglass icon
        let debugIcon = app.images["magnifyingglass"]
        if debugIcon.exists {
            debugIcon.tap()
        }
        // Get the Read task's ID (assume it's the first in the list)
        let taskIDsString = debugTaskIDsBefore.replacingOccurrences(of: "TaskIDs: ", with: "")
        let readTaskID = taskIDsString.components(separatedBy: ",").first!.trimmingCharacters(in: .whitespaces)
        let readTaskCell = app.staticTexts["TaskCell_\(readTaskID)"]
        XCTAssertTrue(readTaskCell.exists, "Read task cell should exist")
        // Tap the checkmark button for the Read task
        var checkmark = app.buttons["checkmark_\(readTaskID)"]
        if !checkmark.exists {
            checkmark = app.otherElements["checkmark_\(readTaskID)"]
        }
        XCTAssertTrue(checkmark.exists, "Checkmark for Read task should exist")
        checkmark.tap()
        // Relaunch app (no reset)
        app.terminate()
        app.launchArguments = []
        app.launch()

        // Wait for checklist screen after relaunch
        let checklistScreen = app.otherElements["DailyChecklistScreen"]
        XCTAssertTrue(checklistScreen.waitForExistence(timeout: 5), "Checklist screen should appear after relaunch")
        // Wait for the completed task cell to appear
        let completedTaskCell = app.staticTexts["TaskCell_\(readTaskID)"]
        XCTAssertTrue(completedTaskCell.waitForExistence(timeout: 5), "Completed task cell should appear after relaunch")
        // Wait for the checkmark button to appear
        let completedCheckmark = app.buttons["checkmark_\(readTaskID)"]
        XCTAssertTrue(completedCheckmark.waitForExistence(timeout: 5), "Completed checkmark should appear after relaunch")

        // If the checkmark is visually selected, assert and return
        if completedCheckmark.isSelected {
            XCTAssertTrue(completedCheckmark.isSelected, "Read task should be visually checked after relaunch")
            return
        }

        // If not visually checked, enable debug mode and use debug labels for further diagnosis
        enableDebugModeByTappingAllSwitches(in: app)
        let backButton = app.buttons["Back"]
        if backButton.exists { backButton.tap() }
        let debugCompletedTaskIDsAfter = app.staticTexts["DebugCompletedTaskIDsLabel"].label
        let completedTaskIDsAfter = debugCompletedTaskIDsAfter.components(separatedBy: ",")
        XCTAssertTrue(completedTaskIDsAfter.contains(readTaskID), "Read task should be marked as complete after relaunch (debug)")
        // Print all images and their accessibility identifiers
        let images = app.images.allElementsBoundByIndex
        for image in images {
            print("DEBUG: Image identifier: \(image.identifier), label: \(image.label)")
        }
    }

    func testChecklistShowsMissedDayModalAfterEndOfDayIfTasksIncomplete() throws {
        let app = launchAppWithReset()
        setupMissedDayScenario(app: app)
        // Assert missed day screen appears directly after relaunch
        let missedDayLabel = app.staticTexts["MissedDayScreen"]
        let foundMissedDayLabel = missedDayLabel.waitForExistence(timeout: 10)
        if foundMissedDayLabel {
            XCTAssertTrue(foundMissedDayLabel, "Missed day screen should appear after end of day if tasks are incomplete")
            return
        }
        // If not found, enable debug mode and print debug info
        enableDebugModeByTappingAllSwitches(in: app)
        let backButton = app.buttons["Back"]
        if backButton.exists { backButton.tap() }
        let debugLabel = app.staticTexts["DEBUG"].label
        print("DEBUG: Debug label after relaunch: \(debugLabel)")
        // Add more debug prints as needed
        XCTFail("Missed day screen did not appear; debug info printed above")
    }

    func testSettingsViewShowsEndOfDayTimePicker() throws {
        let app = launchAppWithReset()
        // Complete program setup to reach Daily Checklist screen
        app.addTask(title: "Read", description: "Read 10 pages")
        app.saveProgram()
        // Now tap the Settings button
        let settingsButton = app.buttons["SettingsButton"]
        XCTAssertTrue(settingsButton.exists)
        settingsButton.tap()
        // Assert End of Day Time picker/label exists
        let endOfDayTime = app.datePickers["EndOfDayTimePicker"]
        XCTAssertTrue(endOfDayTime.exists, "End of Day Time picker/label should exist in Settings view")
    }

    func enableDebugModeByTappingAllSwitches(in app: XCUIApplication) {
        let settingsButton = app.buttons["SettingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 2))
        settingsButton.tap()
        enableDebugModeByTappingAllSwitchesInSettings(in: app)
        // Maximize debug window if possible
        let debugToggle = app.switches["DebugToggle"]
        if debugToggle.exists && (debugToggle.value as? String == "0") {
            debugToggle.tap()
        }
        // Try to expand debug window if a control exists
        let expandButton = app.buttons["ExpandDebugWindow"]
        if expandButton.exists {
            expandButton.tap()
            // Check for expanded debug content
            let programUUIDLabel = app.staticTexts["DebugProgramUUIDLabel"]
            if !programUUIDLabel.waitForExistence(timeout: 2) {
                XCTFail("Failed to maximize debug window: DebugProgramUUIDLabel not visible after expand")
                fatalError("Failed to maximize debug window: DebugProgramUUIDLabel not visible after expand")
            }
        }
    }

    func enableDebugModeByTappingAllSwitchesInSettings(in app: XCUIApplication) {
        let allSwitches = app.switches.allElementsBoundByIndex
        for (index, sw) in allSwitches.enumerated() {
            print("DEBUG: Switch[\(index)]: label='\(sw.label)', value='\(sw.value ?? "nil")'")
            if sw.value as? String == "0" {
                sw.tap()
                print("DEBUG: Tapped switch[\(index)] with label '\(sw.label)'")
                sleep(1)
            }
        }
        // Assert debug label is visible
        let debugLabel = app.staticTexts["DEBUG"]
        let debugNowLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'DEBUG now:'"))
        XCTAssertTrue(debugLabel.exists || debugNowLabel.count > 0, "Debug label should be visible in UI after toggling all switches")
        // Try to expand debug window if a control exists
        let expandButton = app.buttons["ExpandDebugWindow"]
        if expandButton.exists {
            expandButton.tap()
            // Check for expanded debug content
            let programUUIDLabel = app.staticTexts["DebugProgramUUIDLabel"]
            if !programUUIDLabel.waitForExistence(timeout: 2) {
                XCTFail("Failed to maximize debug window: DebugProgramUUIDLabel not visible after expand")
                fatalError("Failed to maximize debug window: DebugProgramUUIDLabel not visible after expand")
            }
        }
    }

    func testSettingsDebugToggleAndEODPicker() {
        let app = launchAppWithReset()
        setupProgram(app: app)
        enableDebugModeByTappingAllSwitches(in: app)
        // Set EOD picker to 8:00 PM
        let endOfDayPicker = app.datePickers["EndOfDayTimePicker"]
        XCTAssertTrue(endOfDayPicker.waitForExistence(timeout: 3), "EndOfDayTimePicker should exist")
        let hourWheel = endOfDayPicker.pickerWheels.element(boundBy: 0)
        let minuteWheel = endOfDayPicker.pickerWheels.element(boundBy: 1)
        let amPmWheel = endOfDayPicker.pickerWheels.element(boundBy: 2)
        hourWheel.adjust(toPickerWheelValue: "8")
        minuteWheel.adjust(toPickerWheelValue: "00")
        amPmWheel.adjust(toPickerWheelValue: "PM")
        print("DEBUG: Set EOD to 8:00 PM")
        // Assert picker wheels are set (robust contains check)
        let hourValue = hourWheel.value as? String ?? ""
        let minuteValue = minuteWheel.value as? String ?? ""
        let ampmValue = amPmWheel.value as? String ?? ""
        print("DEBUG: Hour wheel value after set: \(hourValue)")
        print("DEBUG: Minute wheel value after set: \(minuteValue)")
        print("DEBUG: AM/PM wheel value after set: \(ampmValue)")
        XCTAssertTrue(hourValue.contains("8"), "Hour wheel should contain '8', got: \(hourValue)")
        XCTAssertTrue(minuteValue.contains("00"), "Minute wheel should contain '00', got: \(minuteValue)")
        XCTAssertTrue(ampmValue.uppercased().contains("PM"), "AM/PM wheel should be PM, got: \(ampmValue)")
    }

    func testGoDirectlyToSettingsAndMaximizeDebug() {
        let app = launchAppWithReset()
        // Complete program setup to reach Daily Checklist screen
        app.addTask(title: "Read", description: "Read 10 pages")
        app.saveProgram()
        // Go directly to settings
        let settingsButton = app.buttons["SettingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 2), "Settings button should exist")
        settingsButton.tap()
        // Enable and maximize debug
        enableDebugModeByTappingAllSwitchesInSettings(in: app)
        // Tap the expand debug window icon (try multiple element types)
        var didTapExpand = false
        let expandButton = app.buttons["ExpandDebugWindow"]
        if expandButton.exists {
            expandButton.tap()
            didTapExpand = true
        } else {
            let expandOther = app.otherElements["ExpandDebugWindow"]
            if expandOther.exists {
                expandOther.tap()
                didTapExpand = true
            } else {
                let expandImage = app.images["ExpandDebugWindow"]
                if expandImage.exists {
                    expandImage.tap()
                    didTapExpand = true
                }
            }
        }
        XCTAssertTrue(didTapExpand, "Expand debug window icon should exist and be tappable (button, other, or image)")
        // Assert debug window is maximized
        let programUUIDLabel = app.staticTexts["DebugProgramUUIDLabel"]
        XCTAssertTrue(programUUIDLabel.waitForExistence(timeout: 2), "Debug window should be maximized and show Program UUID label")
    }

    /*
    func testResetProgramReturnsToSetupScreen() throws {
        let app = XCUIApplication()
        app.launch()
        // Create and save a program
        let titleField = app.textFields["Task Title"]
        XCTAssertTrue(titleField.exists)
        titleField.tap()
        titleField.typeText("Read")
        let descriptionField = app.textFields["Task Description"]
        XCTAssertTrue(descriptionField.exists)
        descriptionField.tap()
        descriptionField.typeText("Read 10 pages")
        let addButton = app.buttons["Add Task"]
        print("DEBUG: About to tap Add Task, isEnabled: \(addButton.isEnabled)")
        XCTAssertTrue(addButton.exists)
        XCTAssertTrue(addButton.isEnabled)
        addButton.tap()
        let saveButton = app.buttons["Save Program"]
        print("DEBUG: About to tap Save Program, isEnabled: \(saveButton.isEnabled)")
        XCTAssertTrue(saveButton.exists)
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()
        let checklistHeader = app.staticTexts["Today's Tasks"]
        XCTAssertTrue(checklistHeader.waitForExistence(timeout: 2))
        print(app.debugDescription)
        // Open settings
        let settingsButton = app.buttons["SettingsButton"]
        XCTAssertTrue(settingsButton.exists)
        settingsButton.tap()
        // Tap Reset Program
        let resetButton = app.buttons["Reset Program"]
        XCTAssertTrue(resetButton.exists)
        resetButton.tap()
        // Wait for the settings sheet to be dismissed
        sleep(1)
        // Should return to setup screen
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
    }
*/

    // NOTE: Swipe-to-delete is tested manually due to XCTest limitations with SwiftUI Lists. The system Delete button is not reliably accessible in UI tests.

    func setupMissedDayScenario(app: XCUIApplication, eodHour: String = "8", missedTime: String = "2025-07-24T21:00:00Z") {
        // Setup program
        setupProgram(app: app)
        // Go to Settings
        let settingsButton = app.buttons["SettingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 2))
        settingsButton.tap()
        // Enable debug mode (assume already in Settings)
        enableDebugModeByTappingAllSwitchesInSettings(in: app)
        // Set EOD picker
        let endOfDayPicker = app.datePickers["EndOfDayTimePicker"]
        XCTAssertTrue(endOfDayPicker.waitForExistence(timeout: 3), "EndOfDayTimePicker should exist")
        let hourWheel = endOfDayPicker.pickerWheels.element(boundBy: 0)
        let minuteWheel = endOfDayPicker.pickerWheels.element(boundBy: 1)
        let amPmWheel = endOfDayPicker.pickerWheels.element(boundBy: 2)
        hourWheel.adjust(toPickerWheelValue: eodHour)
        minuteWheel.adjust(toPickerWheelValue: "00")
        amPmWheel.adjust(toPickerWheelValue: "PM")
        print("DEBUG: Set EOD to \(eodHour):00 PM")
        // Go back to checklist
        let backButton = app.buttons["Back"]
        if backButton.exists { backButton.tap() }
        // Relaunch app with time override to simulate missed day
        app.terminate()
        app.launchArguments.append("-currentTimeOverride")
        app.launchArguments.append(missedTime)
        app.launch()
    }

    func testMissedDayScreen_IMissedIt_ResetsToDay1() {
        let app = launchAppWithReset()
        setupMissedDayScenario(app: app)
        // Print all buttons and static texts after missed day screen appears
        print("DEBUG: All buttons after missed day screen appears:")
        let allButtons = app.buttons.allElementsBoundByIndex
        for (index, button) in allButtons.enumerated() {
            print("DEBUG: Button[\(index)]: label='\(button.label)', identifier='\(button.identifier)'")
        }
        print("DEBUG: All static text after missed day screen appears:")
        let allStaticTexts = app.staticTexts.allElementsBoundByIndex
        for (index, text) in allStaticTexts.enumerated() {
            print("DEBUG: StaticText[\(index)]: '\(text.label)'")
        }
        // Wait for and tap I Missed It
        let missedButton = app.buttons["I Missed It"]
        XCTAssertTrue(missedButton.waitForExistence(timeout: 5), "I Missed It button should exist")
        missedButton.tap()
        app.checkOnScreen(identifier: "DailyChecklistScreen", message: "Should return to checklist screen")
        // Print all buttons and static texts after reset
        print("DEBUG: All buttons after 'I Missed It' reset:")
        let allButtons2 = app.buttons.allElementsBoundByIndex
        for (index, button) in allButtons2.enumerated() {
            print("DEBUG: Button[\(index)]: label='\(button.label)', identifier='\(button.identifier)'")
        }
        print("DEBUG: All static text after 'I Missed It' reset:")
        let allStaticTexts2 = app.staticTexts.allElementsBoundByIndex
        for (index, text) in allStaticTexts2.enumerated() {
            print("DEBUG: StaticText[\(index)]: '\(text.label)'")
        }
        // Print accessibility hierarchy and all switches after reset
        print("DEBUG: Accessibility hierarchy after reset:")
        print(app.debugDescription)
        print("DEBUG: All switches after reset:")
        let allSwitchesAfter = app.switches.allElementsBoundByIndex
        for (index, sw) in allSwitchesAfter.enumerated() {
            print("DEBUG: Switch[\(index)]: label='\(sw.label)', value='\(sw.value ?? "nil")'")
        }
        // If SettingsButton is not found but Back is, tap Back
        let settingsButton = app.buttons["SettingsButton"]
        let backButton = app.buttons["Back"]
        if !settingsButton.exists && backButton.exists {
            print("DEBUG: SettingsButton not found, tapping Back to return to checklist")
            backButton.tap()
        }
        // Re-enable debug labels after reset
        enableDebugModeByTappingAllSwitches(in: app)
        // Check for DAY 1 or any day number
        let dayLabel = app.staticTexts["DAY 1"]
        if !dayLabel.exists {
            // Try to find any day label
            let anyDayLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'DAY'"))
            if anyDayLabel.count > 0 {
                print("DEBUG: Found day label: '\(anyDayLabel.element(boundBy: 0).label)'")
                XCTAssertTrue(anyDayLabel.element(boundBy: 0).label.contains("DAY 1"), "Should be on Day 1 after reset, but found: \(anyDayLabel.element(boundBy: 0).label)")
            } else {
                XCTFail("No day label found after reset")
            }
        } else {
            XCTAssertTrue(dayLabel.exists, "Should be on Day 1 after reset")
        }
        let completedTasks = app.buttons.matching(identifier: "checkmark")
        XCTAssertEqual(completedTasks.count, 0, "No tasks should be completed after reset")
    }

    func testMissedDayScreen_ContinueAnyway_AdvancesToNextDay() {
        let app = launchAppWithReset()
        setupMissedDayScenario(app: app)
        app.buttons["Continue Anyway"].tap()
        app.checkOnScreen(identifier: "DailyChecklistScreen", message: "Should return to checklist screen")
        let dayLabel = app.staticTexts["DAY 2"]
        XCTAssertTrue(dayLabel.exists, "Should be on Day 2 after continuing")
        let completedTasks = app.buttons.matching(identifier: "checkmark")
        XCTAssertEqual(completedTasks.count, 0, "No tasks should be completed on new day")
    }
}

extension XCUIApplication {
    func checkOnScreen(identifier: String, timeout: TimeInterval = 2, message: String? = nil) {
        let element = self.descendants(matching: .any)[identifier]
        let msg = message ?? "Should be on screen with identifier \(identifier)"
        guard element.waitForExistence(timeout: timeout) else {
            XCTFail(msg)
            // Immediately stop further test execution
            fatalError(msg)
        }
    }
    
    func addTask(title: String, description: String) {
        checkOnScreen(identifier: "ProgramSetupScreen", message: "Should be on Program Setup screen before adding a task")
        let titleField = self.textFields["Task Title"]
        XCTAssertTrue(titleField.exists)
        titleField.tap()
        titleField.typeText(title)
        let descriptionField = self.textFields["Task Description"]
        XCTAssertTrue(descriptionField.exists)
        descriptionField.tap()
        descriptionField.typeText(description)
        let addButton = self.buttons["Add Task"]
        XCTAssertTrue(addButton.exists)
        addButton.tap()
    }
    
    func saveProgram() {
        checkOnScreen(identifier: "ProgramSetupScreen", message: "Should be on Program Setup screen before saving program")
        let saveButton = self.buttons["Save Program"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()
        // Wait for the checklist screen to appear
        checkOnScreen(identifier: "DailyChecklistScreen", message: "Should navigate to checklist after saving program")
    }
    
    func addProgramAndNavigateToChecklist(taskTitle: String = "Read", taskDescription: String = "Read 10 pages") {
        addTask(title: taskTitle, description: taskDescription)
        saveProgram()
        checkOnScreen(identifier: "DailyChecklistScreen", timeout: 5, message: "Should be on Daily Checklist screen after saving program")
    }
} 
