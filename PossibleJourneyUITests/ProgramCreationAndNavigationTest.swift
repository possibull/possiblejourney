import XCTest

final class ProgramCreationAndNavigationTest: UITestHelperMixin {
    
    func testCreateProgramAndNavigateToDailyChecklist() throws {
        // Given: We start with a clean state
        try resetToCleanState()
        
        // When: We create a program and start it
        try createProgram(from: nil, name: nil)
        try startProgram()
        
        // Then: We should be on the daily checklist page
        try verifyOnDailyChecklist()
    }
    
    func testCreateProgramWithSpecificTemplate() throws {
        // Given: We start with a clean state
        try resetToCleanState()
        
        // When: We create a program with a specific template
        try createProgram(from: "Simple", name: "My Test Program")
        try startProgram()
        
        // Then: We should be on the daily checklist page
        try verifyOnDailyChecklist()
    }
    
    func testCreateProgramAndVerifyNavigationFlow() throws {
        // Given: We start with a clean state
        try resetToCleanState()
        
        // When: We navigate through the complete program creation flow
        try navigateToProgramCreation()
        try createProgram(from: nil, name: nil)
        try startProgram()
        
        // Then: We should be on the daily checklist page
        try verifyOnDailyChecklist()
        
        // And: The daily checklist should be functional
        XCTAssertTrue(app.staticTexts["Daily Checklist"].exists, "Daily Checklist title should be visible")
    }
} 