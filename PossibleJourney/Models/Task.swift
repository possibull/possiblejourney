import Foundation

// MARK: - TaskType Enum (TDD Green Phase)
enum TaskType: String, Codable, CaseIterable, Equatable {
    case growth = "growth"
    case maintenance = "maintenance"
    case recovery = "recovery"
}

struct Task: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var description: String?
    var requiresPhoto: Bool
    var taskType: TaskType
    
    init(id: UUID = UUID(), title: String, description: String? = nil, requiresPhoto: Bool = false, taskType: TaskType = .growth) {
        self.id = id
        self.title = title
        self.description = description
        self.requiresPhoto = requiresPhoto
        self.taskType = taskType
    }
} 