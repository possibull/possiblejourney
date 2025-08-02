import SwiftUI
import Foundation

enum ThemeMode: String, CaseIterable, Codable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .system:
            return "System"
        }
    }
    
    var iconName: String {
        switch self {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .system:
            return "gear"
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: ThemeMode
    
    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? ThemeMode.system.rawValue
        self.currentTheme = ThemeMode(rawValue: savedTheme) ?? .system
    }
    
    func changeTheme(to theme: ThemeMode) {
        self.currentTheme = theme
        // Persist immediately
        UserDefaults.standard.set(theme.rawValue, forKey: "selectedTheme")
    }
    
    var colorScheme: ColorScheme? {
        switch currentTheme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
    

}

// MARK: - Theme-Aware View Modifiers
struct ThemeAwareBackground: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color.blue.opacity(themeManager.colorScheme == .dark ? 0.1 : 0.05),
                        Color.purple.opacity(themeManager.colorScheme == .dark ? 0.05 : 0.03)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

struct ThemeAwareCard: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(
                color: themeManager.colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.05),
                radius: 8,
                x: 0,
                y: 4
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        themeManager.colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1),
                        lineWidth: 1
                    )
            )
    }
}

extension View {
    func themeAwareBackground() -> some View {
        self.modifier(ThemeAwareBackground())
    }
    
    func themeAwareCard() -> some View {
        self.modifier(ThemeAwareCard())
    }
} 