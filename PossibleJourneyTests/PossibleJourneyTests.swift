import XCTest
@testable import PossibleJourney

final class TaskModelTests: XCTestCase {
    func testTaskInitialization() {
        let id = UUID()
        let task = Task(id: id, title: "Exercise", description: nil)
        XCTAssertEqual(task.id, id)
        XCTAssertEqual(task.title, "Exercise")
    }
}

final class ProgramModelTests: XCTestCase {
    func testProgramInitialization() {
        let tasks = [
            Task(id: UUID(), title: "Read 10 pages", description: "Read from any book"),
            Task(id: UUID(), title: "Drink Water", description: "Drink 2L of water")
        ]
        let program = Program(id: UUID(), startDate: Date(), numberOfDays: 75, tasks: tasks)
        XCTAssertEqual(program.tasks.count, 2)
        XCTAssertEqual(program.numberOfDays, 75)
    }
}

final class DailyProgressModelTests: XCTestCase {
    func testDailyProgressInitialization() {
        let taskId = UUID()
        let progress = DailyProgress(id: UUID(), date: Date(), completedTaskIDs: [taskId])
        XCTAssertEqual(progress.completedTaskIDs, [taskId])
    }
}

final class ProgramSetupViewModelTests: XCTestCase {
    func testInitialState() {
        let viewModel = ProgramSetupViewModel()
        XCTAssertEqual(viewModel.numberOfDays, 75)
        XCTAssertTrue(viewModel.tasks.isEmpty)
    }

    func testAddTask() {
        let viewModel = ProgramSetupViewModel()
        viewModel.addTask(title: "Read", description: "Read 10 pages")
        XCTAssertEqual(viewModel.tasks.count, 1)
        XCTAssertEqual(viewModel.tasks.first?.title, "Read")
        XCTAssertEqual(viewModel.tasks.first?.description, "Read 10 pages")
    }
}

final class ProgramSetupViewModelValidationTests: XCTestCase {
    func testTaskNameTooShort() {
        let viewModel = ProgramSetupViewModel()
        XCTAssertFalse(viewModel.isTaskNameValid("A"))
    }
    func testTaskNameTooLong() {
        let viewModel = ProgramSetupViewModel()
        let longName = String(repeating: "A", count: 51)
        XCTAssertFalse(viewModel.isTaskNameValid(longName))
    }
    func testTaskNameValidLength() {
        let viewModel = ProgramSetupViewModel()
        XCTAssertTrue(viewModel.isTaskNameValid("Read"))
    }
    func testDescriptionTooLong() {
        let viewModel = ProgramSetupViewModel()
        let longDesc = String(repeating: "B", count: 101)
        XCTAssertFalse(viewModel.isDescriptionValid(longDesc))
    }
    func testDescriptionValidLength() {
        let viewModel = ProgramSetupViewModel()
        XCTAssertTrue(viewModel.isDescriptionValid("Read 10 pages"))
    }
}

final class ProgramSetupViewModelSaveTests: XCTestCase {
    func testSaveProgramReturnsProgram() {
        let viewModel = ProgramSetupViewModel()
        viewModel.numberOfDays = 30
        let taskId = UUID()
        let task = Task(id: taskId, title: "Test Task", description: "Test Desc")
        viewModel.tasks = [task]
        let before = Date()
        let program = viewModel.saveProgram()
        let after = Date()
        XCTAssertNotNil(program)
        XCTAssertEqual(program?.numberOfDays, 30)
        XCTAssertEqual(program?.tasks.count, 1)
        XCTAssertEqual(program?.tasks.first?.id, taskId)
        XCTAssertEqual(program?.tasks.first?.title, "Test Task")
        XCTAssertEqual(program?.tasks.first?.description, "Test Desc")
        XCTAssertNotNil(program?.id)
        // Check that startDate is close to now
        if let startDate = program?.startDate {
            XCTAssertGreaterThanOrEqual(startDate, before)
            XCTAssertLessThanOrEqual(startDate, after)
        } else {
            XCTFail("startDate should not be nil")
        }
    }

    func testSaveProgramReturnsNilWhenNoTasks() {
        let viewModel = ProgramSetupViewModel()
        viewModel.numberOfDays = 30
        viewModel.tasks = []
        let program = viewModel.saveProgram()
        XCTAssertNil(program)
    }
}

final class ProgramStorageTests: XCTestCase {
    func testSaveAndLoadProgram() {
        let storage = ProgramStorage()
        storage.clear() // Ensure clean state
        let program = Program(
            id: UUID(),
            startDate: Date(),
            numberOfDays: 75,
            tasks: [Task(id: UUID(), title: "Test Task", description: "Test Desc")]
        )
        storage.save(program)
        let loaded = storage.load()
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.numberOfDays, 75)
        XCTAssertEqual(loaded?.tasks.count, 1)
        XCTAssertEqual(loaded?.tasks.first?.title, "Test Task")
        XCTAssertEqual(loaded?.tasks.first?.description, "Test Desc")
    }
}

final class DailyProgressStorageTests: XCTestCase {
    func testSaveAndLoadDailyProgress() {
        let storage = DailyProgressStorage()
        let today = Calendar.current.startOfDay(for: Date())
        let taskID = UUID()
        let progress = DailyProgress(id: UUID(), date: today, completedTaskIDs: [taskID])
        storage.save(progress: progress)
        let loaded = storage.load(for: today)
        XCTAssertNotNil(loaded, "Should load saved progress for today")
        XCTAssertEqual(loaded?.completedTaskIDs, [taskID], "Loaded completedTaskIDs should match saved")
    }
}

func testProgramStorageSaveAndLoad() throws {
    let storage = ProgramStorage()
    let program = Program(
        id: UUID(),
        startDate: Date(),
        numberOfDays: 75,
        tasks: [Task(id: UUID(), title: "Test Task", description: "Test Desc")]
    )
    storage.save(program)
    let loaded = storage.load()
    XCTAssertNotNil(loaded, "Should load a saved program")
    XCTAssertEqual(loaded?.numberOfDays, 75)
    XCTAssertEqual(loaded?.tasks.first?.title, "Test Task")
} 