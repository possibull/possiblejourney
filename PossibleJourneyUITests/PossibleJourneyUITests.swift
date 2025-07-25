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

    func testSaveProgramButtonExistsAndCanBeTapped() throws {
        let app = launchAppWithReset()
        app.addTask(title: "Read", description: "Read 10 pages")
        app.saveProgram()
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
        app.addProgramAndNavigateToChecklist()
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
        // Add two tasks and save program
        app.addTask(title: "Read", description: "Read 10 pages")
        app.addTask(title: "Drink Water", description: "Drink 2L of water")
        app.saveProgram()
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
        // Complete program setup to reach Daily Checklist screen
        app.addTask(title: "Read", description: "Read 10 pages")
        app.addTask(title: "Drink Water", description: "Drink 2L of water")
        app.saveProgram()
        // Set end of day time to just before now (simulate after end of day)
        print("DEBUG: Button identifiers: \(app.buttons.allElementsBoundByIndex.map { $0.identifier })")
        let settingsButton = app.buttons["SettingsButton"]
        XCTAssertTrue(settingsButton.exists)
        settingsButton.tap()
        // Wait for the Settings page to be visible
        let endOfDayPicker = app.datePickers["EndOfDayTimePicker"]
        XCTAssertTrue(endOfDayPicker.waitForExistence(timeout: 2))
        // Print all switches for diagnosis
        print("Switches: \(app.switches.allElementsBoundByIndex.map { $0.label })")
        print("Switch count: \(app.switches.count)")
        for i in 0..<app.switches.count {
            let sw = app.switches.element(boundBy: i)
            print("Switch \(i): label=\(sw.label), value=\(sw.value ?? "nil")")
            if sw.label == "Show Debug Labels" && sw.value as? String == "0" {
                sw.tap()
            }
        }
        // Print all toggles (switches) for diagnosis and tap each
        print("Toggles: \(app.switches.allElementsBoundByIndex.map { $0.label })")
        print("Toggle count: \(app.switches.count)")
        for i in 0..<app.switches.count {
            let toggle = app.switches.element(boundBy: i)
            print("Toggle \(i): label=\(toggle.label), identifier=\(toggle.identifier), value=\(toggle.value ?? "nil"), isHittable=\(toggle.isHittable)")
            if toggle.isHittable {
                toggle.tap()
            }
        }
        // Robustly scroll to and tap the debug toggle
        let debugToggle = app.switches["Show Debug Labels"]
        var attempts = 0
        while !debugToggle.exists && attempts < 5 {
            app.swipeUp()
            attempts += 1
        }
        XCTAssertTrue(debugToggle.waitForExistence(timeout: 2), "Debug toggle should exist")
        print("Debug toggle value before tap: \(debugToggle.value ?? "nil")")
        if debugToggle.exists && debugToggle.isHittable && debugToggle.value as? String == "0" {
            debugToggle.tap()
            sleep(1)
            // Tap again in case first tap just scrolls into view
            if debugToggle.value as? String == "0" {
                debugToggle.tap()
            }
        } else if debugToggle.exists {
            // Try coordinate tap if not hittable
            let coord = debugToggle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            coord.tap()
            sleep(1)
            if debugToggle.value as? String == "0" {
                coord.tap()
            }
        }
        print("Debug toggle value after tap: \(debugToggle.value ?? "nil")")
        // Set the picker to a fixed time: 8:00 PM
        let calendar = Calendar.current
        let eodHour = 20 // 8:00 PM
        let eodMinute = 0
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        // Adjust the picker wheels to set EOD to 8:00 PM
        let hourWheel = endOfDayPicker.pickerWheels.element(boundBy: 0)
        let minuteWheel = endOfDayPicker.pickerWheels.element(boundBy: 1)
        let amPmWheel = endOfDayPicker.pickerWheels.element(boundBy: 2)
        hourWheel.adjust(toPickerWheelValue: "8")
        minuteWheel.adjust(toPickerWheelValue: "00")
        amPmWheel.adjust(toPickerWheelValue: "PM")
        // Set fake 'now' to 9:00 PM (1 hour after EOD)
        let fakeNow = calendar.date(from: DateComponents(year: components.year, month: components.month, day: components.day, hour: 21, minute: 0))!
        let fakeNowTimestamp = Int(fakeNow.timeIntervalSince1970)
        app.buttons["Back"].tap()
        // Do NOT complete all tasks
        // Relaunch checklist (simulate app open after end of day)
        app.terminate()
        app.launchArguments = ["--uitesting-current-time", String(fakeNowTimestamp)]
        app.launch()
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

    func enableDebugLabels(in app: XCUIApplication) {
        let settingsButton = app.buttons["SettingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 2))
        settingsButton.tap()
        let debugToggle = app.switches["Show Debug Labels"]
        var attempts = 0
        while !debugToggle.exists && attempts < 5 {
            app.swipeUp()
            attempts += 1
        }
        XCTAssertTrue(debugToggle.waitForExistence(timeout: 2), "Debug toggle should exist")
        if debugToggle.value as? String == "0" {
            debugToggle.tap()
        }
        // Go back if needed
        let backButton = app.buttons["Back"]
        if backButton.exists { backButton.tap() }
    }

    func setupMissedDayScenario(app: XCUIApplication, eodHour: String = "8", missedTime: String = "2025-07-24T21:00:00Z") {
        app.checkOnScreen(identifier: "ProgramSetupScreen", message: "Should start on Program Setup screen")
        app.addTask(title: "Task 1", description: "Description 1")
        app.addTask(title: "Task 2", description: "Description 2")
        app.saveProgram()
        app.checkOnScreen(identifier: "DailyChecklistScreen", message: "Should navigate to checklist after saving program")
        enableDebugLabels(in: app)
        // Navigate to Settings and set EOD
        let settingsButton = app.buttons["SettingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 2))
        settingsButton.tap()
        let endOfDayPicker = app.datePickers["EndOfDayTimePicker"]
        XCTAssertTrue(endOfDayPicker.waitForExistence(timeout: 2), "End of Day Time picker should exist")
        let hourPicker = endOfDayPicker.pickerWheels.element(boundBy: 0)
        let minutePicker = endOfDayPicker.pickerWheels.element(boundBy: 1)
        hourPicker.adjust(toPickerWheelValue: eodHour)
        minutePicker.adjust(toPickerWheelValue: "00")
        app.buttons["Back"].tap()
        app.terminate()
        app.launchArguments = ["--uitesting", "--currentTimeOverride", missedTime]
        app.launch()
        enableDebugLabels(in: app)
        app.checkOnScreen(identifier: "MissedDayScreen", timeout: 10, message: "Missed day screen should appear")
    }

    func testMissedDayScreen_IMissedIt_ResetsToDay1() {
        let app = launchAppWithReset()
        setupMissedDayScenario(app: app)
        app.buttons["I Missed It"].tap()
        app.checkOnScreen(identifier: "DailyChecklistScreen", message: "Should return to checklist screen")
        let dayLabel = app.staticTexts["DAY 1"]
        XCTAssertTrue(dayLabel.exists, "Should be on Day 1 after reset")
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
