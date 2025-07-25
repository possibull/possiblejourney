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
        
        // Get the app day for the given date
        let appDayNumber = appDay(for: date)
        
        // If we're before the program starts or after it ends, no missed day
        if appDayNumber < 1 || appDayNumber > numberOfDays {
            print("DEBUG: Program.isDayMissed - appDayNumber \(appDayNumber) out of range [1, \(numberOfDays)], returning false")
            return false
        }
        
        // Calculate the end of the app day
        let endHour = calendar.component(.hour, from: endOfDayTime)
        let endMinute = calendar.component(.minute, from: endOfDayTime)
        
        // Calculate the start of the app day (calendar day)
        let appDayStart = calendar.date(byAdding: .day, value: appDayNumber - 1, to: calendar.startOfDay(for: startDate))!
        
        // Calculate the end of the app day based on EOD time
        let endOfAppDay: Date
        if endHour < 12 {
            // AM EOD: end of day is next calendar day at that time
            let nextDay = calendar.date(byAdding: .day, value: 1, to: appDayStart)!
            endOfAppDay = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: nextDay)!
        } else {
            // PM EOD: end of day is same calendar day at that time
            endOfAppDay = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: appDayStart)!
        }
        
        print("DEBUG: Program.isDayMissed - appDayNumber: \(appDayNumber), date: \(date), endOfAppDay: \(endOfAppDay), endHour: \(endHour), endMinute: \(endMinute)")
        
        // Check if we're past the end of the app day
        guard date >= endOfAppDay else {
            print("DEBUG: Program.isDayMissed - not past EOD yet, returning false")
            return false // Not past EOD yet
        }
        
        // Check if any tasks are incomplete
        let hasIncompleteTasks = tasks.contains { !completedTaskIDs.contains($0.id) }
        
        print("DEBUG: Program.isDayMissed - past EOD, hasIncompleteTasks: \(hasIncompleteTasks), returning \(hasIncompleteTasks)")
        return hasIncompleteTasks
    }
} 