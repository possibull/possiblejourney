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

final class ProgramModelDayLogicTests: XCTestCase {
    func testAppDayCalculation_beforeStart() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let program = Program(id: UUID(), startDate: startDate, numberOfDays: 20, tasks: [], endOfDayTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: startDate)!)
        let fakeNow = Calendar.current.date(from: DateComponents(year: 2022, month: 12, day: 31, hour: 23))!
        let day = program.appDay(for: fakeNow)
        XCTAssertEqual(day, 0, "Should be day 0 before program starts")
    }
    func testAppDayCalculation_onStart() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let program = Program(id: UUID(), startDate: startDate, numberOfDays: 20, tasks: [], endOfDayTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: startDate)!)
        let fakeNow = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1, hour: 10))!
        let day = program.appDay(for: fakeNow)
        XCTAssertEqual(day, 1, "Should be day 1 on program start date")
    }
    func testAppDayCalculation_laterDay() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let program = Program(id: UUID(), startDate: startDate, numberOfDays: 20, tasks: [], endOfDayTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: startDate)!)
        let fakeNow = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 5, hour: 21))!
        let day = program.appDay(for: fakeNow)
        XCTAssertEqual(day, 5, "Should be day 5 on Jan 5th before EOD")
    }
    func testIsDayMissed_allTasksComplete() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let task1 = Task(id: UUID(), title: "A", description: nil)
        let task2 = Task(id: UUID(), title: "B", description: nil)
        let program = Program(id: UUID(), startDate: startDate, numberOfDays: 20, tasks: [task1, task2], endOfDayTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: startDate)!)
        let fakeNow = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1, hour: 23))!
        let missed = program.isDayMissed(for: fakeNow, completedTaskIDs: [task1.id, task2.id])
        XCTAssertFalse(missed, "Should not be missed if all tasks complete before EOD")
    }
    func testIsDayMissed_oneTaskIncomplete() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let task1 = Task(id: UUID(), title: "A", description: nil)
        let task2 = Task(id: UUID(), title: "B", description: nil)
        let program = Program(id: UUID(), startDate: startDate, numberOfDays: 20, tasks: [task1, task2], endOfDayTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: startDate)!)
        let fakeNow = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1, hour: 23))!
        let missed = program.isDayMissed(for: fakeNow, completedTaskIDs: [task1.id])
        XCTAssertTrue(missed, "Should be missed if one task is incomplete after EOD")
    }
    func testIsDayMissed_twoTasksIncomplete() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let task1 = Task(id: UUID(), title: "A", description: nil)
        let task2 = Task(id: UUID(), title: "B", description: nil)
        let task3 = Task(id: UUID(), title: "C", description: nil)
        let program = Program(id: UUID(), startDate: startDate, numberOfDays: 20, tasks: [task1, task2, task3], endOfDayTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: startDate)!)
        let fakeNow = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1, hour: 23))!
        let missed = program.isDayMissed(for: fakeNow, completedTaskIDs: [task1.id])
        XCTAssertTrue(missed, "Should be missed if two tasks are incomplete after EOD")
    }
    func testIsDayMissed_noTasksMissed() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let task1 = Task(id: UUID(), title: "A", description: nil)
        let task2 = Task(id: UUID(), title: "B", description: nil)
        let program = Program(id: UUID(), startDate: startDate, numberOfDays: 20, tasks: [task1, task2], endOfDayTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: startDate)!)
        let fakeNow = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1, hour: 23))!
        let missed = program.isDayMissed(for: fakeNow, completedTaskIDs: [task1.id, task2.id])
        XCTAssertFalse(missed, "Should not be missed if all tasks are complete after EOD")
    }
    func testIsDayMissed_AMEndOfDay_beforeAndAfter() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let task1 = Task(id: UUID(), title: "A", description: nil)
        let program = Program(id: UUID(), startDate: startDate, numberOfDays: 20, tasks: [task1], endOfDayTime: Calendar.current.date(bySettingHour: 2, minute: 0, second: 0, of: startDate)!)
        // Before EOD (Jan 2, 1:00 AM)
        let beforeEOD = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 2, hour: 1, minute: 0))!
        let missedBefore = program.isDayMissed(for: beforeEOD, completedTaskIDs: [])
        XCTAssertFalse(missedBefore, "Should not be missed before AM EOD on next day")
        // After EOD (Jan 2, 2:00 AM)
        let afterEOD = Calendar.current.date(from: DateComponents(year: 2023, month: 2, day: 2, hour: 2, minute: 0))!
        let missedAfter = program.isDayMissed(for: afterEOD, completedTaskIDs: [])
        XCTAssertTrue(missedAfter, "Should be missed after AM EOD on next day if not complete")
    }
} 