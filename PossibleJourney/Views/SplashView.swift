//
//  SplashView.swift
//  PossibleJourney
//
//  Created by Ted Possible on 7/22/25.
//

import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 50
    @State private var titleOpacity: Double = 0.0
    @State private var taglineOffset: CGFloat = 30
    @State private var taglineOpacity: Double = 0.0
    @State private var backgroundRotation: Double = 0.0
    @EnvironmentObject var themeManager: ThemeManager
    
    private var themeGradientColors: [Color] {
        // Debug: Print the current theme
        print("DEBUG: Current theme: \(themeManager.currentTheme)")
        
        switch themeManager.currentTheme {
        case .bea:
            print("DEBUG: Using Bea theme colors - PINK")
            return [
                Color.pink, // Very distinct color for testing
                Color.yellow,
                Color.pink
            ]
        case .dark:
            print("DEBUG: Using Dark theme colors - RED")
            return [
                Color.red,
                Color.orange,
                Color.red
            ]
        case .light, .system:
            print("DEBUG: Using Light/System theme colors - GREEN")
            return [
                Color.green,
                Color.blue,
                Color.green
            ]
        @unknown default:
            print("DEBUG: Using default fallback colors - PURPLE")
            // Fallback to original colors if theme is not recognized
            return [
                Color.blue.opacity(0.8),
                Color.purple.opacity(0.6),
                Color.blue.opacity(0.4)
            ]
        }
    }
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                gradient: Gradient(colors: themeGradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .rotationEffect(.degrees(backgroundRotation))
            .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: backgroundRotation)
            
            // Subtle animated circles
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 200, height: 200)
                .offset(x: -100, y: -200)
                .scaleEffect(1.2)
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: UUID())
            
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 150, height: 150)
                .offset(x: 120, y: 250)
                .scaleEffect(0.8)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: UUID())
            
            VStack(spacing: 40) {
                Spacer()
                
                // App icon/logo with modern design
                ZStack {
                    // Glowing background circle
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                    
                    // Main icon
                    Image(systemName: "target")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(.white)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                
                VStack(spacing: 16) {
                    // App name with modern typography
                    Text("Possible Journey")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        .offset(y: titleOffset)
                        .opacity(titleOpacity)
                    
                    // Tagline with elegant styling
                    Text("Transform your habits, one day at a time")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .offset(y: taglineOffset)
                        .opacity(taglineOpacity)
                }
                
                Spacer()
                
                // Loading indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 8, height: 8)
                            .scaleEffect(1.0)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                                value: UUID()
                            )
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            // Start background rotation
            backgroundRotation = 360
            
            // Animate logo
            withAnimation(.easeOut(duration: 1.0)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            // Animate title
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                titleOffset = 0
                titleOpacity = 1.0
            }
            
            // Animate tagline
            withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
                taglineOffset = 0
                taglineOpacity = 1.0
            }
            
            // Auto-dismiss after 3.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    SplashView(showSplash: .constant(true))
} 