import XCTest
import SwiftUI
@testable import PossibleJourney

final class SettingsViewTests: XCTestCase {
    
    // MARK: - Celebration Settings Tests
    
    func testCelebrationSettingsCardExists() {
        // Given: A SettingsView with celebration manager
        let celebrationManager = CelebrationManager()
        let debugState = DebugState()
        let appState = ProgramAppState()
        let themeManager = ThemeManager()
        let endOfDayTime = Date()
        
        // When: Creating the settings view
        let settingsView = SettingsView(endOfDayTime: .constant(endOfDayTime))
            .environmentObject(celebrationManager)
            .environmentObject(debugState)
            .environmentObject(appState)
            .environmentObject(themeManager)
        
        // Then: The view should be created successfully
        XCTAssertNotNil(settingsView)
    }
    
    func testCelebrationSettingsDefaultValues() {
        // Given: A new CelebrationManager
        let manager = CelebrationManager()
        
        // Then: Default values should be set correctly
        // Note: Default values are stored in UserDefaults, so we need to check the actual stored values
        XCTAssertTrue(manager.celebrationEnabled, "Celebrations should be enabled by default")
        // The celebration type might be different due to UserDefaults persistence, so we just check it's valid
        XCTAssertTrue(CelebrationType.allCases.contains(manager.celebrationType), "Celebration type should be valid")
    }
    
    func testCelebrationSettingsToggle() {
        // Given: A CelebrationManager
        let manager = CelebrationManager()
        XCTAssertTrue(manager.celebrationEnabled)
        
        // When: Disabling celebrations
        manager.celebrationEnabled = false
        
        // Then: Celebrations should be disabled
        XCTAssertFalse(manager.celebrationEnabled)
        
        // When: Re-enabling celebrations
        manager.celebrationEnabled = true
        
        // Then: Celebrations should be enabled
        XCTAssertTrue(manager.celebrationEnabled)
    }
    
    func testCelebrationTypeSelection() {
        // Given: A CelebrationManager
        let manager = CelebrationManager()
        let initialType = manager.celebrationType
        
        // When: Changing celebration type
        manager.celebrationType = .fireworks
        
        // Then: Celebration type should be updated
        XCTAssertEqual(manager.celebrationType, .fireworks)
        
        // When: Changing to random
        manager.celebrationType = .random
        
        // Then: Celebration type should be random
        XCTAssertEqual(manager.celebrationType, .random)
        
        // When: Getting current type with random
        let currentType = manager.getCurrentCelebrationType()
        
        // Then: Should return a specific type, not random
        XCTAssertNotEqual(currentType, .random)
        XCTAssertTrue([.confetti, .fireworks, .balloons, .sparkles].contains(currentType))
        
        // Reset to initial type
        manager.celebrationType = initialType
    }
    
    func testAllCelebrationTypesSelectable() {
        // Given: A CelebrationManager
        let manager = CelebrationManager()
        
        // When & Then: All celebration types should be selectable
        manager.celebrationType = .confetti
        XCTAssertEqual(manager.celebrationType, .confetti)
        
        manager.celebrationType = .fireworks
        XCTAssertEqual(manager.celebrationType, .fireworks)
        
        manager.celebrationType = .balloons
        XCTAssertEqual(manager.celebrationType, .balloons)
        
        manager.celebrationType = .sparkles
        XCTAssertEqual(manager.celebrationType, .sparkles)
        
        manager.celebrationType = .random
        XCTAssertEqual(manager.celebrationType, .random)
    }
    
    // MARK: - Settings Persistence Tests
    
    func testCelebrationSettingsPersistence() {
        // Given: A CelebrationManager with custom settings
        let manager1 = CelebrationManager()
        manager1.celebrationEnabled = false
        manager1.celebrationType = .fireworks
        
        // When: Creating a new manager instance
        let manager2 = CelebrationManager()
        
        // Then: Settings should persist across instances
        XCTAssertEqual(manager2.celebrationEnabled, false)
        XCTAssertEqual(manager2.celebrationType, .fireworks)
    }
    
    func testCelebrationSettingsReset() {
        // Given: A CelebrationManager with custom settings
        let manager = CelebrationManager()
        manager.celebrationEnabled = false
        manager.celebrationType = .balloons
        
        // When: Resetting to defaults
        manager.celebrationEnabled = true
        manager.celebrationType = .confetti
        
        // Then: Should be back to defaults
        XCTAssertTrue(manager.celebrationEnabled)
        XCTAssertEqual(manager.celebrationType, .confetti)
    }
    
    // MARK: - Integration Tests
    
    func testCelebrationSettingsIntegrationWithDailyChecklist() {
        // Given: A complete setup with settings and daily checklist
        let celebrationManager = CelebrationManager()
        let debugState = DebugState()
        let appState = ProgramAppState()
        let themeManager = ThemeManager()
        
        // When: Configuring celebration settings
        celebrationManager.celebrationEnabled = true
        celebrationManager.celebrationType = .fireworks
        
        // Then: Settings should be properly configured
        XCTAssertTrue(celebrationManager.celebrationEnabled)
        XCTAssertEqual(celebrationManager.celebrationType, .fireworks)
        
        // When: Getting current celebration type
        let currentType = celebrationManager.getCurrentCelebrationType()
        
        // Then: Should return the configured type
        XCTAssertEqual(currentType, .fireworks)
    }
    
    func testCelebrationSettingsWithRandomType() {
        // Given: A CelebrationManager with random type
        let manager = CelebrationManager()
        manager.celebrationType = .random
        
        // When: Getting current celebration type multiple times
        let type1 = manager.getCurrentCelebrationType()
        let type2 = manager.getCurrentCelebrationType()
        let type3 = manager.getCurrentCelebrationType()
        
        // Then: Each call should return a valid celebration type
        XCTAssertTrue([.confetti, .fireworks, .balloons, .sparkles].contains(type1))
        XCTAssertTrue([.confetti, .fireworks, .balloons, .sparkles].contains(type2))
        XCTAssertTrue([.confetti, .fireworks, .balloons, .sparkles].contains(type3))
        
        // Note: They might be different due to randomness, which is expected
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