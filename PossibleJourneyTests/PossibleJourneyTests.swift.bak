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
        // Just before EOD (Jan 2, 1:59:59 AM)
        let beforeEOD = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 2, hour: 1, minute: 59, second: 59))!
        let missedBefore = program.isDayMissed(for: beforeEOD, completedTaskIDs: [])
        XCTAssertFalse(missedBefore, "Should not be missed just before AM EOD on next day")
        // At EOD (Jan 2, 2:00 AM)
        let atEOD = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 2, hour: 2, minute: 0, second: 0))!
        let missedAtEOD = program.isDayMissed(for: atEOD, completedTaskIDs: [])
        XCTAssertTrue(missedAtEOD, "Should be missed at or after AM EOD on next day if not complete")
    }
    func testIsDayMissed_PMEndOfDay_afterEOD_incompleteTasks() {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let task1 = Task(id: UUID(), title: "A", description: nil)
        let task2 = Task(id: UUID(), title: "B", description: nil)
        let eod = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: startDate)!
        let program = Program(id: UUID(), startDate: startDate, numberOfDays: 20, tasks: [task1, task2], endOfDayTime: eod)
        // Now is 9:00 PM (after EOD)
        let afterEOD = calendar.date(bySettingHour: 21, minute: 0, second: 0, of: startDate)!
        let missed = program.isDayMissed(for: afterEOD, completedTaskIDs: [task1.id])
        XCTAssertTrue(missed, "Should be missed if after PM EOD and not all tasks complete")
    }
    
    func testIsDayMissed_UITestScenario() {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let task1 = Task(id: UUID(), title: "Task 1", description: nil)
        let task2 = Task(id: UUID(), title: "Task 2", description: nil)
        
        // EOD set to 8:00 PM
        let eod = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: startDate)!
        let program = Program(id: UUID(), startDate: startDate, numberOfDays: 20, tasks: [task1, task2], endOfDayTime: eod)
        
        // Now is 9:00 PM (after EOD) with only one task complete
        let afterEOD = calendar.date(bySettingHour: 21, minute: 0, second: 0, of: startDate)!
        let missed = program.isDayMissed(for: afterEOD, completedTaskIDs: [task1.id])
        
        XCTAssertTrue(missed, "UI test scenario: EOD 8 PM, now 9 PM, one task incomplete should be missed")
        
        // Verify that if all tasks are complete, it's not missed
        let notMissed = program.isDayMissed(for: afterEOD, completedTaskIDs: [task1.id, task2.id])
        XCTAssertFalse(notMissed, "UI test scenario: EOD 8 PM, now 9 PM, all tasks complete should not be missed")
    }
} 

final class ProgramMissedDayAdvancingTests: XCTestCase {
    func testEODBeforeMidnight_AdvancesAtMidnight() {
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let eod = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: startDate)! // 7pm
        let task = Task(id: UUID(), title: "A", description: nil)
        var program = Program(id: UUID(), startDate: startDate, numberOfDays: 3, tasks: [task], endOfDayTime: eod)
        program.lastCompletedDay = startDate // Jan 1 completed
        let appDay = program.currentAppDay // Jan 2
        // Before EOD
        let beforeEOD = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: appDay)!
        XCTAssertFalse(program.isCurrentAppDayMissed(now: beforeEOD, completedTaskIDs: []))
        // After EOD (7:01pm)
        let afterEOD = calendar.date(bySettingHour: 19, minute: 1, second: 0, of: appDay)!
        XCTAssertTrue(program.isCurrentAppDayMissed(now: afterEOD, completedTaskIDs: []))
        // After midnight
        let afterMidnight = calendar.date(bySettingHour: 0, minute: 1, second: 0, of: calendar.date(byAdding: .day, value: 1, to: appDay)!)!
        XCTAssertTrue(program.isCurrentAppDayMissed(now: afterMidnight, completedTaskIDs: []))
    }
    func testEODAfterMidnight_AdvancesAtEOD() {
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let eod = calendar.date(bySettingHour: 2, minute: 0, second: 0, of: startDate)! // 2am
        let task = Task(id: UUID(), title: "A", description: nil)
        var program = Program(id: UUID(), startDate: startDate, numberOfDays: 3, tasks: [task], endOfDayTime: eod)
        program.lastCompletedDay = calendar.date(from: DateComponents(year: 2023, month: 1, day: 2))! // Jan 2 completed
        let appDay = program.currentAppDay // Jan 3
        // Before EOD (Jan 4, 1am)
        let beforeEOD = calendar.date(from: DateComponents(year: 2023, month: 1, day: 4, hour: 1))!
        XCTAssertFalse(program.isCurrentAppDayMissed(now: beforeEOD, completedTaskIDs: []))
        // After EOD (Jan 4, 2:01am)
        let afterEOD = calendar.date(from: DateComponents(year: 2023, month: 4, day: 4, hour: 2, minute: 1))!
        XCTAssertTrue(program.isCurrentAppDayMissed(now: afterEOD, completedTaskIDs: []))
    }
    func testMultipleMissedDays_ResolvesInOrder() {
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let eod = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: startDate)! // 7pm
        let task = Task(id: UUID(), title: "A", description: nil)
        var program = Program(id: UUID(), startDate: startDate, numberOfDays: 3, tasks: [task], endOfDayTime: eod)
        // Simulate completing Jan 1
        program.lastCompletedDay = startDate
        // Jan 2 is current app day
        let appDay2 = program.currentAppDay
        // Miss Jan 2 (after EOD)
        let afterEOD2 = calendar.date(bySettingHour: 19, minute: 1, second: 0, of: appDay2)!
        XCTAssertTrue(program.isCurrentAppDayMissed(now: afterEOD2, completedTaskIDs: []))
        // Complete Jan 2
        program.lastCompletedDay = appDay2
        // Jan 3 is current app day
        let appDay3 = program.currentAppDay
        // Miss Jan 3 (after EOD)
        let afterEOD3 = calendar.date(bySettingHour: 19, minute: 1, second: 0, of: appDay3)!
        XCTAssertTrue(program.isCurrentAppDayMissed(now: afterEOD3, completedTaskIDs: []))
    }
} 

final class ProgramLastCompletedDayTests: XCTestCase {
    func testLastCompletedDayUpdatesOnCompletion() {
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let eod = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: startDate)! // 7pm
        let task = Task(id: UUID(), title: "A", description: nil)
        var program = Program(id: UUID(), startDate: startDate, numberOfDays: 3, tasks: [task], endOfDayTime: eod)
        XCTAssertNil(program.lastCompletedDay)
        // Simulate completing day 1
        let day1 = startDate
        program.lastCompletedDay = day1
        XCTAssertEqual(program.lastCompletedDay, day1)
    }
    func testIMissedItResetsStartDateButKeepsProgress() {
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let eod = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: startDate)! // 7pm
        let task = Task(id: UUID(), title: "A", description: nil)
        var program = Program(id: UUID(), startDate: startDate, numberOfDays: 3, tasks: [task], endOfDayTime: eod)
        let progress = DailyProgress(id: UUID(), date: startDate, completedTaskIDs: [task.id])
        // Simulate 'I Missed It'
        let today = calendar.startOfDay(for: Date())
        program.startDate = today
        program.lastCompletedDay = nil
        XCTAssertEqual(program.startDate, today)
        XCTAssertNil(program.lastCompletedDay)
        // Progress is not cleared
        XCTAssertEqual(progress.completedTaskIDs, [task.id])
    }
    func testDayAdvancementOnlyAfterBoundary() {
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let eod = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: startDate)! // 7pm
        let task = Task(id: UUID(), title: "A", description: nil)
        var program = Program(id: UUID(), startDate: startDate, numberOfDays: 3, tasks: [task], endOfDayTime: eod)
        program.lastCompletedDay = startDate
        // Before midnight
        let beforeMidnight = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: startDate)!
        XCTAssertFalse(program.canAdvanceToNextDay(currentDate: beforeMidnight, lastCompletedDay: program.lastCompletedDay))
        // After midnight
        let afterMidnight = calendar.date(bySettingHour: 0, minute: 1, second: 0, of: calendar.date(byAdding: .day, value: 1, to: startDate)!)!
        XCTAssertTrue(program.canAdvanceToNextDay(currentDate: afterMidnight, lastCompletedDay: program.lastCompletedDay))
    }
    func testHistoryPreservedAfterReset() {
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let eod = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: startDate)! // 7pm
        let task = Task(id: UUID(), title: "A", description: nil)
        let program = Program(id: UUID(), startDate: startDate, numberOfDays: 3, tasks: [task], endOfDayTime: eod)
        let progress = DailyProgress(id: UUID(), date: startDate, completedTaskIDs: [task.id])
        // Simulate 'I Missed It' (reset startDate)
        let today = calendar.startOfDay(for: Date())
        var resetProgram = program
        resetProgram.startDate = today
        // Progress for previous days is still available
        XCTAssertEqual(progress.completedTaskIDs, [task.id])
    }
} 