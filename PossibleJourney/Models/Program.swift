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
        let calendar = Calendar.current
        let appDay = self.appDay(for: date)
        if appDay < 1 || appDay > numberOfDays { return false } // Not in program range

        // Compute the start of this app day
        let appDayStart = calendar.date(byAdding: .day, value: appDay - 1, to: calendar.startOfDay(for: startDate))!
        let endHour = calendar.component(.hour, from: endOfDayTime)
        let endMinute = calendar.component(.minute, from: endOfDayTime)
        var endOfAppDay: Date
        if endHour < 12 {
            // AM: EOD is next calendar day at that time
            let nextDay = calendar.date(byAdding: .day, value: 1, to: appDayStart)!
            endOfAppDay = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: nextDay)!
        } else {
            // PM: EOD is today at that time
            endOfAppDay = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: appDayStart)!
        }

        let allTasksComplete = Set(tasks.map { $0.id }).isSubset(of: completedTaskIDs)
        return date >= endOfAppDay && !allTasksComplete
    }
} 