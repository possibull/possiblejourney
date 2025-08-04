import SwiftUI
import Foundation

enum ThemeMode: String, CaseIterable, Codable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    case bea = "bea"
    case birthday = "birthday"
    case usa = "usa"
    case lasVegas = "lasVegas"
    
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
        case .usa:
            return "USA"
        case .lasVegas:
            return "Las Vegas"
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
        case .usa:
            return "flag.fill"
        case .lasVegas:
            return "sparkles"
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: ThemeMode
    @Published var shouldShowBirthdayCake: Bool = false
    @Published var selectedDate: Date? = nil
    
    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? ThemeMode.system.rawValue
        self.currentTheme = ThemeMode(rawValue: savedTheme) ?? .system
        
        // Check if it's August 4th, 2025 and user is on Bea theme - activate birthday theme
        checkAndActivateBirthdayTheme()
    }
    
    func changeTheme(to theme: ThemeMode) {
        print("🎨 changeTheme called with theme: \(theme), current theme: \(currentTheme)")
        
        // Special logic for August 4th, 2025: Bea theme becomes birthday theme
        if theme == .bea {
            let calendar = Calendar.current
            
            // Use selected date as the "current" date for the app, fall back to real current date
            let effectiveDate = self.selectedDate ?? Date()
            let effectiveComponents = calendar.dateComponents([.year, .month, .day], from: effectiveDate)
            
            print("🎨 Bea theme selected - checking effective date: \(effectiveComponents)")
            print("🎨 Using selected date as current: \(self.selectedDate != nil)")
            print("🎨 Is effective date August 4th, 2025? \(effectiveComponents.year == 2025 && effectiveComponents.month == 8 && effectiveComponents.day == 4)")
            
            // Check if effective date is August 4th, 2025
            if effectiveComponents.year == 2025 && effectiveComponents.month == 8 && effectiveComponents.day == 4 {
                print("🎂 Effective date is August 4th, 2025! Bea theme request redirected to Birthday theme!")
                self.currentTheme = .birthday
                UserDefaults.standard.set(ThemeMode.birthday.rawValue, forKey: "selectedTheme")
                
                // Trigger birthday cake popup
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.shouldShowBirthdayCake = true
                }
                return
            }
            
            print("🎨 Bea theme selected but effective date is not August 4th - proceeding normally")
        }
        
        self.currentTheme = theme
        // Persist immediately
        UserDefaults.standard.set(theme.rawValue, forKey: "selectedTheme")
        
        // Check for birthday theme activation when changing to Bea theme (for other dates)
        if theme == .bea {
            checkAndActivateBirthdayTheme()
        }
        
        // Trigger birthday cake popup when birthday theme is activated
        if theme == .birthday {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.shouldShowBirthdayCake = true
            }
        }
    }
    
    private func checkAndActivateBirthdayTheme() {
        checkAndActivateBirthdayTheme(for: Date())
    }
    
    private func checkAndActivateBirthdayTheme(for date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        print("🔍 ThemeManager Birthday Check - Date: \(date), Components: \(components)")
        
        // Check if it's August 4th, 2025
        if components.year == 2025 && components.month == 8 && components.day == 4 {
            print("🎂 August 4th, 2025 detected in ThemeManager! Current theme: \(self.currentTheme)")
            
            // If user is currently on Bea theme, activate birthday theme
            if self.currentTheme == .bea {
                print("🎂 August 4th, 2025 detected! Activating Birthday theme for Bea user!")
                DispatchQueue.main.async {
                    self.currentTheme = .birthday
                    UserDefaults.standard.set(ThemeMode.birthday.rawValue, forKey: "selectedTheme")
                    
                    // Trigger birthday cake popup when automatically activated
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.shouldShowBirthdayCake = true
                    }
                }
            } else {
                print("🎂 August 4th detected but current theme is \(self.currentTheme), not .bea")
            }
        } else {
            print("🔍 Not August 4th, 2025 - Year: \(components.year ?? 0), Month: \(components.month ?? 0), Day: \(components.day ?? 0)")
        }
    }
    
    func resetBirthdayCakeFlag() {
        DispatchQueue.main.async {
            self.shouldShowBirthdayCake = false
        }
    }
    
    func setSelectedDate(_ date: Date?) {
        self.selectedDate = date
        print("🎨 ThemeManager selected date set to: \(date?.description ?? "nil")")
    }
    
    // Get the effective current date for the app (selected date if available, otherwise real current date)
    func getEffectiveCurrentDate() -> Date {
        return self.selectedDate ?? Date()
    }
    

    

    
    // Public method for calendar view to check birthday activation with selected date
    func checkBirthdayActivationForDate(_ date: Date) {
        print("🎂 ThemeManager.checkBirthdayActivationForDate called with date: \(date)")
        checkAndActivateBirthdayTheme(for: date)
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
        case .usa:
            return .light
        case .lasVegas:
            return .dark
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
                        // Bea theme - pastel yellow to pastel blue to pastel purple gradient
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.98, blue: 0.8), // Pastel yellow
                                Color(red: 0.8, green: 0.9, blue: 1.0), // Pastel blue
                                Color(red: 0.9, green: 0.8, blue: 1.0)  // Pastel purple
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else if themeManager.currentTheme == .usa {
                        // USA theme - red, white, and blue gradient with stars
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.8, green: 0.1, blue: 0.2), // Red
                                    Color.white,
                                    Color(red: 0.1, green: 0.3, blue: 0.8)  // Blue
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            
                            // Stars pattern
                            USAPattern()
                        }
                    } else if themeManager.currentTheme == .lasVegas {
                        // Las Vegas theme - authentic sign colors: yellow, white, red, blue
                        ZStack {
                            // Dark night sky gradient inspired by the sign's backdrop
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.02, green: 0.02, blue: 0.08), // Deep night black
                                    Color(red: 0.05, green: 0.05, blue: 0.12), // Dark blue night
                                    Color(red: 0.08, green: 0.08, blue: 0.15)  // Midnight blue
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            
                            // Fireworks with authentic sign colors
                            LasVegasFireworks()
                            
                            // Casino landmarks with sign colors
                            LasVegasLandmarks()
                            
                            // Neon lights matching the sign
                            LasVegasNeonLights()
                        }
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
                    } else if themeManager.currentTheme == .usa {
                        // USA theme - patriotic card with stripes
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.95))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 0.8, green: 0.1, blue: 0.2), // Red
                                                    Color.white,
                                                    Color(red: 0.1, green: 0.3, blue: 0.8)  // Blue
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3
                                        )
                                )
                            
                            // USA stripes pattern
                            USAStripes()
                        }
                    } else if themeManager.currentTheme == .lasVegas {
                        // Las Vegas theme - authentic sign colors card
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.9))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 1.0, green: 1.0, blue: 0.0), // Yellow neon (sign bulbs)
                                                    Color(red: 1.0, green: 1.0, blue: 1.0), // White neon (silver dollars)
                                                    Color(red: 1.0, green: 0.0, blue: 0.0), // Red neon (letters/star)
                                                    Color(red: 0.0, green: 0.5, blue: 1.0)  // Blue (text)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3
                                        )
                                )
                            
                            // Casino elements with sign colors
                            LasVegasCardElements()
                        }
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
                    } else if themeManager.currentTheme == .lasVegas {
                        // Las Vegas theme - authentic sign colors header
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 1.0, blue: 0.0).opacity(0.9), // Yellow neon (sign bulbs)
                                Color(red: 1.0, green: 1.0, blue: 1.0).opacity(0.8), // White neon (silver dollars)
                                Color(red: 1.0, green: 0.0, blue: 0.0).opacity(0.7), // Red neon (letters/star)
                                Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.6)  // Blue (text)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
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
                    (themeManager.currentTheme == .lasVegas ?
                    Color(red: 1.0, green: 1.0, blue: 0.0).opacity(0.8) : // Yellow neon (sign bulbs)
                    (colorScheme == .dark ? 
                            Color.white.opacity(0.15) : Color.gray.opacity(0.3))))
            )
    }
}

// MARK: - Birthday Theme Decorations
struct BirthdayBalloons: View {
    @State private var balloon1Offset: CGFloat = 1200
    @State private var balloon2Offset: CGFloat = 1300
    @State private var balloon3Offset: CGFloat = 1400
    @State private var balloon4Offset: CGFloat = 1500
    @State private var balloon5Offset: CGFloat = 1600
    @State private var balloon6Offset: CGFloat = 1700
    @State private var balloon7Offset: CGFloat = 1800
    @State private var balloon8Offset: CGFloat = 1900
    @State private var balloon9Offset: CGFloat = 2000
    @State private var balloon10Offset: CGFloat = 2100
    @State private var balloon11Offset: CGFloat = 2200
    @State private var balloon12Offset: CGFloat = 2300
    @State private var balloon13Offset: CGFloat = 2400
    @State private var balloon14Offset: CGFloat = 2500
    @State private var balloon15Offset: CGFloat = 2600
    @State private var rotationAngle: Double = 0
    @State private var scaleEffect: CGFloat = 1.0
    @State private var sparkleOpacity: Double = 0.3
    @State private var balloon1Opacity: Double = 1.0
    @State private var balloon2Opacity: Double = 1.0
    @State private var balloon3Opacity: Double = 1.0
    @State private var balloon4Opacity: Double = 1.0
    @State private var balloon5Opacity: Double = 1.0
    @State private var balloon6Opacity: Double = 1.0
    @State private var balloon7Opacity: Double = 1.0
    @State private var balloon8Opacity: Double = 1.0
    @State private var balloon9Opacity: Double = 1.0
    @State private var balloon10Opacity: Double = 1.0
    @State private var balloon11Opacity: Double = 1.0
    @State private var balloon12Opacity: Double = 1.0
    @State private var balloon13Opacity: Double = 1.0
    @State private var balloon14Opacity: Double = 1.0
    @State private var balloon15Opacity: Double = 1.0
    
    var body: some View {
        GeometryReader { geometry in
        ZStack {
                // Balloon 1 - Pink with sparkles
                ZStack {
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
                        .frame(width: 60, height: 75)
                .overlay(
                            // Balloon string - pointing down
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                                .frame(width: 2, height: 80)
                                .offset(y: 37)
                        )
                        .overlay(
                            // Sparkles
                            ForEach(0..<3) { i in
                                Image(systemName: "sparkle")
                                    .foregroundColor(.white.opacity(sparkleOpacity))
                                    .font(.system(size: 12))
                                    .offset(
                                        x: CGFloat.random(in: -20...20),
                                        y: CGFloat.random(in: -25...25)
                                    )
                            }
                        )
                        .offset(x: -80, y: balloon1Offset)
                        .scaleEffect(scaleEffect)
                        .rotationEffect(.degrees(rotationAngle * 0.5))
                        .opacity(balloon1Opacity)
                    
                    // Balloon 2 - Blue with shimmer
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
                        .frame(width: 50, height: 65)
                .overlay(
                            // Balloon string - pointing down
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                                .frame(width: 2, height: 70)
                                .offset(y: 32)
                        )
                        .overlay(
                            // Shimmer effect
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.6),
                                            Color.clear
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 25, height: 30)
                                .offset(x: -8, y: -15)
                                .rotationEffect(.degrees(45))
                        )
                        .offset(x: 80, y: balloon2Offset)
                        .scaleEffect(scaleEffect * 0.9)
                        .rotationEffect(.degrees(-rotationAngle * 0.3))
                        .opacity(balloon2Opacity)
                    
                    // Balloon 3 - Yellow with polka dots
                    ZStack {
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
                            .frame(width: 70, height: 85)
                        
                        // Polka dots
                        ForEach(0..<4) { i in
                            Circle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 8, height: 8)
                                .offset(
                                    x: CGFloat.random(in: -20...20),
                                    y: CGFloat.random(in: -25...25)
                                )
                        }
                    }
                .overlay(
                        // Balloon string - pointing down
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 2, height: 90)
                            .offset(y: 42)
                    )
                    .offset(x: 0, y: balloon3Offset)
                    .scaleEffect(scaleEffect * 1.1)
                    .rotationEffect(.degrees(rotationAngle * 0.7))
                    .opacity(balloon3Opacity)
                    
                    // Balloon 4 - Purple with stars
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.9, green: 0.8, blue: 1.0), // Light purple
                                        Color(red: 0.7, green: 0.6, blue: 0.9)  // Darker purple
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 55, height: 70)
                        
                        // Stars
                        ForEach(0..<3) { i in
                            Image(systemName: "star.fill")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.system(size: 8))
                                .offset(
                                    x: CGFloat.random(in: -15...15),
                                    y: CGFloat.random(in: -20...20)
                                )
                        }
                    }
                    .overlay(
                        // Balloon string - pointing down
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 2, height: 75)
                            .offset(y: 35)
                    )
                    .offset(x: -120, y: balloon4Offset)
                    .scaleEffect(scaleEffect * 0.95)
                    .rotationEffect(.degrees(-rotationAngle * 0.4))
                    .opacity(balloon4Opacity)
                    
                    // Balloon 5 - Green with stripes
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.8, green: 1.0, blue: 0.8), // Light green
                                        Color(red: 0.6, green: 0.9, blue: 0.6)  // Darker green
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 65, height: 80)
                        
                        // Stripes
                        ForEach(0..<3) { i in
                            Rectangle()
                                .fill(Color.white.opacity(0.7))
                                .frame(width: 4, height: 25)
                                .offset(
                                    x: CGFloat.random(in: -15...15),
                                    y: CGFloat.random(in: -20...20)
                                )
                        }
                    }
                    .overlay(
                        // Balloon string - pointing down
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 2, height: 85)
                            .offset(y: 40)
                    )
                    .offset(x: 120, y: balloon5Offset)
                    .scaleEffect(scaleEffect * 1.05)
                    .rotationEffect(.degrees(rotationAngle * 0.6))
                    .opacity(balloon5Opacity)
                    
                    // Balloon 6 - Orange with confetti
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.9, blue: 0.7), // Light orange
                                        Color(red: 0.9, green: 0.7, blue: 0.5)  // Darker orange
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 45, height: 60)
                        
                        // Confetti pieces
                        ForEach(0..<5) { i in
                            Rectangle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 3, height: 6)
                                .rotationEffect(.degrees(Double.random(in: 0...360)))
                                .offset(
                                    x: CGFloat.random(in: -15...15),
                                    y: CGFloat.random(in: -18...18)
                                )
                        }
                    }
                    .overlay(
                        // Balloon string - pointing down
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2, height: 70)
                            .offset(y: 30)
                    )
                    .offset(x: -40, y: balloon6Offset)
                    .scaleEffect(scaleEffect * 0.88)
                    .rotationEffect(.degrees(-rotationAngle * 0.2))
                    .opacity(balloon6Opacity)
                    
                    // Balloon 7 - Teal with dots
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.7, green: 0.9, blue: 0.9), // Light teal
                                        Color(red: 0.5, green: 0.8, blue: 0.8)  // Darker teal
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 50, height: 65)
                        
                        // Dots
                        ForEach(0..<4) { i in
                            Circle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 5, height: 5)
                                .offset(
                                    x: CGFloat.random(in: -12...12),
                                    y: CGFloat.random(in: -15...15)
                                )
                        }
                    }
                    .overlay(
                        // Balloon string - pointing down
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 2, height: 72)
                            .offset(y: 32)
                    )
                    .offset(x: 80, y: balloon7Offset)
                    .scaleEffect(scaleEffect * 0.92)
                    .rotationEffect(.degrees(rotationAngle * 0.3))
                    .opacity(balloon7Opacity)
                    
                    // Balloon 8 - Magenta with hearts
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.7, blue: 0.9), // Light magenta
                                        Color(red: 0.8, green: 0.5, blue: 0.8)  // Darker magenta
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 58, height: 73)
                        
                        // Hearts
                        ForEach(0..<2) { i in
                            Image(systemName: "heart.fill")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.system(size: 10))
                                .offset(
                                    x: CGFloat.random(in: -15...15),
                                    y: CGFloat.random(in: -18...18)
                                )
                        }
                    }
                    .overlay(
                        // Balloon string - pointing down
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 2, height: 78)
                            .offset(y: 36)
                    )
                    .offset(x: -80, y: balloon8Offset)
                    .scaleEffect(scaleEffect * 1.02)
                    .rotationEffect(.degrees(-rotationAngle * 0.5))
                    .opacity(balloon8Opacity)
                    
                    // Balloon 9 - Lime with zigzags
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.8, green: 1.0, blue: 0.6), // Light lime
                                        Color(red: 0.6, green: 0.9, blue: 0.4)  // Darker lime
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 52, height: 67)
                        
                        // Zigzag pattern
                        ForEach(0..<3) { i in
                            Path { path in
                                path.move(to: CGPoint(x: -8, y: -10))
                                path.addLine(to: CGPoint(x: 8, y: -5))
                                path.addLine(to: CGPoint(x: -8, y: 0))
                                path.addLine(to: CGPoint(x: 8, y: 5))
                                path.addLine(to: CGPoint(x: -8, y: 10))
                            }
                            .stroke(Color.white.opacity(0.8), lineWidth: 2)
                            .offset(
                                x: CGFloat.random(in: -10...10),
                                y: CGFloat.random(in: -12...12)
                            )
                        }
                    }
                    .overlay(
                        // Balloon string - pointing down
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 2, height: 74)
                            .offset(y: 33)
                    )
                    .offset(x: 60, y: balloon9Offset)
                    .scaleEffect(scaleEffect * 0.98)
                    .rotationEffect(.degrees(rotationAngle * 0.4))
                    .opacity(balloon9Opacity)
                    
                    // Balloon 10 - Coral with waves
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.8, blue: 0.8), // Light coral
                                        Color(red: 0.9, green: 0.6, blue: 0.6)  // Darker coral
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 48, height: 63)
                        
                        // Wave pattern
                        ForEach(0..<2) { i in
                            Path { path in
                                path.move(to: CGPoint(x: -10, y: -8))
                                path.addCurve(to: CGPoint(x: 10, y: -8), control1: CGPoint(x: -5, y: -12), control2: CGPoint(x: 5, y: -4))
                                path.addCurve(to: CGPoint(x: -10, y: 8), control1: CGPoint(x: 5, y: 12), control2: CGPoint(x: -5, y: 4))
                            }
                            .stroke(Color.white.opacity(0.8), lineWidth: 2)
                            .offset(
                                x: CGFloat.random(in: -8...8),
                                y: CGFloat.random(in: -10...10)
                            )
                        }
                    }
                    .overlay(
                        // Balloon string - pointing down
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 2, height: 70)
                            .offset(y: 31)
                    )
                    .offset(x: -60, y: balloon10Offset)
                    .scaleEffect(scaleEffect * 0.94)
                    .rotationEffect(.degrees(-rotationAngle * 0.3))
                    .opacity(balloon10Opacity)
                    
                    // Balloon 11 - Lavender with moons
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.9, green: 0.8, blue: 1.0), // Light lavender
                                        Color(red: 0.7, green: 0.6, blue: 0.9)  // Darker lavender
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 54, height: 69)
                        
                        // Moons
                        ForEach(0..<2) { i in
                            Image(systemName: "moon.fill")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.system(size: 9))
                                .offset(
                                    x: CGFloat.random(in: -12...12),
                                    y: CGFloat.random(in: -15...15)
                                )
                        }
                    }
                    .overlay(
                        // Balloon string - pointing down
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 2, height: 76)
                            .offset(y: 34)
                    )
                    .offset(x: 100, y: balloon11Offset)
                    .scaleEffect(scaleEffect * 1.03)
                    .rotationEffect(.degrees(rotationAngle * 0.5))
                    .opacity(balloon11Opacity)
                    
                    // Balloon 12 - Mint with diamonds
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.7, green: 1.0, blue: 0.9), // Light mint
                                        Color(red: 0.5, green: 0.8, blue: 0.7)  // Darker mint
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 56, height: 71)
                        
                        // Diamonds
                        ForEach(0..<3) { i in
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: -6))
                                path.addLine(to: CGPoint(x: 4, y: 0))
                                path.addLine(to: CGPoint(x: 0, y: 6))
                                path.addLine(to: CGPoint(x: -4, y: 0))
                                path.closeSubpath()
                            }
                            .fill(Color.white.opacity(0.8))
                            .offset(
                                x: CGFloat.random(in: -10...10),
                                y: CGFloat.random(in: -12...12)
                            )
                        }
                    }
                    .overlay(
                        // Balloon string - pointing down
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 2, height: 78)
                            .offset(y: 35)
                    )
                    .offset(x: -100, y: balloon12Offset)
                    .scaleEffect(scaleEffect * 1.04)
                    .rotationEffect(.degrees(-rotationAngle * 0.6))
                    .opacity(balloon12Opacity)
                    
                    // Balloon 13 - Peach with circles
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.9, blue: 0.8), // Light peach
                                        Color(red: 0.9, green: 0.7, blue: 0.6)  // Darker peach
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 47, height: 62)
                        
                        // Circles
                        ForEach(0..<4) { i in
                            Circle()
                                .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                                .frame(width: 8, height: 8)
                                .offset(
                                    x: CGFloat.random(in: -12...12),
                                    y: CGFloat.random(in: -15...15)
                                )
                        }
                    }
                    .overlay(
                        // Balloon string - pointing down
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 2, height: 69)
                            .offset(y: 30)
                    )
                    .offset(x: 40, y: balloon13Offset)
                    .scaleEffect(scaleEffect * 0.96)
                    .rotationEffect(.degrees(rotationAngle * 0.2))
                    .opacity(balloon13Opacity)
                    
                    // Balloon 14 - Sky blue with triangles
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.8, green: 0.9, blue: 1.0), // Light sky blue
                                        Color(red: 0.6, green: 0.8, blue: 0.9)  // Darker sky blue
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 53, height: 68)
                        
                        // Triangles
                        ForEach(0..<3) { i in
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: -5))
                                path.addLine(to: CGPoint(x: 4, y: 3))
                                path.addLine(to: CGPoint(x: -4, y: 3))
                                path.closeSubpath()
                            }
                            .fill(Color.white.opacity(0.8))
                            .offset(
                                x: CGFloat.random(in: -10...10),
                                y: CGFloat.random(in: -12...12)
                            )
                        }
                    }
                    .overlay(
                        // Balloon string - pointing down
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 2, height: 75)
                            .offset(y: 33)
                    )
                    .offset(x: -40, y: balloon14Offset)
                    .scaleEffect(scaleEffect * 0.99)
                    .rotationEffect(.degrees(-rotationAngle * 0.4))
                    .opacity(balloon14Opacity)
                    
                    // Balloon 15 - Rose with crosses
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.8, blue: 0.9), // Light rose
                                        Color(red: 0.9, green: 0.6, blue: 0.8)  // Darker rose
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 51, height: 66)
                        
                        // Crosses
                        ForEach(0..<2) { i in
                            ZStack {
                                Rectangle()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: 2, height: 8)
                                Rectangle()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: 8, height: 2)
                            }
                            .offset(
                                x: CGFloat.random(in: -10...10),
                                y: CGFloat.random(in: -12...12)
                            )
                        }
                    }
                    .overlay(
                        // Balloon string - pointing down
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 2, height: 73)
                            .offset(y: 32)
                    )
                    .offset(x: 20, y: balloon15Offset)
                    .scaleEffect(scaleEffect * 0.97)
                    .rotationEffect(.degrees(rotationAngle * 0.3))
                    .opacity(balloon15Opacity)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped(antialiased: false)
        }
        .onAppear {
            startBalloonAnimations()
        }
    }
    
    private func startBalloonAnimations() {
        // Rotation animation
        withAnimation(
            Animation.linear(duration: 6)
                .repeatForever(autoreverses: false)
        ) {
            rotationAngle = 360
        }
        
        // Scale animation
        withAnimation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            scaleEffect = 1.1
        }
        
        // Sparkle animation
        withAnimation(
            Animation.easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
        ) {
            sparkleOpacity = 0.8
        }
        
        // Start continuous balloon animations (slower speeds)
        animateBalloon(1, duration: 12.0, delay: 0.0)
        animateBalloon(2, duration: 15.0, delay: 1.0)
        animateBalloon(3, duration: 18.0, delay: 2.0)
        animateBalloon(4, duration: 13.5, delay: 0.5)
        animateBalloon(5, duration: 16.5, delay: 1.5)
        animateBalloon(6, duration: 12.0, delay: 3.0)
        animateBalloon(7, duration: 19.5, delay: 0.8)
        animateBalloon(8, duration: 15.0, delay: 2.5)
        animateBalloon(9, duration: 21.0, delay: 1.2)
        animateBalloon(10, duration: 10.5, delay: 3.5)
        animateBalloon(11, duration: 22.5, delay: 0.3)
        animateBalloon(12, duration: 14.25, delay: 2.8)
        animateBalloon(13, duration: 17.25, delay: 1.8)
        animateBalloon(14, duration: 12.75, delay: 3.2)
        animateBalloon(15, duration: 18.75, delay: 0.7)
    }
    
    private func animateBalloon(_ balloonNumber: Int, duration: Double, delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            animateSingleBalloon(balloonNumber, duration: duration)
        }
    }
    
    private func animateSingleBalloon(_ balloonNumber: Int, duration: Double) {
        // Animate balloon floating up
        withAnimation(
            Animation.linear(duration: duration)
        ) {
            switch balloonNumber {
            case 1:
                balloon1Offset = -800
                balloon1Opacity = 0.0
            case 2:
                balloon2Offset = -900
                balloon2Opacity = 0.0
            case 3:
                balloon3Offset = -1000
                balloon3Opacity = 0.0
            case 4:
                balloon4Offset = -1100
                balloon4Opacity = 0.0
            case 5:
                balloon5Offset = -1200
                balloon5Opacity = 0.0
            case 6:
                balloon6Offset = -1300
                balloon6Opacity = 0.0
            case 7:
                balloon7Offset = -1400
                balloon7Opacity = 0.0
            case 8:
                balloon8Offset = -1500
                balloon8Opacity = 0.0
            case 9:
                balloon9Offset = -1600
                balloon9Opacity = 0.0
            case 10:
                balloon10Offset = -1700
                balloon10Opacity = 0.0
            case 11:
                balloon11Offset = -1800
                balloon11Opacity = 0.0
            case 12:
                balloon12Offset = -1900
                balloon12Opacity = 0.0
            case 13:
                balloon13Offset = -2000
                balloon13Opacity = 0.0
            case 14:
                balloon14Offset = -2100
                balloon14Opacity = 0.0
            case 15:
                balloon15Offset = -2200
                balloon15Opacity = 0.0
            default:
                break
            }
        }
        
        // Reset balloon after animation completes and restart
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            switch balloonNumber {
            case 1:
                balloon1Offset = 1200
                balloon1Opacity = 1.0
            case 2:
                balloon2Offset = 1300
                balloon2Opacity = 1.0
            case 3:
                balloon3Offset = 1400
                balloon3Opacity = 1.0
            case 4:
                balloon4Offset = 1500
                balloon4Opacity = 1.0
            case 5:
                balloon5Offset = 1600
                balloon5Opacity = 1.0
            case 6:
                balloon6Offset = 1700
                balloon6Opacity = 1.0
            case 7:
                balloon7Offset = 1800
                balloon7Opacity = 1.0
            case 8:
                balloon8Offset = 1900
                balloon8Opacity = 1.0
            case 9:
                balloon9Offset = 2000
                balloon9Opacity = 1.0
            case 10:
                balloon10Offset = 2100
                balloon10Opacity = 1.0
            case 11:
                balloon11Offset = 2200
                balloon11Opacity = 1.0
            case 12:
                balloon12Offset = 2300
                balloon12Opacity = 1.0
            case 13:
                balloon13Offset = 2400
                balloon13Opacity = 1.0
            case 14:
                balloon14Offset = 2500
                balloon14Opacity = 1.0
            case 15:
                balloon15Offset = 2600
                balloon15Opacity = 1.0
            default:
                break
            }
            
            // Restart the animation for this balloon
            animateSingleBalloon(balloonNumber, duration: duration)
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

struct BirthdayCakePopup: View {
    @Environment(\.dismiss) private var dismiss
    @State private var cakeScale: CGFloat = 0.8
    @State private var cakeOpacity: Double = 0.0
    @State private var streamerOffset1: CGFloat = -200
    @State private var streamerOffset2: CGFloat = -200
    @State private var streamerOffset3: CGFloat = -200
    @State private var streamerRotation1: Double = 0
    @State private var streamerRotation2: Double = 0
    @State private var streamerRotation3: Double = 0
    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var showConfetti: Bool = false
    @State private var showCrackAnimation: Bool = false
    @State private var crackScale: CGFloat = 1.0
    @State private var crackRotation: Double = 0
    @State private var reveal46: Bool = false
    @State private var splitOffset5: CGFloat = 0
    @State private var splitOffset0: CGFloat = 0
    @State private var splitScale5: CGFloat = 1.0
    @State private var splitScale0: CGFloat = 1.0
    @State private var showSplitAnimation: Bool = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.95, blue: 0.8), // Pastel yellow
                    Color(red: 0.9, green: 0.95, blue: 1.0), // Pastel blue
                    Color(red: 1.0, green: 0.9, blue: 0.95)  // Pastel pink
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated Streamers
            ZStack {
                // Streamer 1 - Pink
                StreamerView(color: Color(red: 1.0, green: 0.8, blue: 0.9), offset: streamerOffset1, rotation: streamerRotation1)
                    .offset(x: streamerOffset1, y: -100)
                    .rotationEffect(.degrees(streamerRotation1))
                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: streamerRotation1)
                
                // Streamer 2 - Blue
                StreamerView(color: Color(red: 0.8, green: 0.9, blue: 1.0), offset: streamerOffset2, rotation: streamerRotation2)
                    .offset(x: streamerOffset2, y: -50)
                    .rotationEffect(.degrees(streamerRotation2))
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: streamerRotation2)
                
                // Streamer 3 - Yellow
                StreamerView(color: Color(red: 1.0, green: 0.95, blue: 0.8), offset: streamerOffset3, rotation: streamerRotation3)
                    .offset(x: streamerOffset3, y: -150)
                    .rotationEffect(.degrees(streamerRotation3))
                    .animation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: streamerRotation3)
            }
            
            // Animated confetti
            if showConfetti {
                ForEach(confettiPieces.indices, id: \.self) { index in
                    ConfettiPieceView(piece: confettiPieces[index])
                }
            }
            
            VStack(spacing: 30) {
                // Title
                Text("🎂 Happy Birthday Bea! 🎂")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                // Beautiful birthday cake with bundled image
                ZStack {
                    // Local birthday cake image - yellow and white cake
                    Image("BirthdayCake")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 250)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    // Dynamic number overlay on the cake
                    VStack {
                        Spacer()
                        
                        ZStack {
                            // Background for the numbers
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.6))
                                .frame(width: 120, height: 60)
                            
                            // Show "46" after splitting animation
                            if reveal46 {
                                Text("46")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 2)
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                // Split "50" into individual digits that move apart
                                HStack(spacing: 0) {
                                    // "5" - splits to the left
                                    Text("5")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 2)
                                        .offset(x: splitOffset5)
                                        .scaleEffect(splitScale5)
                                        .clipped()
                                    
                                    // "0" - splits to the right
                                    Text("0")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 2)
                                        .offset(x: splitOffset0)
                                        .scaleEffect(splitScale0)
                                        .clipped()
                                }
                                .animation(.easeInOut(duration: 0.8), value: splitOffset5)
                                .animation(.easeInOut(duration: 0.8), value: splitOffset0)
                                .animation(.easeInOut(duration: 0.8), value: splitScale5)
                                .animation(.easeInOut(duration: 0.8), value: splitScale0)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                    .frame(width: 300, height: 250)
                }
                .scaleEffect(cakeScale)
                .opacity(cakeOpacity)
                
                // Message
                Text("Wishing you a wonderful year ahead!")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Close button
                Button("Close") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.8, blue: 0.9), // Pink
                            Color(red: 0.8, green: 0.9, blue: 1.0)  // Blue
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .onAppear {
            // Animate cake appearance
            withAnimation(.easeOut(duration: 0.8)) {
                cakeScale = 1.0
                cakeOpacity = 1.0
            }
            
            // Animate streamers
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                streamerOffset1 = 0
                streamerOffset2 = 0
                streamerOffset3 = 0
            }
            
            // Start streamer rotations
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                streamerRotation1 = 15
                streamerRotation2 = -10
                streamerRotation3 = 20
            }
            
            // Create and launch confetti
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                createConfetti()
                showConfetti = true
            }
            
            // Launch second wave of confetti for continuous celebration
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                createConfetti()
            }
            
            // Launch third wave of confetti
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
                createConfetti()
            }
            
            // Start the splitting animation sequence
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                // First, make the "50" shake slightly
                withAnimation(.easeInOut(duration: 0.2).repeatCount(2, autoreverses: true)) {
                    crackScale = 1.05
                    crackRotation = 2
                }
                
                // Then split the numbers apart
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        // "5" moves left and shrinks
                        splitOffset5 = -30
                        splitScale5 = 0.8
                        // "0" moves right and shrinks
                        splitOffset0 = 30
                        splitScale0 = 0.8
                    }
                }
                
                // Then reveal "46"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        reveal46 = true
                    }
                }
            }
        }
    }
    
    private func createConfetti() {
        confettiPieces = []
        let colors: [Color] = [
            Color(red: 1.0, green: 0.8, blue: 0.9), // Pink
            Color(red: 0.8, green: 0.9, blue: 1.0), // Blue
            Color(red: 1.0, green: 0.95, blue: 0.7), // Yellow
            Color(red: 1.0, green: 0.9, blue: 0.8), // Cream
            Color(red: 0.9, green: 0.8, blue: 1.0)  // Purple
        ]
        
        for _ in 0..<150 {
            let piece = ConfettiPiece(
                color: colors.randomElement() ?? .pink,
                size: CGFloat.random(in: 3...15),
                startX: CGFloat.random(in: -200...200),
                startY: 500,
                endX: CGFloat.random(in: -300...300),
                endY: CGFloat.random(in: -400...200),
                rotation: Double.random(in: 0...720),
                duration: Double.random(in: 4.0...8.0),
                delay: Double.random(in: 0...2.0)
            )
            confettiPieces.append(piece)
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

// Animated Streamer View
struct StreamerView: View {
    let color: Color
    let offset: CGFloat
    let rotation: Double
    @State private var waveOffset: CGFloat = 0
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            for x in stride(from: 0, through: 200, by: 2) {
                let y = sin((CGFloat(x) + waveOffset) * 0.1) * 20
                path.addLine(to: CGPoint(x: CGFloat(x), y: y))
            }
        }
        .stroke(color, lineWidth: 8)
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                waveOffset = 100
            }
        }
    }
}

// MARK: - Confetti Animation
struct ConfettiPiece {
    let color: Color
    let size: CGFloat
    let startX: CGFloat
    let startY: CGFloat
    let endX: CGFloat
    let endY: CGFloat
    let rotation: Double
    let duration: Double
    let delay: Double
}

struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    @State private var offsetX: CGFloat
    @State private var offsetY: CGFloat
    @State private var rotation: Double
    @State private var opacity: Double = 1.0
    
    init(piece: ConfettiPiece) {
        self.piece = piece
        self._offsetX = State(initialValue: piece.startX)
        self._offsetY = State(initialValue: piece.startY)
        self._rotation = State(initialValue: piece.rotation)
    }
    
    var body: some View {
        // Confetti piece shape
        Group {
            if Bool.random() {
                // Square confetti
                Rectangle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
            } else {
                // Circle confetti
                Circle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
            }
        }
        .offset(x: offsetX, y: offsetY)
        .rotationEffect(.degrees(rotation))
        .opacity(opacity)
        .onAppear {
            // Animate confetti shooting up and falling
            withAnimation(.easeOut(duration: piece.duration).delay(piece.delay)) {
                offsetX = piece.endX
                offsetY = piece.endY
                rotation = piece.rotation + 360
            }
            
            // Fade out
            withAnimation(.easeIn(duration: 0.5).delay(piece.duration + piece.delay - 0.5)) {
                opacity = 0.0
            }
        }
    }
} 

// MARK: - Las Vegas Theme Components
struct LasVegasFireworks: View {
    @State private var fireworkOffset1: CGFloat = 0
    @State private var fireworkOffset2: CGFloat = 0
    @State private var fireworkOffset3: CGFloat = 0
    @State private var fireworkScale1: CGFloat = 0.1
    @State private var fireworkScale2: CGFloat = 0.1
    @State private var fireworkScale3: CGFloat = 0.1
    @State private var fireworkOpacity1: Double = 0
    @State private var fireworkOpacity2: Double = 0
    @State private var fireworkOpacity3: Double = 0
    
    var body: some View {
        ZStack {
            // Firework 1 - Yellow neon (sign bulbs)
            FireworkView(color: Color(red: 1.0, green: 1.0, blue: 0.0))
                .offset(x: -100, y: fireworkOffset1)
                .scaleEffect(fireworkScale1)
                .opacity(fireworkOpacity1)
            
            // Firework 2 - Red neon (letters/star)
            FireworkView(color: Color(red: 1.0, green: 0.0, blue: 0.0))
                .offset(x: 150, y: fireworkOffset2)
                .scaleEffect(fireworkScale2)
                .opacity(fireworkOpacity2)
            
            // Firework 3 - Blue (text)
            FireworkView(color: Color(red: 0.0, green: 0.5, blue: 1.0))
                .offset(x: 50, y: fireworkOffset3)
                .scaleEffect(fireworkScale3)
                .opacity(fireworkOpacity3)
        }
        .onAppear {
            startFireworkAnimation()
        }
    }
    
    private func startFireworkAnimation() {
        // Firework 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                fireworkOpacity1 = 1.0
                fireworkScale1 = 1.0
                fireworkOffset1 = -200
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 0.3)) {
                    fireworkOpacity1 = 0
                }
            }
        }
        
        // Firework 2
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                fireworkOpacity2 = 1.0
                fireworkScale2 = 1.0
                fireworkOffset2 = -180
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 0.3)) {
                    fireworkOpacity2 = 0
                }
            }
        }
        
        // Firework 3
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                fireworkOpacity3 = 1.0
                fireworkScale3 = 1.0
                fireworkOffset3 = -220
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 0.3)) {
                    fireworkOpacity3 = 0
                }
            }
        }
        
        // Repeat the sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            startFireworkAnimation()
        }
    }
}

struct FireworkView: View {
    let color: Color
    @State private var sparkleRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Main firework burst
            ForEach(0..<12, id: \.self) { index in
                Rectangle()
                    .fill(color)
                    .frame(width: 3, height: 20)
                    .rotationEffect(.degrees(Double(index) * 30 + sparkleRotation))
                    .offset(y: -10)
            }
            
            // Inner sparkles
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: 4, height: 4)
                    .offset(
                        x: cos(Double(index) * .pi / 4) * 15,
                        y: sin(Double(index) * .pi / 4) * 15
                    )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                sparkleRotation = 360
            }
        }
    }
}

struct LasVegasLandmarks: View {
    @State private var landmarkOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Bellagio fountains (simplified)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        // Fountain base
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.3))
                            .frame(width: 60, height: 20)
                        
                        // Water streams
                        ForEach(0..<5, id: \.self) { index in
                            Rectangle()
                                .fill(Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.6))
                                .frame(width: 2, height: 30)
                                .offset(x: CGFloat(index * 12 - 24))
                                .offset(y: -15 + landmarkOffset * 0.5)
                        }
                    }
                    .offset(x: 80, y: -50)
                }
            }
            
            // Eiffel Tower replica (simplified)
            VStack {
                Spacer()
                HStack {
                    ZStack {
                        // Tower base
                        Rectangle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 8, height: 80)
                        
                        // Tower top
                        Triangle()
                            .fill(Color.gray.opacity(0.6))
                            .frame(width: 20, height: 30)
                            .offset(y: -55)
                        
                        // Neon lights
                        ForEach(0..<3, id: \.self) { index in
                            Rectangle()
                                .fill(Color(red: 1.0, green: 0.8, blue: 0.2))
                                .frame(width: 12, height: 2)
                                .offset(y: CGFloat(index * 20 - 20))
                        }
                    }
                    .offset(x: -120, y: -50)
                    Spacer()
                }
            }
            
            // Luxor pyramid (simplified)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        // Pyramid base
                        Triangle()
                            .fill(Color(red: 1.0, green: 1.0, blue: 0.0).opacity(0.4))
                            .frame(width: 60, height: 40)
                        
                        // Pyramid light beam
                        Rectangle()
                            .fill(Color(red: 1.0, green: 1.0, blue: 0.0).opacity(0.3))
                            .frame(width: 4, height: 100)
                            .offset(y: -70)
                    }
                    .offset(x: 120, y: -50)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                landmarkOffset = 10
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct LasVegasNeonLights: View {
    @State private var neonPulse: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Neon sign 1 - "WELCOME" (red neon like sign letters)
            Text("WELCOME")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.0))
                .shadow(color: Color(red: 1.0, green: 0.0, blue: 0.0), radius: 5)
                .scaleEffect(neonPulse)
                .offset(x: -100, y: -200)
            
            // Neon sign 2 - "FABULOUS" (blue like sign text)
            Text("FABULOUS")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
                .shadow(color: Color(red: 0.0, green: 0.5, blue: 1.0), radius: 5)
                .scaleEffect(neonPulse * 0.8)
                .offset(x: 120, y: -180)
            
            // Neon sign 3 - "LAS VEGAS" (yellow neon like sign bulbs)
            Text("LAS VEGAS")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 1.0, green: 1.0, blue: 0.0))
                .shadow(color: Color(red: 1.0, green: 1.0, blue: 0.0), radius: 5)
                .scaleEffect(neonPulse * 1.2)
                .offset(x: 0, y: -220)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                neonPulse = 1.2
            }
        }
    }
}

struct LasVegasCardElements: View {
    @State private var diceRotation: Double = 0
    @State private var cardOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Dice
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.black, lineWidth: 1)
                    )
                
                // Dice dots
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.black)
                        .frame(width: 3, height: 3)
                        .offset(
                            x: CGFloat(index - 1) * 6,
                            y: 0
                        )
                }
            }
            .rotationEffect(.degrees(diceRotation))
            .offset(x: -40, y: -20)
            
            // Playing card
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white)
                    .frame(width: 16, height: 24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.black, lineWidth: 1)
                    )
                
                Text("♠")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.black)
            }
            .offset(x: 40, y: cardOffset)
            
            // Slot machine symbols
            HStack(spacing: 4) {
                ForEach(["🍒", "🍊", "7️⃣"], id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 12))
                }
            }
            .offset(x: 0, y: 30)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                diceRotation = 360
                cardOffset = 5
            }
        }
    }
} 

// MARK: - USA Theme Components
struct USAPattern: View {
    @State private var starRotation: Double = 0
    @State private var starScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Scattered stars
            ForEach(0..<15, id: \.self) { index in
                Image(systemName: "star.fill")
                    .foregroundColor(.white)
                    .font(.system(size: CGFloat.random(in: 8...16)))
                    .offset(
                        x: CGFloat.random(in: -150...150),
                        y: CGFloat.random(in: -300...300)
                    )
                    .rotationEffect(.degrees(starRotation + Double(index * 24)))
                    .scaleEffect(starScale)
            }
            
            // Larger stars in corners
            ForEach(0..<4, id: \.self) { index in
                Image(systemName: "star.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .offset(
                        x: index < 2 ? -180 : 180,
                        y: index % 2 == 0 ? -350 : 350
                    )
                    .rotationEffect(.degrees(starRotation * 0.5 + Double(index * 90)))
                    .scaleEffect(starScale * 1.2)
            }
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 4)
                    .repeatForever(autoreverses: true)
            ) {
                starRotation = 360
                starScale = 1.3
            }
        }
    }
}

struct USAStripes: View {
    @State private var stripeOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Red and white stripes pattern
            ForEach(0..<7, id: \.self) { index in
                Rectangle()
                    .fill(index % 2 == 0 ? Color(red: 0.8, green: 0.1, blue: 0.2) : Color.white)
                    .frame(height: 3)
                    .offset(y: CGFloat(index * 8 - 24) + stripeOffset)
                    .opacity(0.3)
            }
            
            // Blue corner with stars
            VStack {
                HStack {
                    ZStack {
                        Rectangle()
                            .fill(Color(red: 0.1, green: 0.3, blue: 0.8))
                            .frame(width: 40, height: 30)
                            .opacity(0.4)
                        
                        // Small stars in blue corner
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: "star.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 6))
                                .offset(
                                    x: CGFloat(index % 3 - 1) * 8,
                                    y: CGFloat(index / 3 - 1) * 8
                                )
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
            ) {
                stripeOffset = 5
            }
        }
    }
} 

// MARK: - Additional Girly Birthday Decorations

struct BirthdayGlitter: View {
    @State private var glitterOffset: CGFloat = 0
    @State private var glitterRotation: Double = 0
    @State private var glitterOpacity: Double = 0.7
    
    var body: some View {
        ZStack {
            // Sparkling glitter pieces
            ForEach(0..<20, id: \.self) { index in
                Image(systemName: "sparkle")
                    .foregroundColor([
                        Color(red: 1.0, green: 0.8, blue: 0.9), // Pink
                        Color(red: 0.8, green: 0.9, blue: 1.0), // Blue
                        Color(red: 1.0, green: 0.95, blue: 0.7), // Yellow
                        Color(red: 1.0, green: 0.9, blue: 0.95), // Light pink
                        Color.white
                    ][index % 5])
                    .font(.system(size: CGFloat.random(in: 8...16)))
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: CGFloat.random(in: -400...400)
                    )
                    .rotationEffect(.degrees(glitterRotation + Double(index * 18)))
                    .opacity(glitterOpacity)
                    .animation(
                        .easeInOut(duration: Double.random(in: 1.5...3.0))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1),
                        value: glitterRotation
                    )
            }
        }
        .onAppear {
            withAnimation(
                Animation.linear(duration: 8)
                    .repeatForever(autoreverses: false)
            ) {
                glitterRotation = 360
            }
            
            withAnimation(
                Animation.easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
            ) {
                glitterOpacity = 1.0
            }
        }
    }
}

struct BirthdayHearts: View {
    @State private var heartOffset: CGFloat = 0
    @State private var heartScale: CGFloat = 1.0
    @State private var heartRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Floating hearts
            ForEach(0..<12, id: \.self) { index in
                Image(systemName: "heart.fill")
                    .foregroundColor([
                        Color(red: 1.0, green: 0.6, blue: 0.8), // Pink
                        Color(red: 1.0, green: 0.8, blue: 0.9), // Light pink
                        Color(red: 0.9, green: 0.7, blue: 0.9), // Purple
                        Color(red: 1.0, green: 0.9, blue: 0.95) // Very light pink
                    ][index % 4])
                    .font(.system(size: CGFloat.random(in: 12...24)))
                    .offset(
                        x: CGFloat.random(in: -180...180),
                        y: CGFloat.random(in: -350...350) + heartOffset
                    )
                    .scaleEffect(heartScale)
                    .rotationEffect(.degrees(heartRotation + Double(index * 30)))
                    .animation(
                        .easeInOut(duration: Double.random(in: 2.0...4.0))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: heartScale
                    )
            }
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 4)
                    .repeatForever(autoreverses: true)
            ) {
                heartOffset = 20
                heartScale = 1.2
                heartRotation = 360
            }
        }
    }
}

struct BirthdayStars: View {
    @State private var starOffset: CGFloat = 0
    @State private var starScale: CGFloat = 1.0
    @State private var starRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Twinkling stars
            ForEach(0..<15, id: \.self) { index in
                Image(systemName: "star.fill")
                    .foregroundColor([
                        Color(red: 1.0, green: 0.95, blue: 0.7), // Yellow
                        Color(red: 1.0, green: 1.0, blue: 0.8), // Light yellow
                        Color.white,
                        Color(red: 1.0, green: 0.9, blue: 0.6) // Gold
                    ][index % 4])
                    .font(.system(size: CGFloat.random(in: 10...20)))
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: CGFloat.random(in: -400...400) + starOffset
                    )
                    .scaleEffect(starScale)
                    .rotationEffect(.degrees(starRotation + Double(index * 24)))
                    .animation(
                        .easeInOut(duration: Double.random(in: 1.5...3.5))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.15),
                        value: starScale
                    )
            }
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
            ) {
                starOffset = 15
                starScale = 1.3
                starRotation = 360
            }
        }
    }
}

struct BirthdayCupcakes: View {
    @State private var cupcakeOffset: CGFloat = 0
    @State private var cupcakeScale: CGFloat = 1.0
    @State private var cupcakeRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Decorative cupcakes
            ForEach(0..<6, id: \.self) { index in
                ZStack {
                    // Cupcake base
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.9, green: 0.7, blue: 0.5), // Brown
                                    Color(red: 0.8, green: 0.6, blue: 0.4)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 30, height: 25)
                    
                    // Cupcake frosting
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.8, blue: 0.9), // Pink
                                    Color(red: 0.9, green: 0.6, blue: 0.8)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 35, height: 20)
                        .offset(y: -12)
                    
                    // Sprinkles
                    ForEach(0..<5, id: \.self) { sprinkleIndex in
                        Circle()
                            .fill([
                                Color(red: 1.0, green: 0.9, blue: 0.7), // Yellow
                                Color(red: 0.8, green: 0.9, blue: 1.0), // Blue
                                Color(red: 1.0, green: 0.8, blue: 0.9) // Pink
                            ][sprinkleIndex % 3])
                            .frame(width: 3, height: 3)
                            .offset(
                                x: CGFloat.random(in: -10...10),
                                y: CGFloat.random(in: -15...(-5))
                            )
                    }
                }
                .offset(
                    x: CGFloat(index * 60 - 150),
                    y: 300 + cupcakeOffset
                )
                .scaleEffect(cupcakeScale)
                .rotationEffect(.degrees(cupcakeRotation + Double(index * 60)))
                .animation(
                    .easeInOut(duration: Double.random(in: 2.0...4.0))
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.3),
                    value: cupcakeScale
                )
            }
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 4)
                    .repeatForever(autoreverses: true)
            ) {
                cupcakeOffset = 10
                cupcakeScale = 1.1
                cupcakeRotation = 360
            }
        }
    }
}

struct BirthdayGifts: View {
    @State private var giftOffset: CGFloat = 0
    @State private var giftScale: CGFloat = 1.0
    @State private var giftRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Decorative gift boxes
            ForEach(0..<4, id: \.self) { index in
                ZStack {
                    // Gift box base
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.8, blue: 0.9), // Pink
                                    Color(red: 0.9, green: 0.6, blue: 0.8)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 40, height: 35)
                        .cornerRadius(5)
                    
                    // Gift box lid
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.8, green: 0.9, blue: 1.0), // Blue
                                    Color(red: 0.6, green: 0.8, blue: 0.9)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 45, height: 8)
                        .cornerRadius(3)
                        .offset(y: -21)
                    
                    // Ribbon
                    Rectangle()
                        .fill(Color(red: 1.0, green: 0.95, blue: 0.7)) // Yellow
                        .frame(width: 4, height: 35)
                    
                    Rectangle()
                        .fill(Color(red: 1.0, green: 0.95, blue: 0.7)) // Yellow
                        .frame(width: 40, height: 4)
                        .offset(y: 5)
                    
                    // Bow
                    ZStack {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.6, blue: 0.8)) // Pink
                            .frame(width: 12, height: 8)
                        
                        Circle()
                            .fill(Color(red: 1.0, green: 0.6, blue: 0.8)) // Pink
                            .frame(width: 8, height: 12)
                    }
                    .offset(y: -21)
                }
                .offset(
                    x: CGFloat(index * 80 - 120),
                    y: 350 + giftOffset
                )
                .scaleEffect(giftScale)
                .rotationEffect(.degrees(giftRotation + Double(index * 90)))
                .animation(
                    .easeInOut(duration: Double.random(in: 2.5...4.5))
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.4),
                    value: giftScale
                )
            }
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 5)
                    .repeatForever(autoreverses: true)
            ) {
                giftOffset = 15
                giftScale = 1.15
                giftRotation = 360
            }
        }
    }
}




 