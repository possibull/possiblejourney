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
        app.checkOnScreen(identifier: "DailyChecklistScreen", timeout: 5, message: "Should be on Daily Checklist screen after relaunch")
    }

    func testChecklistTaskCompletionPersistsAfterRelaunch() throws {
        let app = launchAppWithReset()
        // Add two tasks and save program
        app.addTask(title: "Read", description: "Read 10 pages")
        app.addTask(title: "Drink Water", description: "Drink 2L of water")
        app.saveProgram()
        // Mark the first task as complete
        let firstTask = app.staticTexts["Read"]
        XCTAssertTrue(firstTask.exists)
        // Tap the checkmark button (assume it's the first button in the cell)
        let firstTaskCell = firstTask.coordinate(withNormalizedOffset: CGVector(dx: -0.2, dy: 0.5))
        firstTaskCell.tap()
        // Relaunch app (no reset)
        app.terminate()
        app.launchArguments = []
        app.launch()
        app.checkOnScreen(identifier: "DailyChecklistScreen", timeout: 5, message: "Should be on Daily Checklist screen after relaunch")
        // Verify the first task is still marked as complete (checkmark exists)
        let checkmark = app.images["checkmark"]
        XCTAssertTrue(checkmark.exists, "First task should be checked after relaunch")
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
        if !element.waitForExistence(timeout: timeout) {
            XCTFail(msg)
            return
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
