import SwiftUI
import Foundation

enum ThemeMode: String, CaseIterable, Codable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    case bea = "bea"
    case birthday = "birthday"
    
    var displayName: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .system:
            return "System"
        case .bea:
            return "Bea"
        case .birthday:
            return "Birthday"
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
        case .bea:
            return "heart.fill"
        case .birthday:
            return "birthday.cake.fill"
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
        case .bea:
            return .light
        case .birthday:
            return .light
        }
    }
    

}

// MARK: - Theme-Aware View Modifiers (Fixed)
struct ThemeAwareBackground: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if themeManager.currentTheme == .birthday {
                        // Birthday theme - festive pastel gradient with decorations
                        ZStack {
                            // Main gradient background
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.95, blue: 0.8), // Pastel yellow
                                    Color(red: 0.9, green: 0.95, blue: 1.0), // Pastel blue
                                    Color(red: 1.0, green: 0.9, blue: 0.95)  // Pastel pink
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            // Large "46" in background
                            Text("46")
                                .font(.system(size: 200, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.1))
                                .rotationEffect(.degrees(-15))
                                .offset(x: 50, y: -100)
                            
                            // Floating balloons
                            BirthdayBalloons()
                            
                            // Streamers
                            BirthdayStreamers()
                        }
                    } else if themeManager.currentTheme == .bea {
                        // Bea theme - pastel yellow to pastel blue gradient
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.98, blue: 0.8), // Pastel yellow
                                Color(red: 0.8, green: 0.9, blue: 1.0)  // Pastel blue
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else if colorScheme == .dark {
                        // Simplified dark theme - single gradient
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black,
                                Color(red: 0.1, green: 0.05, blue: 0.15)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else {
                        // Simplified light theme - single gradient
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(.systemBackground),
                                Color.blue.opacity(0.02)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
            )
    }
}

struct ThemeAwareCard: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if themeManager.currentTheme == .birthday {
                        // Birthday theme - festive card with confetti
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.95))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 1.0, green: 0.8, blue: 0.9), // Pink
                                                    Color(red: 0.8, green: 0.9, blue: 1.0), // Blue
                                                    Color(red: 1.0, green: 0.95, blue: 0.7)  // Yellow
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3
                                        )
                                )
                            
                            // Confetti decoration
                            BirthdayConfetti()
                        }
                    } else if themeManager.currentTheme == .bea {
                        // Bea theme - soft pastel card
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.9))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 1.0, green: 0.98, blue: 0.8), // Pastel yellow
                                                Color(red: 0.8, green: 0.9, blue: 1.0)  // Pastel blue
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                    } else if colorScheme == .dark {
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
                color: themeManager.currentTheme == .birthday ? 
                    Color.black.opacity(0.15) :
                    (themeManager.currentTheme == .bea ? 
                        Color.black.opacity(0.1) : 
                        (colorScheme == .dark ? Color.black.opacity(0.4) : Color.black.opacity(0.05))),
                radius: themeManager.currentTheme == .birthday ? 8 : 
                    (themeManager.currentTheme == .bea ? 6 : (colorScheme == .dark ? 12 : 8)),
                x: 0,
                y: themeManager.currentTheme == .birthday ? 4 : 
                    (themeManager.currentTheme == .bea ? 3 : (colorScheme == .dark ? 6 : 4))
            )
    }
}

struct ThemeAwareHeader: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if themeManager.currentTheme == .birthday {
                        // Birthday theme - festive header with ribbon
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.8, blue: 0.9).opacity(0.9), // Pink
                                    Color(red: 0.8, green: 0.9, blue: 1.0).opacity(0.7), // Blue
                                    Color(red: 1.0, green: 0.95, blue: 0.7).opacity(0.8)  // Yellow
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            // Birthday ribbon decoration
                            BirthdayRibbon()
                        }
                    } else if themeManager.currentTheme == .bea {
                        // Bea theme - soft pastel header
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.98, blue: 0.8).opacity(0.8), // Pastel yellow
                                Color(red: 0.8, green: 0.9, blue: 1.0).opacity(0.6)  // Pastel blue
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else if colorScheme == .dark {
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
    @EnvironmentObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(
                themeManager.currentTheme == .birthday ? 
                    Color(red: 1.0, green: 0.8, blue: 0.9).opacity(0.7) : // Pink
                    (themeManager.currentTheme == .bea ? 
                        Color(red: 0.8, green: 0.9, blue: 1.0).opacity(0.6) : // Pastel blue
                        (colorScheme == .dark ? 
                            Color.white.opacity(0.15) : Color.gray.opacity(0.3)))
            )
    }
}

// MARK: - Birthday Theme Decorations
struct BirthdayBalloons: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Balloon 1 - Pink
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.8, blue: 0.9), // Light pink
                            Color(red: 0.9, green: 0.6, blue: 0.8)  // Darker pink
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 40, height: 50)
                .offset(x: -150, y: -200 + animationOffset)
                .overlay(
                    // Balloon string
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2, height: 60)
                        .offset(y: 25)
                )
            
            // Balloon 2 - Blue
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.8, green: 0.9, blue: 1.0), // Light blue
                            Color(red: 0.6, green: 0.8, blue: 0.9)  // Darker blue
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 35, height: 45)
                .offset(x: 120, y: -180 + animationOffset * 0.8)
                .overlay(
                    // Balloon string
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2, height: 50)
                        .offset(y: 22)
                )
            
            // Balloon 3 - Yellow
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.95, blue: 0.7), // Light yellow
                            Color(red: 0.9, green: 0.85, blue: 0.6)  // Darker yellow
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 45, height: 55)
                .offset(x: 180, y: -220 + animationOffset * 1.2)
                .overlay(
                    // Balloon string
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2, height: 70)
                        .offset(y: 27)
                )
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
            ) {
                animationOffset = 20
            }
        }
    }
}

struct BirthdayStreamers: View {
    @State private var streamerOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Streamer 1 - Pink
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.8, blue: 0.9),
                            Color(red: 0.9, green: 0.6, blue: 0.8)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 8, height: 200)
                .rotationEffect(.degrees(45))
                .offset(x: -100, y: -300 + streamerOffset)
            
            // Streamer 2 - Blue
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.8, green: 0.9, blue: 1.0),
                            Color(red: 0.6, green: 0.8, blue: 0.9)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 6, height: 180)
                .rotationEffect(.degrees(-30))
                .offset(x: 150, y: -280 + streamerOffset * 0.7)
            
            // Streamer 3 - Yellow
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.95, blue: 0.7),
                            Color(red: 0.9, green: 0.85, blue: 0.6)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 10, height: 220)
                .rotationEffect(.degrees(60))
                .offset(x: 80, y: -320 + streamerOffset * 1.3)
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 4)
                    .repeatForever(autoreverses: true)
            ) {
                streamerOffset = 30
            }
        }
    }
}

struct BirthdayConfetti: View {
    @State private var confettiOffset: CGFloat = 0
    @State private var confettiRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Confetti pieces
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(
                        [Color(red: 1.0, green: 0.8, blue: 0.9), // Pink
                         Color(red: 0.8, green: 0.9, blue: 1.0), // Blue
                         Color(red: 1.0, green: 0.95, blue: 0.7)][index % 3] // Yellow
                    )
                    .frame(width: 4, height: 4)
                    .offset(
                        x: CGFloat(index * 20 - 80) + confettiOffset * 0.5,
                        y: CGFloat(index * 15 - 60) + confettiOffset * 0.3
                    )
                    .rotationEffect(.degrees(confettiRotation + Double(index * 45)))
            }
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
            ) {
                confettiOffset = 10
                confettiRotation = 360
            }
        }
    }
}

struct BirthdayRibbon: View {
    @State private var ribbonOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Ribbon 1 - Pink
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.8, blue: 0.9),
                            Color(red: 0.9, green: 0.6, blue: 0.8)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 120, height: 6)
                .rotationEffect(.degrees(-15))
                .offset(x: -50, y: -20 + ribbonOffset)
            
            // Ribbon 2 - Blue
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.8, green: 0.9, blue: 1.0),
                            Color(red: 0.6, green: 0.8, blue: 0.9)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 100, height: 5)
                .rotationEffect(.degrees(20))
                .offset(x: 60, y: -15 + ribbonOffset * 0.8)
            
            // Ribbon 3 - Yellow
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.95, blue: 0.7),
                            Color(red: 0.9, green: 0.85, blue: 0.6)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 80, height: 4)
                .rotationEffect(.degrees(-10))
                .offset(x: 0, y: -25 + ribbonOffset * 1.2)
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
            ) {
                ribbonOffset = 5
            }
        }
    }
}

struct BirthdayCakeBackground: View {
    @State private var cakeScale: CGFloat = 1.0
    @State private var cakeRotation: Double = 0
    
    var body: some View {
        // Debug print to confirm this view is being rendered
        let _ = print("🎂 BirthdayCakeBackground is being rendered!")
        ZStack {
            // Debug background to make sure the view is visible
            Color.red.opacity(0.3)
                .frame(width: 300, height: 300)
                .border(Color.red, width: 3)
            // Birthday cake with "46" on top
            VStack(spacing: 0) {
                // Cake top layer (smallest)
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.9, blue: 0.8), // Cream
                                Color(red: 0.9, green: 0.8, blue: 0.7)  // Light brown
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 200, height: 50)
                    .overlay(
                        // "46" on top of cake
                        Text("46")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)
                    )
                
                // Cake middle layer
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.8, blue: 0.9), // Pink
                                Color(red: 0.9, green: 0.7, blue: 0.8)  // Darker pink
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 220, height: 55)
                    .overlay(
                        // Sprinkles
                        HStack(spacing: 4) {
                            ForEach(0..<5, id: \.self) { _ in
                                Circle()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: 3, height: 3)
                            }
                        }
                        .offset(y: 5)
                    )
                
                // Cake bottom layer (largest)
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.8, green: 0.9, blue: 1.0), // Blue
                                Color(red: 0.7, green: 0.8, blue: 0.9)  // Darker blue
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 240, height: 60)
                    .overlay(
                        // More sprinkles
                        HStack(spacing: 6) {
                            ForEach(0..<6, id: \.self) { _ in
                                Circle()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: 4, height: 4)
                            }
                        }
                        .offset(y: 8)
                    )
                
                // Cake plate
                Ellipse()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.9),
                                Color.gray.opacity(0.3)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 260, height: 25)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
            }
            .scaleEffect(cakeScale)
            .rotationEffect(.degrees(cakeRotation))
            .offset(x: 0, y: 0) // Center position
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .onAppear {
            // Gentle floating animation
            withAnimation(
                Animation.easeInOut(duration: 4)
                    .repeatForever(autoreverses: true)
            ) {
                cakeScale = 1.05
                cakeRotation = 2
            }
        }
    }
}

// MARK: - Birthday Theme Icons
extension ThemeManager {
    func birthdayIcon(for systemIcon: String) -> String {
        switch systemIcon {
        case "target":
            return "birthday.cake.fill"
        case "magnifyingglass":
            return "gift.fill"
        case "gear", "gearshape.fill":
            return "party.popper.fill"
        case "list.bullet":
            return "balloon.fill"
        case "play.fill":
            return "gift.circle.fill"
        case "camera.fill", "camera":
            return "camera.circle.fill"
        case "photo.fill", "photo":
            return "camera.circle.fill"
        case "bell":
            return "bell.badge.fill"
        case "calendar":
            return "calendar.badge.plus"
        case "plus.circle.fill":
            return "plus.circle.fill"
        case "checkmark", "checkmark.circle.fill":
            return "checkmark.circle.fill"
        case "circle.fill", "circle":
            return "circle.fill"
        case "chevron.up", "chevron.down":
            return systemIcon
        case "line.3.horizontal":
            return "line.3.horizontal"
        case "exclamationmark.triangle.fill":
            return "exclamationmark.triangle.fill"
        case "trash.fill", "trash.circle.fill":
            return "trash.circle.fill"
        case "arrow.clockwise":
            return "arrow.clockwise"
        case "info.circle.fill":
            return "info.circle.fill"
        case "ladybug.fill":
            return "ladybug.fill"
        case "terminal.fill":
            return "terminal.fill"
        case "paintbrush.fill":
            return "paintbrush.fill"
        case "arrow.up.circle.fill":
            return "arrow.up.circle.fill"
        case "xmark.circle.fill":
            return "xmark.circle.fill"
        default:
            return systemIcon
        }
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
    
    func birthdayIcon(_ systemIcon: String) -> some View {
        self.modifier(BirthdayIconModifier(systemIcon: systemIcon))
    }
}

struct BirthdayIconModifier: ViewModifier {
    let systemIcon: String
    @EnvironmentObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        if themeManager.currentTheme == .birthday {
            Image(systemName: themeManager.birthdayIcon(for: systemIcon))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.8, blue: 0.9), // Pink
                            Color(red: 0.8, green: 0.9, blue: 1.0), // Blue
                            Color(red: 1.0, green: 0.95, blue: 0.7)  // Yellow
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        } else {
            content
        }
    }
} 