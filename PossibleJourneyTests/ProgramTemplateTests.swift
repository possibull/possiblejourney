import XCTest
@testable import PossibleJourney

final class ProgramTemplateTests: XCTestCase {
    func testCreateAndRetrieveTemplateByID() {
        // Arrange
        let storage = ProgramTemplateStorage()
        storage.clear() // Ensure clean state
        let template = ProgramTemplate(
            name: "Test Template",
            description: "A template for testing.",
            category: .learning,
            defaultNumberOfDays: 10,
            tasks: [
                Task(id: UUID(), title: "Test Task 1", description: "Desc 1"),
                Task(id: UUID(), title: "Test Task 2", description: "Desc 2")
            ],
            isDefault: false
        )
        // Act
        storage.add(template)
        let loaded = storage.get(by: template.id)
        // Assert
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.id, template.id)
        XCTAssertEqual(loaded?.name, "Test Template")
        XCTAssertEqual(loaded?.tasks.count, 2)
    }
    
    func testCreateProgramFromTemplate() {
        // Arrange
        let template = ProgramTemplate(
            name: "Test Template",
            description: "A template for testing.",
            category: .learning,
            defaultNumberOfDays: 10,
            tasks: [
                Task(id: UUID(), title: "Test Task 1", description: "Desc 1"),
                Task(id: UUID(), title: "Test Task 2", description: "Desc 2")
            ],
            isDefault: false
        )
        let startDate = Date()
        let endOfDayTime = Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22) // 10pm
        
        // Act
        let program = template.createProgram(startDate: startDate, endOfDayTime: endOfDayTime)
        
        // Assert
        XCTAssertEqual(program.templateID, template.id)
        XCTAssertEqual(program.startDate, startDate)
        XCTAssertEqual(program.endOfDayTime, endOfDayTime)
        XCTAssertNil(program.lastCompletedDay) // Should be nil initially
    }
    
    func testProgramResolvesTasksAndNumberOfDaysFromTemplate() {
        // Arrange
        let storage = ProgramTemplateStorage()
        storage.clear() // Ensure clean state
        
        let template = ProgramTemplate(
            name: "Test Template",
            description: "A template for testing.",
            category: .learning,
            defaultNumberOfDays: 15,
            tasks: [
                Task(id: UUID(), title: "Task 1", description: "Description 1"),
                Task(id: UUID(), title: "Task 2", description: "Description 2"),
                Task(id: UUID(), title: "Task 3", description: "Description 3")
            ],
            isDefault: false
        )
        storage.add(template)
        
        let program = template.createProgram(startDate: Date(), endOfDayTime: Date())
        
        // Act
        let resolvedTasks = program.tasks(using: storage)
        let resolvedNumberOfDays = program.numberOfDays(using: storage)
        let resolvedTemplate = program.template(using: storage)
        
        // Assert
        XCTAssertEqual(resolvedTasks.count, 3)
        XCTAssertEqual(resolvedTasks[0].title, "Task 1")
        XCTAssertEqual(resolvedTasks[1].title, "Task 2")
        XCTAssertEqual(resolvedTasks[2].title, "Task 3")
        XCTAssertEqual(resolvedNumberOfDays, 15)
        XCTAssertNotNil(resolvedTemplate)
        XCTAssertEqual(resolvedTemplate?.id, template.id)
    }
    
    func testUpdateAndDeleteTemplate() {
        // Arrange
        let storage = ProgramTemplateStorage()
        storage.clear() // Ensure clean state
        
        let originalTemplate = ProgramTemplate(
            name: "Original Template",
            description: "Original description",
            category: .health,
            defaultNumberOfDays: 10,
            tasks: [
                Task(id: UUID(), title: "Original Task", description: "Original task description")
            ],
            isDefault: false
        )
        storage.add(originalTemplate)
        
        // Act - Update the template
        let updatedTemplate = ProgramTemplate(
            id: originalTemplate.id, // Same ID
            name: "Updated Template",
            description: "Updated description",
            category: .productivity,
            defaultNumberOfDays: 20,
            tasks: [
                Task(id: UUID(), title: "Updated Task 1", description: "Updated task 1"),
                Task(id: UUID(), title: "Updated Task 2", description: "Updated task 2")
            ],
            isDefault: true
        )
        storage.update(updatedTemplate)
        
        // Assert - Verify update
        let retrievedTemplate = storage.get(by: originalTemplate.id)
        XCTAssertNotNil(retrievedTemplate)
        XCTAssertEqual(retrievedTemplate?.name, "Updated Template")
        XCTAssertEqual(retrievedTemplate?.description, "Updated description")
        XCTAssertEqual(retrievedTemplate?.category, .productivity)
        XCTAssertEqual(retrievedTemplate?.defaultNumberOfDays, 20)
        XCTAssertEqual(retrievedTemplate?.tasks.count, 2)
        XCTAssertEqual(retrievedTemplate?.isDefault, true)
        
        // Act - Delete the template
        storage.delete(updatedTemplate)
        
        // Assert - Verify deletion
        let deletedTemplate = storage.get(by: originalTemplate.id)
        XCTAssertNil(deletedTemplate)
    }
    
    func testTemplateSelectionFlow() {
        // Arrange
        let storage = ProgramTemplateStorage()
        storage.clear() // Ensure clean state
        
        let template = ProgramTemplate(
            name: "Test Template",
            description: "A template for testing.",
            category: .learning,
            defaultNumberOfDays: 10,
            tasks: [
                Task(id: UUID(), title: "Test Task 1", description: "Desc 1"),
                Task(id: UUID(), title: "Test Task 2", description: "Desc 2")
            ],
            isDefault: false
        )
        storage.add(template)
        
        let startDate = Date()
        let endOfDayTime = Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22) // 10pm
        
        // Act - Simulate the template selection flow
        let program = template.createProgram(startDate: startDate, endOfDayTime: endOfDayTime)
        
        // Assert - Verify the program was created correctly
        XCTAssertEqual(program.templateID, template.id)
        XCTAssertEqual(program.startDate, startDate)
        XCTAssertEqual(program.endOfDayTime, endOfDayTime)
        XCTAssertNil(program.lastCompletedDay)
        
        // Verify the program can resolve its template and tasks
        let resolvedTemplate = program.template(using: storage)
        let resolvedTasks = program.tasks(using: storage)
        let resolvedNumberOfDays = program.numberOfDays(using: storage)
        
        XCTAssertNotNil(resolvedTemplate)
        XCTAssertEqual(resolvedTemplate?.id, template.id)
        XCTAssertEqual(resolvedTasks.count, 2)
        XCTAssertEqual(resolvedNumberOfDays, 10)
    }

    func testProgramWithCustomNumberOfDays() {
        // Arrange
        let storage = ProgramTemplateStorage()
        storage.clear()
        
        let template = ProgramTemplate(
            name: "Test Template",
            description: "A template for testing custom days.",
            category: .learning,
            defaultNumberOfDays: 30,
            tasks: [
                Task(id: UUID(), title: "Test Task 1", description: "Desc 1"),
                Task(id: UUID(), title: "Test Task 2", description: "Desc 2")
            ],
            isDefault: true
        )
        storage.add(template)
        
        // Act - Create program with custom number of days
        let customDays = 15
        let program = template.createProgram(numberOfDays: customDays)
        
        // Assert
        XCTAssertEqual(program.numberOfDays(), customDays)
        XCTAssertEqual(program.templateID, template.id)
        XCTAssertNotNil(program.startDate)
        XCTAssertNotNil(program.endOfDayTime)
    }
    
    func testProgramUsesTemplateDefaultWhenNoCustomDaysSpecified() {
        // Arrange
        let storage = ProgramTemplateStorage()
        storage.clear()
        
        let template = ProgramTemplate(
            name: "Test Template",
            description: "A template for testing default days.",
            category: .learning,
            defaultNumberOfDays: 25,
            tasks: [
                Task(id: UUID(), title: "Test Task 1", description: "Desc 1")
            ],
            isDefault: true
        )
        storage.add(template)
        
        // Act - Create program without specifying custom days
        let program = template.createProgram()
        
        // Assert
        XCTAssertEqual(program.numberOfDays(), template.defaultNumberOfDays)
        XCTAssertEqual(program.numberOfDays(), 25)
    }
    
    func testProgramWithCustomDaysAndOtherParameters() {
        // Arrange
        let storage = ProgramTemplateStorage()
        storage.clear()
        
        let template = ProgramTemplate(
            name: "Test Template",
            description: "A template for testing custom days with other params.",
            category: .health,
            defaultNumberOfDays: 21,
            tasks: [
                Task(id: UUID(), title: "Exercise", description: "Daily workout")
            ],
            isDefault: true
        )
        storage.add(template)
        
        let customStartDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let customEndTime = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
        let customDays = 45
        
        // Act
        let program = template.createProgram(
            startDate: customStartDate,
            endOfDayTime: customEndTime,
            numberOfDays: customDays
        )
        
        // Assert
        XCTAssertEqual(program.numberOfDays(), customDays)
        XCTAssertEqual(program.startDate, customStartDate)
        XCTAssertEqual(program.endOfDayTime, customEndTime)
        XCTAssertEqual(program.templateID, template.id)
    }
    
    func testProgramDayCalculationWithCustomDays() {
        // Arrange
        let storage = ProgramTemplateStorage()
        storage.clear()
        
        let template = ProgramTemplate(
            name: "Test Template",
            description: "A template for testing day calculation.",
            category: .productivity,
            defaultNumberOfDays: 10,
            tasks: [
                Task(id: UUID(), title: "Task", description: "Description")
            ],
            isDefault: true
        )
        storage.add(template)
        
        let startDate = Calendar.current.startOfDay(for: Date())
        let customDays = 7
        let program = template.createProgram(startDate: startDate, numberOfDays: customDays)
        
        // Act & Assert
        XCTAssertEqual(program.appDay(for: startDate), 1)
        XCTAssertEqual(program.appDay(for: Calendar.current.date(byAdding: .day, value: 6, to: startDate)!), 7)
        XCTAssertEqual(program.appDay(for: Calendar.current.date(byAdding: .day, value: 7, to: startDate)!), 8) // Should be 8 even though program is only 7 days
        XCTAssertEqual(program.appDay(for: Calendar.current.date(byAdding: .day, value: -1, to: startDate)!), 0) // Before start
    }
} 