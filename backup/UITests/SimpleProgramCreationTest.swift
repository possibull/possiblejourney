import XCTest

/// Simple test to verify we can create a program from template and start it
final class SimpleProgramCreationTest: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testCreateProgramFromTemplateAndStart() throws {
        // Given: App is launched
        print("🚀 App launched")
        
        // Wait for splash screen to disappear
        Thread.sleep(forTimeInterval: 3)
        
        // When: We navigate to program creation
        print("📱 Looking for program creation elements...")
        
        // Check if we're on template selection page
        if app.staticTexts["Choose Template"].waitForExistence(timeout: 5) {
            print("✅ Found 'Choose Template' text")
            
            // Select first available template
            let templateCards = app.cells
            if templateCards.count > 0 {
                print("📋 Found \(templateCards.count) template cards")
                templateCards.element(boundBy: 0).tap()
                print("✅ Tapped first template")
                
                Thread.sleep(forTimeInterval: 2)
                
                // Look for start program button
                let startButton = app.buttons["Start Program"]
                if startButton.waitForExistence(timeout: 5) {
                    print("✅ Found 'Start Program' button")
                    startButton.tap()
                    print("✅ Tapped 'Start Program'")
                    
                    Thread.sleep(forTimeInterval: 2)
                    
                    // Handle release notes if they appear
                    let continueButton = app.navigationBars.buttons["Continue"]
                    if continueButton.waitForExistence(timeout: 3) {
                        print("📝 Found release notes, continuing...")
                        continueButton.tap()
                        Thread.sleep(forTimeInterval: 1)
                    }
                    
                    // Then: We should be on the daily checklist
                    let dailyChecklistText = app.staticTexts["Daily Checklist"]
                    if dailyChecklistText.waitForExistence(timeout: 10) {
                        print("✅ Successfully reached Daily Checklist page!")
                        XCTAssertTrue(dailyChecklistText.exists, "Should be on Daily Checklist page")
                    } else {
                        print("❌ Daily Checklist text not found")
                        // Print what we can see for debugging
                        let allTexts = app.staticTexts.allElementsBoundByIndex
                        print("📄 Available text elements:")
                        for (index, text) in allTexts.enumerated() {
                            if text.exists {
                                print("  \(index): '\(text.label)'")
                            }
                        }
                        XCTFail("Should be on Daily Checklist page")
                    }
                    
                } else {
                    print("❌ 'Start Program' button not found")
                    XCTFail("Start Program button should exist")
                }
                
            } else {
                print("❌ No template cards found")
                XCTFail("Template cards should exist")
            }
            
        } else {
            print("❌ 'Choose Template' text not found")
            // Print what we can see for debugging
            let allTexts = app.staticTexts.allElementsBoundByIndex
            print("📄 Available text elements:")
            for (index, text) in allTexts.enumerated() {
                if text.exists {
                    print("  \(index): '\(text.label)'")
                }
            }
            XCTFail("Should be on template selection page")
        }
    }
} 