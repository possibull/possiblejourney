import Foundation

struct Task: Codable {
    let id: UUID
    let title: String
    let description: String?
} 