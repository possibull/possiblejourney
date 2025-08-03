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
        let dailyProgressStorage = DailyProgressStorage()
        
        // Check all days from start date up to (but not including) the viewing date
        var currentDate = startDate
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
        
        // Also check if the current viewing date itself is missed
        // Skip if we're past the program duration
        let viewingDayNumber = calendar.dateComponents([.day], from: startDate, to: viewingDate).day ?? 0
        if viewingDayNumber < program.numberOfDays() {
            // Load the progress for the viewing date and check if it was completed
            let viewingDayProgress = dailyProgressStorage.load(for: viewingDate) ?? DailyProgress(
                id: UUID(),
                date: viewingDate,
                completedTaskIDs: [],
                isCompleted: false // Default to not completed if no progress exists
            )
            
            if !viewingDayProgress.isCompleted {
                // Check if the viewing date is past its end-of-day (i.e., missed)
                let now = Date()
                let completedTaskIDs = Set(viewingDayProgress.completedTaskIDs)
                if program.isDayMissed(for: now, completedTaskIDs: completedTaskIDs) {
                    return true
                }
            }
        }
        
        // No missed days found
        return false
    }

    func completeCurrentDay() {
        // Called when all tasks are completed for the current day
        // Set lastCompletedDay to the actual date being completed (selectedDate), not the computed currentActiveDay
        program.lastCompletedDay = selectedDate
        // Save program with updated lastCompletedDay
        ProgramStorage().save(program)
        
        // Mark the day as completed since all tasks are done
        dailyProgress.isCompleted = true
        DailyProgressStorage().save(progress: dailyProgress)
        
        // Auto-advance to the next incomplete day
        autoAdvanceToNextIncompleteDay()
    }

    func resetProgramToToday() {
        // Called when user taps 'I Missed It'
        // Clear the loaded program to navigate back to Program Template page
        // This preserves the historical program data and allows starting fresh
        ProgramStorage().clear()
        DailyProgressStorage().clearAll()
    }
    
    // Auto-advance to the next incomplete day after completing the current day
    private func autoAdvanceToNextIncompleteDay() {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: program.startDate)
        let today = calendar.startOfDay(for: Date())
        let dailyProgressStorage = DailyProgressStorage()
        
        // Start checking from the day after the one we just completed
        var nextDate = calendar.date(byAdding: .day, value: 1, to: selectedDate)!
        
        // Check all days from the next day up to today
        while nextDate <= today {
            // Skip if we're past the program duration
            let dayNumber = calendar.dateComponents([.day], from: startDate, to: nextDate).day ?? 0
            if dayNumber >= program.numberOfDays() {
                break
            }
            
            // Load the progress for this day and check if it was completed
            let dayProgress = dailyProgressStorage.load(for: nextDate) ?? DailyProgress(
                id: UUID(),
                date: nextDate,
                completedTaskIDs: [],
                isCompleted: false
            )
            
            if !dayProgress.isCompleted {
                // Found the next incomplete day, navigate to it
                selectDate(nextDate)
                return
            }
            
            // Move to next day
            nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate)!
        }
        
        // No more incomplete days found, stay on today
        selectDate(today)
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
        // This allows the missed day screen to show for future dates
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
        // Start with today's date - the missed day logic will handle finding the first missed day
        self.selectedDate = Calendar.current.startOfDay(for: now)
    }
} 