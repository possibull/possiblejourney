import Foundation

struct DailyProgress: Codable {
    let id: UUID
    let date: Date
    let completedTaskIDs: [UUID]
} 