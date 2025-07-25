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
        // Enable debug mode
        let debugToggle = app.switches["Show Debug Labels"]
        XCTAssertTrue(debugToggle.waitForExistence(timeout: 2))
        if debugToggle.value as? String == "0" {
            debugToggle.tap()
        }
        let endOfDayPicker = app.datePickers["EndOfDayTimePicker"]
        XCTAssertTrue(endOfDayPicker.exists)
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
        let missedDayScreen = app.otherElements["MissedDayScreen"]
        XCTAssertTrue(missedDayScreen.waitForExistence(timeout: 5), "Missed day screen should appear after end of day if tasks are incomplete")
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
