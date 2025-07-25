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
        // Print task IDs before relaunch
        print("DEBUG: Task IDs before relaunch:")
        let taskCells = app.staticTexts.allElementsBoundByIndex
        for cell in taskCells {
            print("DEBUG: Task cell label: \(cell.label)")
        }
        // Print debug task IDs before relaunch
        let debugTaskIDsBefore = app.staticTexts["TaskIDsDebug"].label
        print("DEBUG: TaskIDsDebug before relaunch: \(debugTaskIDsBefore)")
        // Print debug completed task IDs before relaunch
        let debugCompletedTaskIDsBefore = app.staticTexts["CompletedTaskIDsDebug"].label
        print("DEBUG: CompletedTaskIDsDebug before relaunch: \(debugCompletedTaskIDsBefore)")
        // Get the Read task's ID (assume it's the first in the list)
        let readTaskID = debugTaskIDsBefore.components(separatedBy: ",").first!
        // Mark the first task as complete
        let firstTask = app.staticTexts["Read"]
        XCTAssertTrue(firstTask.exists)
        let firstTaskCell = firstTask.coordinate(withNormalizedOffset: CGVector(dx: -0.2, dy: 0.5))
        firstTaskCell.tap()
        // Relaunch app (no reset)
        app.terminate()
        app.launchArguments = []
        app.launch()
        enableDebugModeByTappingAllSwitches(in: app)
        // Tap Back button to return to checklist
        let backButton = app.buttons["Back"]
        if backButton.exists {
            backButton.tap()
        }
        app.checkOnScreen(identifier: "DailyChecklistScreen", timeout: 5, message: "Should be on Daily Checklist screen after relaunch")
        // Print task IDs after relaunch
        print("DEBUG: Task IDs after relaunch:")
        let taskCellsAfter = app.staticTexts.allElementsBoundByIndex
        for cell in taskCellsAfter {
            print("DEBUG: Task cell label: \(cell.label)")
        }
        // Print debug task IDs after relaunch
        let debugTaskIDsAfter = app.staticTexts["TaskIDsDebug"].label
        print("DEBUG: TaskIDsDebug after relaunch: \(debugTaskIDsAfter)")
        // Print debug completed task IDs after relaunch
        let debugCompletedTaskIDsAfter = app.staticTexts["CompletedTaskIDsDebug"].label
        print("DEBUG: CompletedTaskIDsDebug after relaunch: \(debugCompletedTaskIDsAfter)")
        // Assert that the Read task's ID is present in the completed IDs after relaunch
        let completedTaskIDsAfter = debugCompletedTaskIDsAfter.components(separatedBy: ",")
        XCTAssertTrue(completedTaskIDsAfter.contains(readTaskID), "Read task should be marked as complete after relaunch")
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
        if !foundMissedDayLabel {
            print(app.debugDescription)
        }
        XCTAssertTrue(foundMissedDayLabel, "Missed day screen should appear after end of day if tasks are incomplete")
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
        // Removed: Go back to checklist
        // let backButton = app.buttons["Back"]
        // if backButton.exists { backButton.tap() }
    }

    func testSettingsDebugToggleAndEODPicker() {
        let app = launchAppWithReset()
        setupProgram(app: app)
        enableDebugModeByTappingAllSwitches(in: app)
        // Set EOD picker to 8:00 PM
        let settingsButton = app.buttons["SettingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 2))
        settingsButton.tap()
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
