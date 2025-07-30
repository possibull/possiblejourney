import Foundation

class ProgramSetupViewModel {
    var numberOfDays: Int = 75
    var tasks: [Task] = []

    func addTask(title: String, description: String?) {
        let newTask = Task(id: UUID(), title: title, description: description)
        tasks.append(newTask)
    }

    func isTaskNameValid(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 3 && trimmed.count <= 50
    }
    func isDescriptionValid(_ description: String) -> Bool {
        description.count <= 100
    }

    func saveProgram(templateID: UUID) -> Program? {
        guard !tasks.isEmpty else { return nil }
        return Program(
            id: UUID(),
            startDate: Date(),
            endOfDayTime: Calendar.current.startOfDay(for: Date()),
            lastCompletedDay: nil,
            templateID: templateID,
            customNumberOfDays: nil
        )
    }
}

class DailyChecklistViewModel: ObservableObject {
    @Published var program: Program
    @Published var dailyProgress: DailyProgress
    @Published var now: Date
    @Published var ignoreMissedDayForCurrentSession: Bool = false
    @Published var selectedDate: Date // Add selected date

    // The current active day is determined by program.nextActiveDay(now)
    var currentActiveDay: Date {
        program.currentAppDay
    }

    var isDayMissed: Bool {
        if ignoreMissedDayForCurrentSession {
            return false
        }
        
        // Check if any previous days in the program were missed
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: program.startDate)
        let viewingDate = calendar.startOfDay(for: selectedDate)
        
        // Check all days from start date up to (but not including) the viewing date
        var currentDate = startDate
        let dailyProgressStorage = DailyProgressStorage()
        
        while currentDate < viewingDate {
            // Skip if we're past the program duration
            let dayNumber = calendar.dateComponents([.day], from: startDate, to: currentDate).day ?? 0
            if dayNumber >= program.numberOfDays() {
                break
            }
            
            // Load the progress for this day and check if it was completed
            let dayProgress = dailyProgressStorage.load(for: currentDate) ?? DailyProgress(
                id: UUID(),
                date: currentDate,
                completedTaskIDs: [],
                isCompleted: false // Default to not completed if no progress exists
            )
            
            if !dayProgress.isCompleted {
                // Found an incomplete day, trigger missed day screen
                return true
            }
            
            // Move to next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // No missed days found
        return false
    }

    func completeCurrentDay() {
        // Called when all tasks are completed for the current day
        program.lastCompletedDay = currentActiveDay
        // Save program with updated lastCompletedDay
        ProgramStorage().save(program)
        
        // Mark the day as completed since all tasks are done
        dailyProgress.isCompleted = true
        DailyProgressStorage().save(progress: dailyProgress)
    }

    func resetProgramToToday() {
        // Called when user taps 'I Missed It'
        // Clear the loaded program to navigate back to Program Template page
        // This preserves the historical program data and allows starting fresh
        ProgramStorage().clear()
        DailyProgressStorage().clearAll()
    }
    
    func updateDailyProgress(_ newProgress: DailyProgress) {
        dailyProgress = newProgress
        // Don't automatically update selectedDate - only update when user explicitly selects from calendar
    }
    
    func selectDate(_ date: Date) {
        selectedDate = date
        // Update the current date to the selected date for missed day calculations
        now = date
        // Clear the ignore flag when selecting a new date so missed day logic can evaluate
        ignoreMissedDayForCurrentSession = false
        // Load the progress for the selected date
        let dailyProgressStorage = DailyProgressStorage()
        let progress = dailyProgressStorage.load(for: date) ?? DailyProgress(
            id: UUID(),
            date: date,
            completedTaskIDs: [],
            isCompleted: false // Default to not completed until completed
        )
        updateDailyProgress(progress)
    }
    
    func getCompletedDates() -> Set<Date> {
        // Get all completed dates from the program
        var completedDates: Set<Date> = []
        
        if let lastCompleted = program.lastCompletedDay {
            // Add all dates from start to last completed day
            let calendar = Calendar.current
            var currentDate = calendar.startOfDay(for: program.startDate)
            let endDate = calendar.startOfDay(for: lastCompleted)
            
            while currentDate <= endDate {
                completedDates.insert(currentDate)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
        }
        
        return completedDates
    }

    init(program: Program, dailyProgress: DailyProgress, now: Date = Date()) {
        self.program = program
        self.dailyProgress = dailyProgress
        self.now = now
        self.selectedDate = now // Always start with current date, not the loaded progress date
    }
} 