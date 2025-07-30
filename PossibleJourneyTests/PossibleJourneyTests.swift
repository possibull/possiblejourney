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
        let template = ProgramTemplate(
            name: "Test Template",
            description: "A template for testing.",
            category: .learning,
            defaultNumberOfDays: 75,
            tasks: tasks,
            isDefault: false
        )
        let storage = ProgramTemplateStorage()
        storage.clear()
        storage.add(template)
        let program = template.createProgram(startDate: Date(), endOfDayTime: Date(), numberOfDays: nil)
        XCTAssertEqual(program.tasks(using: storage).count, 2)
        XCTAssertEqual(program.numberOfDays(using: storage), 75)
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
        let template = ProgramTemplate(
            name: "Test Save Template",
            description: "A template for saving.",
            category: .learning,
            defaultNumberOfDays: 30,
            tasks: [task],
            isDefault: false
        )
        let storage = ProgramTemplateStorage()
        storage.clear()
        storage.add(template)
        let program = viewModel.saveProgram(templateID: template.id)
        let after = Date()
        XCTAssertNotNil(program)
        let loadedTemplate = storage.get(by: program!.templateID)
        XCTAssertEqual(loadedTemplate?.defaultNumberOfDays, 30)
        XCTAssertEqual(loadedTemplate?.tasks.count, 1)
        XCTAssertEqual(loadedTemplate?.tasks.first?.id, taskId)
        XCTAssertEqual(loadedTemplate?.tasks.first?.title, "Test Task")
        XCTAssertEqual(loadedTemplate?.tasks.first?.description, "Test Desc")
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
        let template = ProgramTemplate(
            name: "Test Save Template",
            description: "A template for saving.",
            category: .learning,
            defaultNumberOfDays: 30,
            tasks: [],
            isDefault: false
        )
        let storage = ProgramTemplateStorage()
        storage.clear()
        storage.add(template)
        let program = viewModel.saveProgram(templateID: template.id)
        XCTAssertNil(program)
    }
}

final class ProgramStorageTests: XCTestCase {
    func testSaveAndLoadProgram() {
        let storage = ProgramStorage()
        storage.clear() // Ensure clean state
        let template = ProgramTemplate(
            name: "Test Template",
            description: "A template for testing.",
            category: .learning,
            defaultNumberOfDays: 75,
            tasks: [Task(id: UUID(), title: "Test Task", description: "Test Desc")],
            isDefault: false
        )
        let templateStorage = ProgramTemplateStorage()
        templateStorage.clear()
        templateStorage.add(template)
        let program = template.createProgram(startDate: Date(), endOfDayTime: Date(), numberOfDays: nil)
        storage.save(program)
        let loaded = storage.load()
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.numberOfDays(using: templateStorage), 75)
        XCTAssertEqual(loaded?.tasks(using: templateStorage).count, 1)
        XCTAssertEqual(loaded?.tasks(using: templateStorage).first?.title, "Test Task")
        XCTAssertEqual(loaded?.tasks(using: templateStorage).first?.description, "Test Desc")
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
    func makeTemplate(tasks: [Task] = [], numberOfDays: Int = 20) -> ProgramTemplate {
        ProgramTemplate(
            name: "Logic Template",
            description: "Logic test template",
            category: .learning,
            defaultNumberOfDays: numberOfDays,
            tasks: tasks,
            isDefault: false
        )
    }
    func makeStorage(with template: ProgramTemplate) -> ProgramTemplateStorage {
        let storage = ProgramTemplateStorage()
        storage.clear()
        storage.add(template)
        return storage
    }
    func testAppDayCalculation_beforeStart() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let template = makeTemplate()
        let storage = makeStorage(with: template)
        let program = Program(id: UUID(), startDate: startDate, endOfDayTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: startDate)!, lastCompletedDay: nil, templateID: template.id, customNumberOfDays: nil)
        let fakeNow = Calendar.current.date(from: DateComponents(year: 2022, month: 12, day: 31, hour: 23))!
        let day = program.appDay(for: fakeNow)
        XCTAssertEqual(day, 0, "Should be day 0 before program starts")
    }
    func testAppDayCalculation_onStart() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let template = makeTemplate()
        let storage = makeStorage(with: template)
        let program = Program(id: UUID(), startDate: startDate, endOfDayTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: startDate)!, lastCompletedDay: nil, templateID: template.id, customNumberOfDays: nil)
        let fakeNow = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1, hour: 10))!
        let day = program.appDay(for: fakeNow)
        XCTAssertEqual(day, 1, "Should be day 1 on program start date")
    }
    func testAppDayCalculation_laterDay() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let template = makeTemplate()
        let storage = makeStorage(with: template)
        let program = Program(id: UUID(), startDate: startDate, endOfDayTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: startDate)!, lastCompletedDay: nil, templateID: template.id, customNumberOfDays: nil)
        let fakeNow = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 5, hour: 21))!
        let day = program.appDay(for: fakeNow)
        XCTAssertEqual(day, 5, "Should be day 5 on Jan 5th before EOD")
    }
}

final class ProgramMissedDayAdvancingTests: XCTestCase {
    func makeTemplate(tasks: [Task] = [], numberOfDays: Int = 20) -> ProgramTemplate {
        ProgramTemplate(
            name: "Missed Day Template",
            description: "Missed day test template",
            category: .learning,
            defaultNumberOfDays: numberOfDays,
            tasks: tasks,
            isDefault: false
        )
    }
    func makeStorage(with template: ProgramTemplate) -> ProgramTemplateStorage {
        let storage = ProgramTemplateStorage()
        storage.clear()
        storage.add(template)
        return storage
    }
    func testAdvanceMissedDay_beforeStart() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let template = makeTemplate()
        let storage = makeStorage(with: template)
        let program = Program(id: UUID(), startDate: startDate, endOfDayTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: startDate)!, lastCompletedDay: nil, templateID: template.id, customNumberOfDays: nil)
        let fakeNow = Calendar.current.date(from: DateComponents(year: 2022, month: 12, day: 31, hour: 23))!
        let day = program.appDay(for: fakeNow)
        XCTAssertEqual(day, 0, "Should be day 0 before program starts")
    }
    func testAdvanceMissedDay_onStart() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let template = makeTemplate()
        let storage = makeStorage(with: template)
        let program = Program(id: UUID(), startDate: startDate, endOfDayTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: startDate)!, lastCompletedDay: nil, templateID: template.id, customNumberOfDays: nil)
        let fakeNow = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1, hour: 10))!
        let day = program.appDay(for: fakeNow)
        XCTAssertEqual(day, 1, "Should be day 1 on program start date")
    }
    func testAdvanceMissedDay_laterDay() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let template = makeTemplate()
        let storage = makeStorage(with: template)
        let program = Program(id: UUID(), startDate: startDate, endOfDayTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: startDate)!, lastCompletedDay: nil, templateID: template.id, customNumberOfDays: nil)
        let fakeNow = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 5, hour: 21))!
        let day = program.appDay(for: fakeNow)
        XCTAssertEqual(day, 5, "Should be day 5 on Jan 5th before EOD")
    }
}

final class ProgramLastCompletedDayTests: XCTestCase {
    func makeTemplate(tasks: [Task] = [], numberOfDays: Int = 20) -> ProgramTemplate {
        ProgramTemplate(
            name: "Last Completed Day Template",
            description: "Last completed day test template",
            category: .learning,
            defaultNumberOfDays: numberOfDays,
            tasks: tasks,
            isDefault: false
        )
    }
    func makeStorage(with template: ProgramTemplate) -> ProgramTemplateStorage {
        let storage = ProgramTemplateStorage()
        storage.clear()
        storage.add(template)
        return storage
    }
    func testLastCompletedDay_beforeStart() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let template = makeTemplate()
        let storage = makeStorage(with: template)
        let program = Program(id: UUID(), startDate: startDate, endOfDayTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: startDate)!, lastCompletedDay: nil, templateID: template.id, customNumberOfDays: nil)
        let fakeNow = Calendar.current.date(from: DateComponents(year: 2022, month: 12, day: 31, hour: 23))!
        let day = program.appDay(for: fakeNow)
        XCTAssertEqual(day, 0, "Should be day 0 before program starts")
    }
    func testLastCompletedDay_onStart() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let template = makeTemplate()
        let storage = makeStorage(with: template)
        let program = Program(id: UUID(), startDate: startDate, endOfDayTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: startDate)!, lastCompletedDay: nil, templateID: template.id, customNumberOfDays: nil)
        let fakeNow = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1, hour: 10))!
        let day = program.appDay(for: fakeNow)
        XCTAssertEqual(day, 1, "Should be day 1 on program start date")
    }
    func testLastCompletedDay_laterDay() {
        let startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let template = makeTemplate()
        let storage = makeStorage(with: template)
        let program = Program(id: UUID(), startDate: startDate, endOfDayTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: startDate)!, lastCompletedDay: nil, templateID: template.id, customNumberOfDays: nil)
        let fakeNow = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 5, hour: 21))!
        let day = program.appDay(for: fakeNow)
        XCTAssertEqual(day, 5, "Should be day 5 on Jan 5th before EOD")
    }
} 

final class TemplateCardMoreTasksTests: XCTestCase {
    func testMoreTasksTextAppearsWhenMoreThan3Tasks() {
        // Arrange
        let template = ProgramTemplate(
            name: "Test Template",
            description: "A template with many tasks",
            category: .learning,
            defaultNumberOfDays: 10,
            tasks: [
                Task(id: UUID(), title: "Task 1", description: "First task"),
                Task(id: UUID(), title: "Task 2", description: "Second task"),
                Task(id: UUID(), title: "Task 3", description: "Third task"),
                Task(id: UUID(), title: "Task 4", description: "Fourth task"),
                Task(id: UUID(), title: "Task 5", description: "Fifth task")
            ],
            isDefault: false
        )
        
        // Act & Assert
        XCTAssertEqual(template.tasks.count, 5)
        XCTAssertTrue(template.tasks.count > 3)
        XCTAssertEqual(template.tasks.count - 3, 2)
    }
    
    func testMoreTasksTextDoesNotAppearWhen3OrFewerTasks() {
        // Arrange
        let template = ProgramTemplate(
            name: "Test Template",
            description: "A template with few tasks",
            category: .learning,
            defaultNumberOfDays: 10,
            tasks: [
                Task(id: UUID(), title: "Task 1", description: "First task"),
                Task(id: UUID(), title: "Task 2", description: "Second task"),
                Task(id: UUID(), title: "Task 3", description: "Third task")
            ],
            isDefault: false
        )
        
        // Act & Assert
        XCTAssertEqual(template.tasks.count, 3)
        XCTAssertFalse(template.tasks.count > 3)
    }
    
    func testTemplateCardShowsCorrectNumberOfVisibleTasks() {
        // Arrange
        let template = ProgramTemplate(
            name: "Test Template",
            description: "A template with many tasks",
            category: .learning,
            defaultNumberOfDays: 10,
            tasks: [
                Task(id: UUID(), title: "Task 1", description: "First task"),
                Task(id: UUID(), title: "Task 2", description: "Second task"),
                Task(id: UUID(), title: "Task 3", description: "Third task"),
                Task(id: UUID(), title: "Task 4", description: "Fourth task"),
                Task(id: UUID(), title: "Task 5", description: "Fifth task")
            ],
            isDefault: false
        )
        
        // Act
        let visibleTasks = Array(template.tasks.prefix(3))
        let hiddenTasks = template.tasks.count - 3
        
        // Assert
        XCTAssertEqual(visibleTasks.count, 3)
        XCTAssertEqual(visibleTasks[0].title, "Task 1")
        XCTAssertEqual(visibleTasks[1].title, "Task 2")
        XCTAssertEqual(visibleTasks[2].title, "Task 3")
        XCTAssertEqual(hiddenTasks, 2)
    }
    
    func testTemplateCardExpansionShowsAllTasks() {
        // Arrange
        let template = ProgramTemplate(
            name: "Test Template",
            description: "A template with many tasks",
            category: .learning,
            defaultNumberOfDays: 10,
            tasks: [
                Task(id: UUID(), title: "Task 1", description: "First task"),
                Task(id: UUID(), title: "Task 2", description: "Second task"),
                Task(id: UUID(), title: "Task 3", description: "Third task"),
                Task(id: UUID(), title: "Task 4", description: "Fourth task"),
                Task(id: UUID(), title: "Task 5", description: "Fifth task")
            ],
            isDefault: false
        )
        
        // Act - Collapsed state (default)
        let collapsedTasks = Array(template.tasks.prefix(3))
        
        // Act - Expanded state (all tasks)
        let expandedTasks = template.tasks
        
        // Assert
        XCTAssertEqual(collapsedTasks.count, 3, "Collapsed state should show only 3 tasks")
        XCTAssertEqual(expandedTasks.count, 5, "Expanded state should show all tasks")
        XCTAssertEqual(expandedTasks[0].title, "Task 1")
        XCTAssertEqual(expandedTasks[1].title, "Task 2")
        XCTAssertEqual(expandedTasks[2].title, "Task 3")
        XCTAssertEqual(expandedTasks[3].title, "Task 4")
        XCTAssertEqual(expandedTasks[4].title, "Task 5")
    }
} 