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
        // TODO: Implement logic
        return -1 // placeholder to make test fail
    }
    func isDayMissed(for date: Date, completedTaskIDs: Set<UUID>) -> Bool {
        // TODO: Implement logic
        return false // placeholder to make test fail
    }
} 