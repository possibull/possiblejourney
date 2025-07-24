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

    func saveProgram() -> Program? {
        guard !tasks.isEmpty else { return nil }
        return Program(
            id: UUID(),
            startDate: Date(),
            numberOfDays: numberOfDays,
            tasks: tasks
        )
    }
}

class DailyChecklistViewModel: ObservableObject {
    @Published var program: Program
    @Published var dailyProgress: DailyProgress
    var now: Date

    var isDayMissed: Bool {
        program.isDayMissed(for: now, completedTaskIDs: Set(dailyProgress.completedTaskIDs))
    }

    init(program: Program, dailyProgress: DailyProgress, now: Date = Date()) {
        self.program = program
        self.dailyProgress = dailyProgress
        self.now = now
    }
} 