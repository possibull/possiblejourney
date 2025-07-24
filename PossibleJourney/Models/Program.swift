import Foundation

struct Program: Codable {
    let id: UUID
    let startDate: Date
    let numberOfDays: Int
    var tasks: [Task]
    var endOfDayTime: Date = Calendar.current.startOfDay(for: Date()) // Default 12:00AM
} 