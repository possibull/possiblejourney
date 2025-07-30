import Foundation

struct Task: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var description: String?
    
    init(id: UUID = UUID(), title: String, description: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
    }
} 