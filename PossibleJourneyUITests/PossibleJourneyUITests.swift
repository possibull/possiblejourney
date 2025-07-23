import XCTest

final class PossibleJourneyUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Clear persistence before each test
        UserDefaults.standard.removeObject(forKey: "savedProgram")
    }

    func testAddTaskFlow() throws {
        let app = XCUIApplication()
        app.launch()
        app.addTask(title: "Read", description: "Read 10 pages")
        // Verify the task appears in the list
        let taskCell = app.staticTexts["Read"]
        XCTAssertTrue(taskCell.waitForExistence(timeout: 1))
    }

    func testSaveProgramButtonExistsAndCanBeTapped() throws {
        let app = XCUIApplication()
        app.launch()
        let saveButton = app.buttons["Save Program"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()
        // No confirmation required yet
    }

    func testSaveProgramButtonDisabledWhenNoTasks() throws {
        let app = XCUIApplication()
        app.launch()
        let saveButton = app.buttons["Save Program"]
        XCTAssertTrue(saveButton.exists)
        XCTAssertFalse(saveButton.isEnabled)
    }

    func testSaveProgramNavigatesToDailyChecklist() throws {
        let app = XCUIApplication()
        app.launch()
        app.addProgramAndNavigateToChecklist()
    }

    func testProgramPersistsAndChecklistAppearsOnRelaunch() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--uitesting-reset")
        app.launch()
        // Verify we are on the Program Setup screen before adding a program
        let setupScreen = app.otherElements["ProgramSetupScreen"]
        XCTAssertTrue(setupScreen.waitForExistence(timeout: 2), "Should start on Program Setup screen")
        // First launch: create and save a program, navigate to checklist
        app.addProgramAndNavigateToChecklist()
        // Relaunch: check for checklist or setup screen using accessibility identifiers
        app.terminate()
        app.launch()
        let checklistScreen2 = app.otherElements["DailyChecklistScreen"]
        let setupScreen2 = app.otherElements["ProgramSetupScreen"]
        if checklistScreen2.waitForExistence(timeout: 5) {
            XCTAssertTrue(true)
        } else if setupScreen2.waitForExistence(timeout: 1) {
            XCTFail("Setup screen is visible after relaunch, expected checklist")
        } else {
            XCTFail("Neither checklist nor setup screen is visible after relaunch")
        }
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
    func addTask(title: String, description: String) {
        let setupScreen = self.otherElements["ProgramSetupScreen"]
        XCTAssertTrue(setupScreen.waitForExistence(timeout: 2), "Should be on Program Setup screen before adding a task")
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
        let setupScreen = self.otherElements["ProgramSetupScreen"]
        XCTAssertTrue(setupScreen.waitForExistence(timeout: 2), "Should be on Program Setup screen before saving program")
        let saveButton = self.buttons["Save Program"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()
    }
    
    func addProgramAndNavigateToChecklist(taskTitle: String = "Read", taskDescription: String = "Read 10 pages") {
        addTask(title: taskTitle, description: taskDescription)
        saveProgram()
        let checklistScreen = self.otherElements["DailyChecklistScreen"]
        XCTAssertTrue(checklistScreen.waitForExistence(timeout: 5), "Should be on Daily Checklist screen after saving program")
    }
} 
