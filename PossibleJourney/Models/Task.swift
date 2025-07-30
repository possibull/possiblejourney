import Foundation

struct Task: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var description: String?
    var requiresPhoto: Bool
    
    init(id: UUID = UUID(), title: String, description: String? = nil, requiresPhoto: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.requiresPhoto = requiresPhoto
    }
} 