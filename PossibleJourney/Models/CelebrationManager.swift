import SwiftUI
import Foundation

enum CelebrationType: String, CaseIterable, Identifiable {
    case confetti = "confetti"
    case fireworks = "fireworks"
    case balloons = "balloons"
    case sparkles = "sparkles"
    case random = "random"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .confetti:
            return "Confetti"
        case .fireworks:
            return "Fireworks"
        case .balloons:
            return "Balloons"
        case .sparkles:
            return "Sparkles"
        case .random:
            return "Random"
        }
    }
    
    var icon: String {
        switch self {
        case .confetti:
            return "sparkles"
        case .fireworks:
            return "flame"
        case .balloons:
            return "balloon"
        case .sparkles:
            return "star.fill"
        case .random:
            return "dice"
        }
    }
}

class CelebrationManager: ObservableObject {
    @AppStorage("celebrationType") var celebrationType: CelebrationType = .confetti
    @AppStorage("celebrationEnabled") var celebrationEnabled: Bool = true
    
    func getRandomCelebrationType() -> CelebrationType {
        let types: [CelebrationType] = [.confetti, .fireworks, .balloons, .sparkles]
        return types.randomElement() ?? .confetti
    }
    
    func getCurrentCelebrationType() -> CelebrationType {
        if celebrationType == .random {
            return getRandomCelebrationType()
        }
        return celebrationType
    }
} 