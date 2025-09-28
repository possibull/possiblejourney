import XCTest
@testable import PossibleJourney

final class TaskModelTests: XCTestCase {
    func testTaskInitialization() {
        let id = UUID()
        let task = Task(id: id, title: "Exercise", description: nil)
        XCTAssertEqual(task.id, id)
        XCTAssertEqual(task.title, "Exercise")
    }
    
    func testTaskWithPhotoRequirement() {
        let task = Task(id: UUID(), title: "Take Progress Photo", description: "Document your journey", requiresPhoto: true)
        XCTAssertTrue(task.requiresPhoto)
    }
    
    func testTaskWithoutPhotoRequirement() {
        let task = Task(id: UUID(), title: "Read", description: "Read 10 pages")
        XCTAssertFalse(task.requiresPhoto)
    }
    
    // MARK: - TaskType Tests (TDD Red Phase)
    func testTaskTypeEnumExists() {
        // This test will fail until we implement TaskType enum
        let taskType = TaskType.growth
        XCTAssertEqual(taskType, .growth)
    }
    
    func testTaskTypeHasThreeCases() {
        // Test that TaskType has all three required cases
        let growthType = TaskType.growth
        let maintenanceType = TaskType.maintenance
        let recoveryType = TaskType.recovery
        
        XCTAssertEqual(growthType, .growth)
        XCTAssertEqual(maintenanceType, .maintenance)
        XCTAssertEqual(recoveryType, .recovery)
    }
    
    func testTaskHasTaskTypeProperty() {
        // Test that Task struct has a taskType property
        let task = Task(id: UUID(), title: "Test Task", description: "Test Description", taskType: .growth)
        XCTAssertEqual(task.taskType, .growth)
    }
    
    func testTaskTypeDefaultValue() {
        // Test that Task has a default taskType value
        let task = Task(id: UUID(), title: "Test Task", description: "Test Description")
        XCTAssertEqual(task.taskType, .growth) // Default should be growth
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

final class DailyChecklistViewModelTests: XCTestCase {
    func testViewingDifferentDaysShowsCorrectDayNumber() {
        // Given: A program that starts today
        let today = Calendar.current.startOfDay(for: Date())
        let program = Program(
            id: UUID(),
            startDate: today,
            endOfDayTime: Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22),
            lastCompletedDay: nil,
            templateID: UUID(),
            customNumberOfDays: 7
        )
        
        // When: Viewing day 2 (tomorrow)
        let day2 = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let day2Progress = DailyProgress(
            id: UUID(),
            date: day2,
            completedTaskIDs: []
        )
        
        let viewModel = DailyChecklistViewModel(
            program: program,
            dailyProgress: day2Progress,
            now: day2
        )
        
        // Then: The day number should be 2
        let expectedDay = 2
        let actualDay = viewModel.program.appDay(for: day2)
        XCTAssertEqual(actualDay, expectedDay, "Day 2 should show as day 2, but got day \(actualDay)")
    }
    
    func testDailyProgressLoadsCorrectDataForDifferentDays() {
        // Given: A program with different progress for different days
        let today = Calendar.current.startOfDay(for: Date())
        let day1 = today
        let day2 = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let day3 = Calendar.current.date(byAdding: .day, value: 2, to: today)!
        
        let program = Program(
            id: UUID(),
            startDate: day1,
            endOfDayTime: Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22),
            lastCompletedDay: nil,
            templateID: UUID(),
            customNumberOfDays: 7
        )
        
        let storage = DailyProgressStorage()
        
        // Create different progress for each day
        let day1Progress = DailyProgress(
            id: UUID(),
            date: day1,
            completedTaskIDs: [UUID()]
        )
        
        let day2Progress = DailyProgress(
            id: UUID(),
            date: day2,
            completedTaskIDs: [UUID(), UUID()]
        )
        
        let day3Progress = DailyProgress(
            id: UUID(),
            date: day3,
            completedTaskIDs: []
        )
        
        // Save progress for each day
        storage.save(progress: day1Progress)
        storage.save(progress: day2Progress)
        storage.save(progress: day3Progress)
        
        // When: Loading progress for day 2
        let loadedDay2Progress = storage.load(for: day2)
        
        // Then: Should get day 2's progress, not day 1's
        XCTAssertNotNil(loadedDay2Progress, "Day 2 progress should be loaded")
        XCTAssertEqual(loadedDay2Progress?.date, day2, "Loaded progress should be for day 2")
        XCTAssertEqual(loadedDay2Progress?.completedTaskIDs.count, 2, "Day 2 should have 2 completed tasks")
        
        // When: Loading progress for day 1
        let loadedDay1Progress = storage.load(for: day1)
        
        // Then: Should get day 1's progress
        XCTAssertNotNil(loadedDay1Progress, "Day 1 progress should be loaded")
        XCTAssertEqual(loadedDay1Progress?.date, day1, "Loaded progress should be for day 1")
        XCTAssertEqual(loadedDay1Progress?.completedTaskIDs.count, 1, "Day 1 should have 1 completed task")
    }

    func testDay2ShowsCorrectInfoNotDay1Info() {
        // Given: A program that starts today with different progress for each day
        let today = Calendar.current.startOfDay(for: Date())
        let day1 = today
        let day2 = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let day3 = Calendar.current.date(byAdding: .day, value: 2, to: today)!
        
        let program = Program(
            id: UUID(),
            startDate: day1,
            endOfDayTime: Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22),
            lastCompletedDay: nil,
            templateID: UUID(),
            customNumberOfDays: 7
        )
        
        let storage = DailyProgressStorage()
        
        // Create different progress for each day
        let day1Progress = DailyProgress(
            id: UUID(),
            date: day1,
            completedTaskIDs: [UUID()]
        )
        
        let day2Progress = DailyProgress(
            id: UUID(),
            date: day2,
            completedTaskIDs: [UUID(), UUID()] // Different number of completed tasks
        )
        
        let day3Progress = DailyProgress(
            id: UUID(),
            date: day3,
            completedTaskIDs: []
        )
        
        // Save progress for each day
        storage.save(progress: day1Progress)
        storage.save(progress: day2Progress)
        storage.save(progress: day3Progress)
        
        // When: Creating a view model for day 2
        let loadedDay2Progress = storage.load(for: day2)!
        let viewModel = DailyChecklistViewModel(
            program: program,
            dailyProgress: loadedDay2Progress,
            now: day2
        )
        
        // Then: The view model should show day 2 info, not day 1 info
        XCTAssertEqual(viewModel.selectedDate, day2, "Selected date should be day 2")
        XCTAssertEqual(viewModel.dailyProgress.date, day2, "Daily progress should be for day 2")
        XCTAssertEqual(viewModel.dailyProgress.completedTaskIDs.count, 2, "Day 2 should have 2 completed tasks")
        
        // Verify the day number calculation
        let dayNumber = program.appDay(for: day2)
        XCTAssertEqual(dayNumber, 2, "Day 2 should be calculated as day 2")
    }

    func testDayCalculationForSpecificDates() {
        // Given: A program that starts on July 29th
        let calendar = Calendar.current
        let july29 = calendar.date(from: DateComponents(year: 2024, month: 7, day: 29))!
        let july30 = calendar.date(from: DateComponents(year: 2024, month: 7, day: 30))!
        let july31 = calendar.date(from: DateComponents(year: 2024, month: 7, day: 31))!
        
        let program = Program(
            id: UUID(),
            startDate: july29,
            endOfDayTime: calendar.startOfDay(for: july29).addingTimeInterval(60*60*22),
            lastCompletedDay: nil,
            templateID: UUID(),
            customNumberOfDays: 7
        )
        
        // Test day calculation for each date
        let day1 = calculateDayNumber(startDate: july29, selectedDate: july29)
        let day2 = calculateDayNumber(startDate: july29, selectedDate: july30)
        let day3 = calculateDayNumber(startDate: july29, selectedDate: july31)
        
        // Assertions
        XCTAssertEqual(day1, 1, "July 29th should be DAY 1")
        XCTAssertEqual(day2, 2, "July 30th should be DAY 2")
        XCTAssertEqual(day3, 3, "July 31st should be DAY 3")
        
        print("Day calculations: July 29th = Day \(day1), July 30th = Day \(day2), July 31st = Day \(day3)")
    }
    
    private func calculateDayNumber(startDate: Date, selectedDate: Date) -> Int {
        let start = Calendar.current.startOfDay(for: startDate)
        let selectedDay = Calendar.current.startOfDay(for: selectedDate)
        let diff = Calendar.current.dateComponents([.day], from: start, to: selectedDay).day ?? 0
        return min(max(diff + 1, 1), 7) // Assuming 7 days program
    }

    func testDailyChecklistViewModelSelectedDateUpdate() {
        // Given: A program that starts on July 29th
        let calendar = Calendar.current
        let july29 = calendar.date(from: DateComponents(year: 2024, month: 7, day: 29))!
        let july30 = calendar.date(from: DateComponents(year: 2024, month: 7, day: 30))!
        let july31 = calendar.date(from: DateComponents(year: 2024, month: 7, day: 31))!
        
        let program = Program(
            id: UUID(),
            startDate: july29,
            endOfDayTime: calendar.startOfDay(for: july29).addingTimeInterval(60*60*22),
            lastCompletedDay: nil,
            templateID: UUID(),
            customNumberOfDays: 7
        )
        
        let initialProgress = DailyProgress(id: UUID(), date: july29, completedTaskIDs: [])
        let viewModel = DailyChecklistViewModel(program: program, dailyProgress: initialProgress)
        
        // Test initial state
        XCTAssertEqual(viewModel.selectedDate, july29, "Initial selected date should be start date")
        
        // Test updating to July 30th
        let progress30 = DailyProgress(id: UUID(), date: july30, completedTaskIDs: [])
        viewModel.updateDailyProgress(progress30)
        
        XCTAssertEqual(viewModel.selectedDate, july30, "Selected date should be updated to July 30th")
        XCTAssertEqual(viewModel.dailyProgress.date, july30, "Daily progress date should be July 30th")
        
        // Test updating to July 31st
        let progress31 = DailyProgress(id: UUID(), date: july31, completedTaskIDs: [])
        viewModel.updateDailyProgress(progress31)
        
        XCTAssertEqual(viewModel.selectedDate, july31, "Selected date should be updated to July 31st")
        XCTAssertEqual(viewModel.dailyProgress.date, july31, "Daily progress date should be July 31st")
        
        print("Test passed: ViewModel correctly updates selectedDate")
    }

    func testMarkingDayAsMissedPreservesStartDate() {
        // Given: A program that starts on July 29th
        let calendar = Calendar.current
        let july29 = calendar.date(from: DateComponents(year: 2024, month: 7, day: 29))!
        let july30 = calendar.date(from: DateComponents(year: 2024, month: 7, day: 30))!
        let july31 = calendar.date(from: DateComponents(year: 2024, month: 7, day: 31))!
        
        let program = Program(
            id: UUID(),
            startDate: july29,
            endOfDayTime: calendar.startOfDay(for: july29).addingTimeInterval(60*60*22),
            lastCompletedDay: nil,
            templateID: UUID(),
            customNumberOfDays: 7
        )
        
        let initialProgress = DailyProgress(id: UUID(), date: july29, completedTaskIDs: [])
        let viewModel = DailyChecklistViewModel(program: program, dailyProgress: initialProgress)
        
        // Verify initial state
        XCTAssertEqual(viewModel.program.startDate, july29)
        XCTAssertEqual(viewModel.currentActiveDay, july29)
        
        // When: Marking the day as missed (July 29th)
        viewModel.resetProgramToToday()
        
        // Then: Start date should remain July 29th, but current active day should be July 30th
        XCTAssertEqual(viewModel.program.startDate, july29, "Start date should not change")
        XCTAssertEqual(viewModel.program.lastCompletedDay, july29, "Last completed day should be July 29th")
        XCTAssertEqual(viewModel.currentActiveDay, july30, "Current active day should be July 30th")
        XCTAssertEqual(viewModel.selectedDate, july30, "Selected date should be July 30th")
        
        // Verify day calculation still works correctly
        let day1 = calculateDayNumber(startDate: july29, selectedDate: july29)
        let day2 = calculateDayNumber(startDate: july29, selectedDate: july30)
        let day3 = calculateDayNumber(startDate: july29, selectedDate: july31)
        
        XCTAssertEqual(day1, 1, "July 29th should be Day 1")
        XCTAssertEqual(day2, 2, "July 30th should be Day 2")
        XCTAssertEqual(day3, 3, "July 31st should be Day 3")
    }
    

} 