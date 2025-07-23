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

        // Enter task title
        let titleField = app.textFields["Task Title"]
        XCTAssertTrue(titleField.exists)
        titleField.tap()
        titleField.typeText("Read")

        // Enter task description
        let descriptionField = app.textFields["Task Description"]
        XCTAssertTrue(descriptionField.exists)
        descriptionField.tap()
        descriptionField.typeText("Read 10 pages")

        // Tap Add Task button
        let addButton = app.buttons["Add Task"]
        XCTAssertTrue(addButton.exists)
        addButton.tap()

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
        // Enter program details (number of days and start date are defaulted)
        let titleField = app.textFields["Task Title"]
        XCTAssertTrue(titleField.exists)
        titleField.tap()
        titleField.typeText("Read")
        let descriptionField = app.textFields["Task Description"]
        XCTAssertTrue(descriptionField.exists)
        descriptionField.tap()
        descriptionField.typeText("Read 10 pages")
        let addButton = app.buttons["Add Task"]
        XCTAssertTrue(addButton.exists)
        addButton.tap()
        // Tap Save Program
        let saveButton = app.buttons["Save Program"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()
        // Assert that the daily checklist view appears (look for the header)
        let checklistScreen = app.otherElements["DailyChecklistScreen"]
        print(app.debugDescription)
        XCTAssertTrue(checklistScreen.waitForExistence(timeout: 5))
    }

    func testProgramPersistsAndChecklistAppearsOnRelaunch() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--uitesting-reset")
        app.launch()
        print(app.debugDescription)
        // First launch: create and save a program
        let titleField = app.textFields["Task Title"]
        XCTAssertTrue(titleField.exists)
        titleField.tap()
        titleField.typeText("Read")
        let descriptionField = app.textFields["Task Description"]
        XCTAssertTrue(descriptionField.exists)
        descriptionField.tap()
        descriptionField.typeText("Read 10 pages")
        let addButton = app.buttons["Add Task"]
        XCTAssertTrue(addButton.exists)
        addButton.tap()
        let saveButton = app.buttons["Save Program"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()
        let checklistScreen = app.otherElements["DailyChecklistScreen"]
        XCTAssertTrue(checklistScreen.waitForExistence(timeout: 5))
        // Relaunch: check for checklist or setup screen using accessibility identifiers
        app.terminate()
        app.launch()
        print(app.debugDescription)
        let checklistScreen2 = app.otherElements["DailyChecklistScreen"]
        let setupScreen = app.otherElements["ProgramSetupScreen"]
        if checklistScreen2.waitForExistence(timeout: 5) {
            print("Checklist screen is visible after relaunch.")
            XCTAssertTrue(true)
        } else if setupScreen.waitForExistence(timeout: 1) {
            print("Setup screen is visible after relaunch, expected checklist.")
            XCTFail("Setup screen is visible after relaunch, expected checklist")
        } else {
            print("Neither checklist nor setup screen is visible after relaunch.")
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
