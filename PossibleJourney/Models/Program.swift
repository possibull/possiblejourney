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
        let endHour = calendar.component(.hour, from: endOfDayTime)
        let endMinute = calendar.component(.minute, from: endOfDayTime)
        var appDayToCheck = self.appDay(for: date)
        var appDayStart = calendar.date(byAdding: .day, value: appDayToCheck - 1, to: calendar.startOfDay(for: startDate))!
        var endOfAppDay: Date
        if endHour < 12 {
            // AM: EOD is next calendar day at that time
            let eod = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: calendar.date(byAdding: .day, value: 1, to: appDayStart)!)!
            if date < eod {
                appDayToCheck -= 1
                if appDayToCheck < 1 || appDayToCheck > numberOfDays { return false }
                appDayStart = calendar.date(byAdding: .day, value: appDayToCheck - 1, to: calendar.startOfDay(for: startDate))!
            }
            endOfAppDay = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: calendar.date(byAdding: .day, value: 1, to: appDayStart)!)!
        } else {
            // PM: EOD is today at that time
            endOfAppDay = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: appDayStart)!
        }
        if appDayToCheck < 1 || appDayToCheck > numberOfDays { return false }
        let missed = tasks.contains { !completedTaskIDs.contains($0.id) }
        return date >= endOfAppDay && missed
    }
} 