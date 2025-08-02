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

// MARK: - Theme-Aware View Modifiers (Fixed)
struct ThemeAwareBackground: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                colorScheme == .dark ?
                    // Simplified dark theme - single gradient
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black,
                            Color(red: 0.1, green: 0.05, blue: 0.15)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ) :
                    // Simplified light theme - single gradient
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.systemBackground),
                            Color.blue.opacity(0.02)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
            )
    }
}

struct ThemeAwareCard: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if colorScheme == .dark {
                        // Enhanced dark card with subtle gradient and glow
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.15, green: 0.15, blue: 0.18),
                                        Color(red: 0.12, green: 0.12, blue: 0.15)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.1),
                                                Color.clear
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    } else {
                        // Light card with standard styling
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                            )
                    }
                }
            )
            .shadow(
                color: colorScheme == .dark ? 
                    Color.black.opacity(0.4) : Color.black.opacity(0.05),
                radius: colorScheme == .dark ? 12 : 8,
                x: 0,
                y: colorScheme == .dark ? 6 : 4
            )
    }
}

struct ThemeAwareHeader: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if colorScheme == .dark {
                        // Enhanced dark header with subtle gradient
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.18, green: 0.18, blue: 0.22).opacity(0.8),
                                Color(red: 0.15, green: 0.15, blue: 0.18).opacity(0.6)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else {
                        Color(.systemGray6).opacity(1.0)
                    }
                }
            )
    }
}

struct ThemeAwareDivider: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(
                colorScheme == .dark ? 
                    Color.white.opacity(0.15) : Color.gray.opacity(0.3)
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
    
    func themeAwareHeader() -> some View {
        self.modifier(ThemeAwareHeader())
    }
    
    func themeAwareDivider() -> some View {
        self.modifier(ThemeAwareDivider())
    }
} 