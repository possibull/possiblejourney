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
        return program.isCurrentAppDayMissed(now: now, completedTaskIDs: Set(dailyProgress.completedTaskIDs))
    }

    func completeCurrentDay() {
        // Called when all tasks are completed for the current day
        program.lastCompletedDay = currentActiveDay
        // Save program with updated lastCompletedDay
        ProgramStorage().save(program)
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
        // Load the progress for the selected date
        let dailyProgressStorage = DailyProgressStorage()
        let progress = dailyProgressStorage.load(for: date) ?? DailyProgress(
            id: UUID(),
            date: date,
            completedTaskIDs: []
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