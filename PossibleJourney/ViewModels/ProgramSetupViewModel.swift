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
    @Published var selectedDate: Date = Date() // Add selected date

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
        // Mark the missed day as completed so user can continue from the next day
        // This allows the user to skip the missed day and continue their program
        program.lastCompletedDay = currentActiveDay
        ProgramStorage().save(program)
        
        // Also update the current daily progress to reflect the new day
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: currentActiveDay)!
        let nextDayProgress = DailyProgress(
            id: UUID(),
            date: nextDay,
            completedTaskIDs: []
        )
        updateDailyProgress(nextDayProgress)
    }
    
    func updateDailyProgress(_ newProgress: DailyProgress) {
        dailyProgress = newProgress
        selectedDate = newProgress.date
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
        self.selectedDate = dailyProgress.date
    }
} 