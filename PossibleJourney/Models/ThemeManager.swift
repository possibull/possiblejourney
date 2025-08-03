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
        
        // Check if it's August 4th, 2025 and user is on Bea theme - activate birthday theme
        checkAndActivateBirthdayTheme()
    }
    
    func changeTheme(to theme: ThemeMode) {
        self.currentTheme = theme
        // Persist immediately
        UserDefaults.standard.set(theme.rawValue, forKey: "selectedTheme")
        
        // Check for birthday theme activation when changing to Bea theme
        if theme == .bea {
            checkAndActivateBirthdayTheme()
        }
    }
    
    private func checkAndActivateBirthdayTheme() {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        
        // Check if it's August 4th, 2025
        if components.year == 2025 && components.month == 8 && components.day == 4 {
            // If user is currently on Bea theme, activate birthday theme
            if self.currentTheme == .bea {
                print("🎂 August 4th, 2025 detected! Activating Birthday theme for Bea user!")
                DispatchQueue.main.async {
                    self.currentTheme = .birthday
                    UserDefaults.standard.set(ThemeMode.birthday.rawValue, forKey: "selectedTheme")
                }
            }
        }
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
                Text("🎂 Happy Birthday! 🎂")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                // Beautiful birthday cake with real image
                ZStack {
                    // Real birthday cake image - yellow and white cake
                    AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400&h=300&fit=crop&crop=center")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 250)
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    } placeholder: {
                        // Fallback placeholder while loading
                        RoundedRectangle(cornerRadius: 15)
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
                            .frame(width: 300, height: 250)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .foregroundColor(.white)
                            )
                    }
                    
                    // "46" overlay on the cake
                    VStack {
                        Spacer()
                        
                        Text("46")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 2)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.black.opacity(0.6))
                            )
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