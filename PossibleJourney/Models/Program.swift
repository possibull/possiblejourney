import Foundation

struct Program: Codable {
    let id: UUID
    var startDate: Date
    var endOfDayTime: Date = Calendar.current.startOfDay(for: Date()) // Default 12:00AM
    var lastCompletedDay: Date? = nil // New property
    let templateID: UUID // Reference to the template this program was created from
    let customNumberOfDays: Int? // Custom number of days, nil means use template default
}

extension Program {
    /// Fetch the template for this program
    func template(using storage: ProgramTemplateStorage = ProgramTemplateStorage()) -> ProgramTemplate? {
        storage.get(by: templateID)
    }
    
    /// Computed property to get tasks from the template
    func tasks(using storage: ProgramTemplateStorage = ProgramTemplateStorage()) -> [Task] {
        template(using: storage)?.tasks ?? []
    }
    
    /// Computed property to get number of days from the template or custom value
    func numberOfDays(using storage: ProgramTemplateStorage = ProgramTemplateStorage()) -> Int {
        // Use custom number of days if specified, otherwise use template default
        if let customDays = customNumberOfDays {
            return customDays
        }
        return template(using: storage)?.defaultNumberOfDays ?? 0
    }
    
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
    
    /// Returns the date/time when the next app day is allowed to start, based on EOD and 12AM rules
    func nextAppDayBoundary(after date: Date) -> Date {
        let calendar = Calendar.current
        let endHour = calendar.component(.hour, from: endOfDayTime)
        let endMinute = calendar.component(.minute, from: endOfDayTime)
        let startOfDate = calendar.startOfDay(for: date)
        let eodBoundary: Date
        if endHour < 12 {
            // EOD is AM: next day boundary is at EOD (e.g., 2AM)
            let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDate)!
            eodBoundary = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: nextDay)!
        } else {
            // EOD is PM: end of day is same calendar day at that time
            eodBoundary = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: startOfDate)!
        }
        let midnightBoundary = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: startOfDate)!)
        // The next day becomes active after whichever is later: EOD or 12AM
        return max(eodBoundary, midnightBoundary)
    }
    
    func isDayMissed(for date: Date, completedTaskIDs: Set<UUID>) -> Bool {
        let calendar = Calendar.current
        let appDayNumber = appDay(for: date)
        if appDayNumber < 1 || appDayNumber > numberOfDays() {
            print("DEBUG: Program.isDayMissed - appDayNumber \(appDayNumber) out of range [1, \(numberOfDays())], returning false")
            return false
        }
        let endHour = calendar.component(.hour, from: endOfDayTime)
        let endMinute = calendar.component(.minute, from: endOfDayTime)
        let appDayStart = calendar.date(byAdding: .day, value: appDayNumber - 1, to: calendar.startOfDay(for: startDate))!
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
        guard date >= endOfAppDay else {
            print("DEBUG: Program.isDayMissed - not past EOD yet, returning false")
            return false
        }
        let hasIncompleteTasks = tasks().contains { !completedTaskIDs.contains($0.id) }
        print("DEBUG: Program.isDayMissed - past EOD, hasIncompleteTasks: \(hasIncompleteTasks), returning \(hasIncompleteTasks)")
        return hasIncompleteTasks
    }
    
    /// Returns true if the app can advance to the next day, based on EOD and midnight rules
    func canAdvanceToNextDay(currentDate: Date, lastCompletedDay: Date?) -> Bool {
        guard let lastCompleted = lastCompletedDay else { return false }
        let boundary = nextAppDayBoundary(after: lastCompleted)
        return currentDate >= boundary
    }
    
    /// Returns the next active day (date) based on lastCompletedDay and advancement rules
    func nextActiveDay(currentDate: Date) -> Date? {
        guard let lastCompleted = lastCompletedDay else { return startDate }
        let boundary = nextAppDayBoundary(after: lastCompleted)
        if currentDate >= boundary {
            // Next day is active
            return Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: lastCompleted))
        } else {
            // Still on last completed day
            return lastCompleted
        }
    }

    var currentAppDay: Date {
        let calendar = Calendar.current
        if let last = lastCompletedDay {
            return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: last))!
        } else {
            return calendar.startOfDay(for: startDate)
        }
    }
    
    /// Returns the EOD boundary for a given app day
    func endOfDay(for appDay: Date) -> Date {
        let calendar = Calendar.current
        let endHour = calendar.component(.hour, from: endOfDayTime)
        let endMinute = calendar.component(.minute, from: endOfDayTime)
        if endHour < 12 {
            // AM EOD: boundary is next day at EOD time
            let nextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: appDay))!
            return calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: nextDay)!
        } else {
            // PM EOD: boundary is same day at EOD time
            return calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: calendar.startOfDay(for: appDay))!
        }
    }
    
    /// Returns true if the current app day is missed (incomplete and past EOD)
    func isCurrentAppDayMissed(now: Date, completedTaskIDs: Set<UUID>) -> Bool {
        let appDay = currentAppDay
        let eod = endOfDay(for: appDay)
        let allComplete = tasks().allSatisfy { completedTaskIDs.contains($0.id) }
        return !allComplete && now >= eod
    }
    
    /// Returns true if the active day for the given current date is missed
    func isActiveDayMissed(currentDate: Date, completedTaskIDs: Set<UUID>) -> Bool {
        let activeDay = nextActiveDay(currentDate: currentDate) ?? startDate
        let eod = endOfDay(for: activeDay)
        let allComplete = tasks().allSatisfy { completedTaskIDs.contains($0.id) }
        return !allComplete && currentDate >= eod
    }
} 