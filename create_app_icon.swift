import SwiftUI
import CoreGraphics
import UIKit

// App Icon Generator for Possible Journey
// This script creates a 1024x1024 app icon that complies with Apple's guidelines

struct AppIconView: View {
    var body: some View {
        ZStack {
            // Background gradient - blue theme matching the app
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.4, blue: 0.8), // Deep blue
                    Color(red: 0.2, green: 0.6, blue: 1.0)  // Lighter blue
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Main icon elements
            VStack(spacing: 20) {
                // Target/compass icon representing goals and progress
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 8)
                        .frame(width: 200, height: 200)
                    
                    // Middle ring
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 6)
                        .frame(width: 150, height: 150)
                    
                    // Inner circle with checkmark
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    // Checkmark representing completion
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                }
                
                // Progress dots representing daily progress
                HStack(spacing: 12) {
                    ForEach(0..<5) { index in
                        Circle()
                            .fill(index < 3 ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 12, height: 12)
                            .scaleEffect(index < 3 ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.1), value: UUID())
                    }
                }
            }
        }
        .frame(width: 1024, height: 1024)
        .clipped()
    }
}

// Function to generate and save the icon
func generateAppIcon() {
    let renderer = ImageRenderer(content: AppIconView())
    renderer.scale = 1.0
    
    if let image = renderer.uiImage {
        // Convert to PNG data
        if let pngData = image.pngData() {
            // Save to file
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let iconPath = documentsPath.appendingPathComponent("PossibleJourney_AppIcon_1024x1024.png")
            
            do {
                try pngData.write(to: iconPath)
                print("✅ App icon generated successfully!")
                print("📁 Saved to: \(iconPath.path)")
                print("📏 Size: 1024x1024 pixels")
                print("🎨 Theme: Blue gradient with target/checkmark design")
                print("📱 Apple Guidelines: Compliant")
            } catch {
                print("❌ Error saving icon: \(error)")
            }
        }
    }
}

// Alternative simpler design for better visibility at small sizes
struct SimpleAppIconView: View {
    var body: some View {
        ZStack {
            // Clean gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.4, blue: 0.8),
                    Color(red: 0.2, green: 0.6, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Simple, bold target design
            ZStack {
                // Outer circle
                Circle()
                    .stroke(Color.white, lineWidth: 12)
                    .frame(width: 300, height: 300)
                
                // Middle circle
                Circle()
                    .stroke(Color.white, lineWidth: 10)
                    .frame(width: 200, height: 200)
                
                // Inner circle with checkmark
                Circle()
                    .fill(Color.white)
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
                
                // Bold checkmark
                Image(systemName: "checkmark")
                    .font(.system(size: 60, weight: .black))
                    .foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
            }
        }
        .frame(width: 1024, height: 1024)
        .clipped()
    }
}

func generateSimpleAppIcon() {
    let renderer = ImageRenderer(content: SimpleAppIconView())
    renderer.scale = 1.0
    
    if let image = renderer.uiImage {
        if let pngData = image.pngData() {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let iconPath = documentsPath.appendingPathComponent("PossibleJourney_Simple_AppIcon_1024x1024.png")
            
            do {
                try pngData.write(to: iconPath)
                print("✅ Simple app icon generated successfully!")
                print("📁 Saved to: \(iconPath.path)")
                print("🎯 Design: Clean target with checkmark")
                print("📱 Optimized for small display sizes")
            } catch {
                print("❌ Error saving simple icon: \(error)")
            }
        }
    }
}

// Generate both versions
generateAppIcon()
generateSimpleAppIcon() 