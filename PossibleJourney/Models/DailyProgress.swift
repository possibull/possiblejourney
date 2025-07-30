import Foundation

struct DailyProgress: Codable, Identifiable {
    let id: UUID
    let date: Date
    var completedTaskIDs: Set<UUID>
    var photoURLs: [UUID: URL] // Task ID -> Photo URL mapping
    var isMissed: Bool // Track if this day was missed
    
    init(id: UUID = UUID(), date: Date, completedTaskIDs: Set<UUID> = [], photoURLs: [UUID: URL] = [:], isMissed: Bool = true) {
        self.id = id
        self.date = date
        self.completedTaskIDs = completedTaskIDs
        self.photoURLs = photoURLs
        self.isMissed = isMissed
    }
} 