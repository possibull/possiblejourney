import XCTest
import SwiftUI
@testable import PossibleJourney

final class CelebrationTests: XCTestCase {
    
    // MARK: - CelebrationManager Tests
    
    func testCelebrationManagerDefaultValues() {
        // Given: A new CelebrationManager
        let manager = CelebrationManager()
        
        // Then: Default values should be set correctly
        XCTAssertEqual(manager.celebrationType, .confetti)
        XCTAssertTrue(manager.celebrationEnabled)
    }
    
    func testCelebrationManagerGetRandomCelebrationType() {
        // Given: A CelebrationManager
        let manager = CelebrationManager()
        
        // When: Getting a random celebration type
        let randomType = manager.getRandomCelebrationType()
        
        // Then: Should return a valid celebration type (not random)
        XCTAssertNotEqual(randomType, .random)
        XCTAssertTrue([.confetti, .fireworks, .balloons, .sparkles].contains(randomType))
    }
    
    func testCelebrationManagerGetCurrentCelebrationTypeWhenRandom() {
        // Given: A CelebrationManager with random type
        let manager = CelebrationManager()
        manager.celebrationType = .random
        
        // When: Getting current celebration type
        let currentType = manager.getCurrentCelebrationType()
        
        // Then: Should return a specific type, not random
        XCTAssertNotEqual(currentType, .random)
        XCTAssertTrue([.confetti, .fireworks, .balloons, .sparkles].contains(currentType))
    }
    
    func testCelebrationManagerGetCurrentCelebrationTypeWhenSpecific() {
        // Given: A CelebrationManager with specific type
        let manager = CelebrationManager()
        manager.celebrationType = .fireworks
        
        // When: Getting current celebration type
        let currentType = manager.getCurrentCelebrationType()
        
        // Then: Should return the specific type
        XCTAssertEqual(currentType, .fireworks)
    }
    
    // MARK: - CelebrationType Tests
    
    func testCelebrationTypeDisplayNames() {
        // Then: All celebration types should have proper display names
        XCTAssertEqual(CelebrationType.confetti.displayName, "Confetti")
        XCTAssertEqual(CelebrationType.fireworks.displayName, "Fireworks")
        XCTAssertEqual(CelebrationType.balloons.displayName, "Balloons")
        XCTAssertEqual(CelebrationType.sparkles.displayName, "Sparkles")
        XCTAssertEqual(CelebrationType.random.displayName, "Random")
    }
    
    func testCelebrationTypeIcons() {
        // Then: All celebration types should have proper icons
        XCTAssertEqual(CelebrationType.confetti.icon, "sparkles")
        XCTAssertEqual(CelebrationType.fireworks.icon, "flame")
        XCTAssertEqual(CelebrationType.balloons.icon, "balloon")
        XCTAssertEqual(CelebrationType.sparkles.icon, "star.fill")
        XCTAssertEqual(CelebrationType.random.icon, "dice")
    }
    
    func testCelebrationTypeIdentifiable() {
        // Then: All celebration types should be identifiable
        let types = CelebrationType.allCases
        XCTAssertEqual(types.count, 5)
        
        for type in types {
            XCTAssertFalse(type.id.isEmpty)
            XCTAssertEqual(type.id, type.rawValue)
        }
    }
    
    // MARK: - Celebration Trigger Tests
    
    func testCelebrationTriggeredWhenAllTasksCompleted() {
        // Given: A program with tasks and celebration enabled
        let program = Program(
            id: UUID(),
            startDate: Date(),
            endOfDayTime: Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22),
            lastCompletedDay: nil,
            templateID: UUID(),
            customNumberOfDays: 7
        )
        
        let task1 = Task(id: UUID(), title: "Task 1", description: "Description 1", requiresPhoto: false)
        let task2 = Task(id: UUID(), title: "Task 2", description: "Description 2", requiresPhoto: false)
        
        let dailyProgress = DailyProgress(
            id: UUID(),
            date: Date(),
            completedTaskIDs: [task1.id, task2.id], // All tasks completed
            isCompleted: false
        )
        
        let celebrationManager = CelebrationManager()
        celebrationManager.celebrationEnabled = true
        
        // When: Checking if celebration should be triggered
        // Simulate the logic from DailyChecklistView.toggleTask
        let allTasksCompleted = [task1, task2].allSatisfy { 
            dailyProgress.completedTaskIDs.contains($0.id) 
        }
        
        // Then: Celebration should be triggered
        XCTAssertTrue(allTasksCompleted)
        XCTAssertTrue(celebrationManager.celebrationEnabled)
    }
    
    func testCelebrationNotTriggeredWhenTasksIncomplete() {
        // Given: A program with tasks and celebration enabled
        let program = Program(
            id: UUID(),
            startDate: Date(),
            endOfDayTime: Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22),
            lastCompletedDay: nil,
            templateID: UUID(),
            customNumberOfDays: 7
        )
        
        let task1 = Task(id: UUID(), title: "Task 1", description: "Description 1", requiresPhoto: false)
        let task2 = Task(id: UUID(), title: "Task 2", description: "Description 2", requiresPhoto: false)
        
        let dailyProgress = DailyProgress(
            id: UUID(),
            date: Date(),
            completedTaskIDs: [task1.id], // Only one task completed
            isCompleted: false
        )
        
        let celebrationManager = CelebrationManager()
        celebrationManager.celebrationEnabled = true
        
        // When: Checking if celebration should be triggered
        let allTasksCompleted = [task1, task2].allSatisfy { 
            dailyProgress.completedTaskIDs.contains($0.id) 
        }
        
        // Then: Celebration should not be triggered
        XCTAssertFalse(allTasksCompleted)
    }
    
    func testCelebrationNotTriggeredWhenDisabled() {
        // Given: A program with all tasks completed but celebration disabled
        let program = Program(
            id: UUID(),
            startDate: Date(),
            endOfDayTime: Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22),
            lastCompletedDay: nil,
            templateID: UUID(),
            customNumberOfDays: 7
        )
        
        let task1 = Task(id: UUID(), title: "Task 1", description: "Description 1", requiresPhoto: false)
        let task2 = Task(id: UUID(), title: "Task 2", description: "Description 2", requiresPhoto: false)
        
        let dailyProgress = DailyProgress(
            id: UUID(),
            date: Date(),
            completedTaskIDs: [task1.id, task2.id], // All tasks completed
            isCompleted: false
        )
        
        let celebrationManager = CelebrationManager()
        celebrationManager.celebrationEnabled = false // Disabled
        
        // When: Checking if celebration should be triggered
        let allTasksCompleted = [task1, task2].allSatisfy { 
            dailyProgress.completedTaskIDs.contains($0.id) 
        }
        
        // Then: Celebration should not be triggered even though tasks are complete
        XCTAssertTrue(allTasksCompleted)
        XCTAssertFalse(celebrationManager.celebrationEnabled)
    }
    
    // MARK: - Edge Case Tests
    
    func testCelebrationSettingsWithEmptyTasks() {
        // Given: A program with no tasks
        let program = Program(
            id: UUID(),
            startDate: Date(),
            endOfDayTime: Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22),
            lastCompletedDay: nil,
            templateID: UUID(),
            customNumberOfDays: 7
        )
        
        let dailyProgress = DailyProgress(
            id: UUID(),
            date: Date(),
            completedTaskIDs: [],
            isCompleted: false
        )
        
        let celebrationManager = CelebrationManager()
        celebrationManager.celebrationEnabled = true
        
        // When: Checking if celebration should be triggered
        let allTasksCompleted = [].allSatisfy { (task: Task) in
            dailyProgress.completedTaskIDs.contains(task.id) 
        }
        
        // Then: Should be true for empty task list (all 0 tasks are completed)
        XCTAssertTrue(allTasksCompleted)
    }
    
    func testCelebrationSettingsWithPhotoRequiredTasks() {
        // Given: A program with photo-required tasks
        let program = Program(
            id: UUID(),
            startDate: Date(),
            endOfDayTime: Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22),
            lastCompletedDay: nil,
            templateID: UUID(),
            customNumberOfDays: 7
        )
        
        let photoTask = Task(id: UUID(), title: "Photo Task", description: "Take a photo", requiresPhoto: true)
        
        let dailyProgress = DailyProgress(
            id: UUID(),
            date: Date(),
            completedTaskIDs: [photoTask.id], // Task completed but photo might not be taken
            isCompleted: false
        )
        
        let celebrationManager = CelebrationManager()
        celebrationManager.celebrationEnabled = true
        
        // When: Checking if celebration should be triggered
        let allTasksCompleted = [photoTask].allSatisfy { 
            dailyProgress.completedTaskIDs.contains($0.id) 
        }
        
        // Then: Celebration should be triggered if task is marked complete
        XCTAssertTrue(allTasksCompleted)
    }
}

 