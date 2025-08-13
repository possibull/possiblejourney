import SwiftUI
import Foundation

// MARK: - Confetti Celebration
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var animationTimer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiParticleView(particle: particle)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            // Start immediately without delay
            createParticles()
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func createParticles() {
        // Use GeometryReader to get available space
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        particles = (0..<100).map { _ in
            // Create fountain effect - particles start from bottom center
            let startX = screenWidth / 2 + Double.random(in: -20...20) // Small spread at base
            let startY = screenHeight + 50 // Start from bottom
            
            // Calculate triangle dispersion pattern
            let angle = Double.random(in: -45...45) // 90-degree spread (45° left to 45° right)
            let speed = Double.random(in: 8...15) // Faster upward velocity
            
            // Convert angle to velocity components
            let velocityX = sin(angle * .pi / 180) * speed
            let velocityY = -cos(angle * .pi / 180) * speed // Negative for upward movement
            
            return ConfettiParticle(
                id: UUID(),
                x: startX,
                y: startY,
                velocityX: velocityX,
                velocityY: velocityY,
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -5...5),
                color: [.red, .blue, .green, .yellow, .purple, .orange, .pink].randomElement()!,
                size: Double.random(in: 5...15)
            )
        }
    }
    
    private func startAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateParticles()
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func updateParticles() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        for i in particles.indices {
            // Apply gravity to make particles fall back down
            particles[i].velocityY += 0.3
            
            particles[i].y += particles[i].velocityY
            particles[i].x += particles[i].velocityX
            particles[i].rotation += particles[i].rotationSpeed
            
            // Add some wind effect
            particles[i].velocityX += Double.random(in: -0.1...0.1)
            
            // Reset particles that fall off screen or go too high
            if particles[i].y > screenHeight + 50 || particles[i].y < -50 {
                // Reset to fountain base
                particles[i].x = screenWidth / 2 + Double.random(in: -20...20)
                particles[i].y = screenHeight + 50
                
                // New fountain burst
                let angle = Double.random(in: -45...45)
                let speed = Double.random(in: 8...15)
                particles[i].velocityX = sin(angle * .pi / 180) * speed
                particles[i].velocityY = -cos(angle * .pi / 180) * speed
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: UUID
    var x: Double
    var y: Double
    var velocityX: Double
    var velocityY: Double
    var rotation: Double
    var rotationSpeed: Double
    var color: Color
    var size: Double
}

struct ConfettiParticleView: View {
    let particle: ConfettiParticle
    
    var body: some View {
        Rectangle()
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size)
            .position(x: particle.x, y: particle.y)
            .rotationEffect(.degrees(particle.rotation))
    }
}

// MARK: - Fireworks Celebration
struct FireworksView: View {
    @State private var fireworks: [Firework] = []
    @State private var animationTimer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(fireworks) { firework in
                    CelebrationFireworkView(firework: firework)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            startFireworks()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func startFireworks() {
        // Create multiple initial fireworks immediately
        createFirework()
        createFirework()
        createFirework()
        
        // Schedule more fireworks more frequently
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
            createFirework()
        }
    }
    
    private func createFirework() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let newFirework = Firework(
            id: UUID(),
            x: Double.random(in: 50...screenWidth - 50),
            y: screenHeight + 50,
            targetY: Double.random(in: 50...screenHeight * 0.8), // Better distribution across screen
            color: [.red, .blue, .green, .yellow, .purple, .orange, .pink].randomElement()!,
            particles: []
        )
        
        fireworks.append(newFirework)
        
        // Remove old fireworks
        if fireworks.count > 8 {
            fireworks.removeFirst()
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

struct Firework: Identifiable {
    let id: UUID
    var x: Double
    var y: Double
    let targetY: Double
    let color: Color
    var particles: [FireworkParticle]
    var exploded: Bool = false
}

struct FireworkParticle: Identifiable {
    let id: UUID
    var x: Double
    var y: Double
    var velocityX: Double
    var velocityY: Double
    var alpha: Double
}

struct CelebrationFireworkView: View {
    let firework: Firework
    @State private var currentFirework: Firework
    @State private var animationTimer: Timer?
    
    init(firework: Firework) {
        self.firework = firework
        self._currentFirework = State(initialValue: firework)
    }
    
    var body: some View {
        ZStack {
            // Rising firework
            if !currentFirework.exploded {
                Circle()
                    .fill(currentFirework.color)
                    .frame(width: 12, height: 12) // Made bigger
                    .position(x: currentFirework.x, y: currentFirework.y)
                    .shadow(color: currentFirework.color.opacity(0.8), radius: 4, x: 0, y: 0) // Added glow effect
            }
            
            // Exploded particles
            ForEach(currentFirework.particles) { particle in
                Circle()
                    .fill(currentFirework.color)
                    .frame(width: 6, height: 6) // Made bigger
                    .position(x: particle.x, y: particle.y)
                    .opacity(particle.alpha)
                    .shadow(color: currentFirework.color.opacity(particle.alpha * 0.5), radius: 2, x: 0, y: 0) // Added glow effect
            }
        }
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func startAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateFirework()
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func updateFirework() {
        if !currentFirework.exploded {
            // Move firework up faster for more excitement
            currentFirework.y -= 5
            
            // Check if it should explode
            if currentFirework.y <= currentFirework.targetY {
                explodeFirework()
            }
        } else {
            // Update particles with gravity and air resistance for realistic explosion
            for i in currentFirework.particles.indices {
                // Apply gravity
                currentFirework.particles[i].velocityY += 0.1
                
                // Apply air resistance
                currentFirework.particles[i].velocityX *= 0.98
                currentFirework.particles[i].velocityY *= 0.98
                
                // Update position
                currentFirework.particles[i].x += currentFirework.particles[i].velocityX
                currentFirework.particles[i].y += currentFirework.particles[i].velocityY
                
                // Fade out particles gradually
                currentFirework.particles[i].alpha -= 0.015
            }
            
            // Remove faded particles
            currentFirework.particles.removeAll { $0.alpha <= 0 }
        }
    }
    
    private func explodeFirework() {
        currentFirework.exploded = true
        
        // Create multiple explosion rings for realistic firework effect
        var allParticles: [FireworkParticle] = []
        
        // Inner ring - fast particles
        for i in 0..<20 {
            let angle = (Double(i) / 20.0) * 2 * .pi
            let speed = Double.random(in: 8...12)
            
            allParticles.append(FireworkParticle(
                id: UUID(),
                x: currentFirework.x,
                y: currentFirework.y,
                velocityX: cos(angle) * speed,
                velocityY: sin(angle) * speed,
                alpha: 1.0
            ))
        }
        
        // Middle ring - medium speed particles
        for i in 0..<15 {
            let angle = (Double(i) / 15.0) * 2 * .pi + Double.random(in: -0.2...0.2)
            let speed = Double.random(in: 5...8)
            
            allParticles.append(FireworkParticle(
                id: UUID(),
                x: currentFirework.x,
                y: currentFirework.y,
                velocityX: cos(angle) * speed,
                velocityY: sin(angle) * speed,
                alpha: 1.0
            ))
        }
        
        // Outer ring - slower particles
        for i in 0..<10 {
            let angle = (Double(i) / 10.0) * 2 * .pi + Double.random(in: -0.3...0.3)
            let speed = Double.random(in: 3...6)
            
            allParticles.append(FireworkParticle(
                id: UUID(),
                x: currentFirework.x,
                y: currentFirework.y,
                velocityX: cos(angle) * speed,
                velocityY: sin(angle) * speed,
                alpha: 1.0
            ))
        }
        
        // Add some random particles for sparkle effect
        for _ in 0..<15 {
            let angle = Double.random(in: 0...2 * .pi)
            let speed = Double.random(in: 2...10)
            
            allParticles.append(FireworkParticle(
                id: UUID(),
                x: currentFirework.x,
                y: currentFirework.y,
                velocityX: cos(angle) * speed,
                velocityY: sin(angle) * speed,
                alpha: 1.0
            ))
        }
        
        currentFirework.particles = allParticles
    }
}

// MARK: - Balloons Celebration
struct BalloonsView: View {
    @State private var balloons: [Balloon] = []
    @State private var animationTimer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(balloons) { balloon in
                    BalloonView(balloon: balloon)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            // Start immediately without delay
            createBalloons()
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func createBalloons() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        balloons = (0..<15).map { _ in
            Balloon(
                id: UUID(),
                x: Double.random(in: 0...screenWidth),
                y: screenHeight + 100,
                velocityX: Double.random(in: -2...2), // Increased horizontal movement
                velocityY: Double.random(in: -3...(-1)),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -2...2),
                color: [.red, .blue, .green, .yellow, .purple, .orange, .pink].randomElement()!,
                size: Double.random(in: 30...60)
            )
        }
    }
    
    private func startAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateBalloons()
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func updateBalloons() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        for i in balloons.indices {
            balloons[i].y += balloons[i].velocityY
            balloons[i].x += balloons[i].velocityX
            balloons[i].rotation += balloons[i].rotationSpeed
            
            // Add more pronounced swaying for better movement
            balloons[i].velocityX += sin(Date().timeIntervalSince1970 + Double(i)) * 0.2
            
            // Add some wind effect for more natural movement
            balloons[i].velocityX += Double.random(in: -0.1...0.1)
            
            // Keep balloons within screen bounds horizontally
            if balloons[i].x < -50 {
                balloons[i].x = screenWidth + 50
            } else if balloons[i].x > screenWidth + 50 {
                balloons[i].x = -50
            }
            
            // Reset balloons that float off screen
            if balloons[i].y < -100 {
                balloons[i].y = screenHeight + 100
                balloons[i].x = Double.random(in: 0...screenWidth)
            }
        }
    }
}

struct Balloon: Identifiable {
    let id: UUID
    var x: Double
    var y: Double
    var velocityX: Double
    var velocityY: Double
    var rotation: Double
    var rotationSpeed: Double
    var color: Color
    var size: Double
}

struct BalloonView: View {
    let balloon: Balloon
    
    var body: some View {
        VStack(spacing: 0) {
            // Balloon body
            Ellipse()
                .fill(balloon.color)
                .frame(width: balloon.size, height: balloon.size * 1.3)
                .overlay(
                    Ellipse()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
            
            // Balloon string - longer, curlier, and pointing opposite to balloon top
            Path { path in
                let startX: CGFloat = 0
                let startY: CGFloat = balloon.size * 0.65 // Start from bottom of balloon
                let endX: CGFloat = balloon.size * 0.3 // Point towards opposite side
                let endY: CGFloat = startY + 40 // Longer string
                
                path.move(to: CGPoint(x: startX, y: startY))
                
                // Create a curly string with multiple curves
                let control1X = startX + 5
                let control1Y = startY + 10
                let control2X = endX - 5
                let control2Y = endY - 10
                
                path.addCurve(
                    to: CGPoint(x: endX, y: endY),
                    control1: CGPoint(x: control1X, y: control1Y),
                    control2: CGPoint(x: control2X, y: control2Y)
                )
                
                // Add a small curl at the end
                let curlX = endX + 3
                let curlY = endY + 5
                path.addCurve(
                    to: CGPoint(x: curlX, y: curlY),
                    control1: CGPoint(x: endX + 2, y: endY + 2),
                    control2: CGPoint(x: curlX, y: curlY)
                )
            }
            .stroke(Color.gray, lineWidth: 1.5)
        }
        .position(x: balloon.x, y: balloon.y)
        .rotationEffect(.degrees(balloon.rotation))
    }
}

// MARK: - Sparkles Celebration
struct SparklesView: View {
    @State private var sparkles: [Sparkle] = []
    @State private var animationTimer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(sparkles) { sparkle in
                    SparkleView(sparkle: sparkle)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            // Start immediately without delay
            createSparkles()
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func createSparkles() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        sparkles = (0..<50).map { _ in
            Sparkle(
                id: UUID(),
                x: Double.random(in: 0...screenWidth),
                y: Double.random(in: 0...screenHeight),
                scale: Double.random(in: 0.5...1.5),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -3...3),
                alpha: Double.random(in: 0.3...1.0),
                color: [.yellow, .white, .orange, .pink].randomElement()!
            )
        }
    }
    
    private func startAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateSparkles()
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func updateSparkles() {
        for i in sparkles.indices {
            sparkles[i].rotation += sparkles[i].rotationSpeed
            
            // Make sparkles twinkle
            let time = Date().timeIntervalSince1970
            sparkles[i].alpha = 0.3 + 0.7 * sin(time * 2 + Double(i))
        }
    }
}

struct Sparkle: Identifiable {
    let id: UUID
    var x: Double
    var y: Double
    var scale: Double
    var rotation: Double
    var rotationSpeed: Double
    var alpha: Double
    var color: Color
}

struct SparkleView: View {
    let sparkle: Sparkle
    
    var body: some View {
        Image(systemName: "sparkle")
            .foregroundColor(sparkle.color)
            .font(.system(size: 20))
            .scaleEffect(sparkle.scale)
            .rotationEffect(.degrees(sparkle.rotation))
            .opacity(sparkle.alpha)
            .position(x: sparkle.x, y: sparkle.y)
    }
}

// MARK: - Celebration Container
struct CelebrationOverlay: View {
    let celebrationType: CelebrationType
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            ZStack {
                // Semi-transparent background
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isShowing = false
                        }
                    }
                
                // Celebration animations as background
                celebrationAnimation
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Centered congratulations text overlay
                VStack(spacing: 10) {
                    Text("🎉 Congratulations! 🎉")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("All tasks completed!")
                        .font(.title2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
            }
            .transition(.opacity)
        }
    }
    
    @ViewBuilder
    private var celebrationAnimation: some View {
        switch celebrationType {
        case .confetti:
            ConfettiView()
        case .fireworks:
            FireworksView()
        case .balloons:
            BalloonsView()
        case .sparkles:
            SparklesView()
        case .random:
            // This should never be called as it's handled by CelebrationManager
            ConfettiView()
        }
    }
} 