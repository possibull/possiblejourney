import Foundation

struct Program: Codable {
    let id: UUID
    let startDate: Date
    let numberOfDays: Int
    var tasks: [Task]
    var endOfDayTime: Date = Calendar.current.startOfDay(for: Date()) // Default 12:00AM
}

extension Program {
    func appDay(for date: Date) -> Int {
        let calendar = Calendar.current
        let startOfStartDate = calendar.startOfDay(for: startDate)
        let startOfDate = calendar.startOfDay(for: date)
        let diff = calendar.dateComponents([.day], from: startOfStartDate, to: startOfDate).day ?? 0
        if diff < 0 {
            return 0
        }
        return diff + 1
    }
    func isDayMissed(for date: Date, completedTaskIDs: Set<UUID>) -> Bool {
        // TODO: Implement logic
        return false // placeholder to make test fail
    }
} 