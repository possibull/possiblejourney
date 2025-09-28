import Foundation

// MARK: - TaskType Enum (TDD Green Phase)
enum TaskType: String, Codable, CaseIterable, Equatable {
    case growth = "growth"
    case maintenance = "maintenance"
    case recovery = "recovery"
}

// MARK: - ProgressRule Enum (TDD Green Phase)
enum ProgressRule: Codable, Equatable {
    case deltaThreshold(minimumImprovement: Double)
    case countMin(minimumCount: Int)
    case booleanCondition(condition: String)
    case rollingWindow(targetCount: Int, windowDays: Int)
    case threshold(metricAlias: String, comparator: String, target: Double)
}

struct Task: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var description: String?
    var requiresPhoto: Bool
    var taskType: TaskType
    var progressRule: ProgressRule?
    var linkedMetricId: String?
    
    init(id: UUID = UUID(), title: String, description: String? = nil, requiresPhoto: Bool = false, taskType: TaskType = .growth, progressRule: ProgressRule? = nil, linkedMetricId: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.requiresPhoto = requiresPhoto
        self.taskType = taskType
        self.progressRule = progressRule
        self.linkedMetricId = linkedMetricId
    }
    
    // MARK: - Codable Implementation for Backward Compatibility
    enum CodingKeys: String, CodingKey {
        case id, title, description, requiresPhoto, taskType, progressRule, linkedMetricId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        requiresPhoto = try container.decodeIfPresent(Bool.self, forKey: .requiresPhoto) ?? false
        taskType = try container.decodeIfPresent(TaskType.self, forKey: .taskType) ?? .growth
        progressRule = try container.decodeIfPresent(ProgressRule.self, forKey: .progressRule)
        linkedMetricId = try container.decodeIfPresent(String.self, forKey: .linkedMetricId)
    }
} 