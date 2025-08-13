import SwiftUI
import Foundation

// MARK: - Confetti Celebration
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var animationTimer: Timer?
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                ConfettiParticleView(particle: particle)
            }
        }
        .onAppear {
            createParticles()
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func createParticles() {
        particles = (0..<100).map { _ in
            ConfettiParticle(
                id: UUID(),
                x: Double.random(in: 0...UIScreen.main.bounds.width),
                y: -50,
                velocityX: Double.random(in: -2...2),
                velocityY: Double.random(in: 2...6),
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
        for i in particles.indices {
            particles[i].y += particles[i].velocityY
            particles[i].x += particles[i].velocityX
            particles[i].rotation += particles[i].rotationSpeed
            
            // Add some wind effect
            particles[i].velocityX += Double.random(in: -0.1...0.1)
            
            // Reset particles that fall off screen
            if particles[i].y > UIScreen.main.bounds.height + 50 {
                particles[i].y = -50
                particles[i].x = Double.random(in: 0...UIScreen.main.bounds.width)
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
        ZStack {
            ForEach(fireworks) { firework in
                CelebrationFireworkView(firework: firework)
            }
        }
        .onAppear {
            startFireworks()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func startFireworks() {
        // Create initial fireworks
        createFirework()
        
        // Schedule more fireworks
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            createFirework()
        }
    }
    
    private func createFirework() {
        let newFirework = Firework(
            id: UUID(),
            x: Double.random(in: 50...UIScreen.main.bounds.width - 50),
            y: UIScreen.main.bounds.height + 50,
            targetY: Double.random(in: 100...UIScreen.main.bounds.height - 100),
            color: [.red, .blue, .green, .yellow, .purple, .orange, .pink].randomElement()!,
            particles: []
        )
        
        fireworks.append(newFirework)
        
        // Remove old fireworks
        if fireworks.count > 5 {
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
                    .frame(width: 8, height: 8)
                    .position(x: currentFirework.x, y: currentFirework.y)
            }
            
            // Exploded particles
            ForEach(currentFirework.particles) { particle in
                Circle()
                    .fill(currentFirework.color)
                    .frame(width: 4, height: 4)
                    .position(x: particle.x, y: particle.y)
                    .opacity(particle.alpha)
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
            // Move firework up
            currentFirework.y -= 3
            
            // Check if it should explode
            if currentFirework.y <= currentFirework.targetY {
                explodeFirework()
            }
        } else {
            // Update particles
            for i in currentFirework.particles.indices {
                currentFirework.particles[i].x += currentFirework.particles[i].velocityX
                currentFirework.particles[i].y += currentFirework.particles[i].velocityY
                currentFirework.particles[i].alpha -= 0.02
            }
            
            // Remove faded particles
            currentFirework.particles.removeAll { $0.alpha <= 0 }
        }
    }
    
    private func explodeFirework() {
        currentFirework.exploded = true
        
        // Create explosion particles
        currentFirework.particles = (0..<30).map { _ in
            let angle = Double.random(in: 0...2 * .pi)
            let speed = Double.random(in: 2...6)
            
            return FireworkParticle(
                id: UUID(),
                x: currentFirework.x,
                y: currentFirework.y,
                velocityX: cos(angle) * speed,
                velocityY: sin(angle) * speed,
                alpha: 1.0
            )
        }
    }
}

// MARK: - Balloons Celebration
struct BalloonsView: View {
    @State private var balloons: [Balloon] = []
    @State private var animationTimer: Timer?
    
    var body: some View {
        ZStack {
            ForEach(balloons) { balloon in
                BalloonView(balloon: balloon)
            }
        }
        .onAppear {
            createBalloons()
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func createBalloons() {
        balloons = (0..<15).map { _ in
            Balloon(
                id: UUID(),
                x: Double.random(in: 0...UIScreen.main.bounds.width),
                y: UIScreen.main.bounds.height + 100,
                velocityX: Double.random(in: -1...1),
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
        for i in balloons.indices {
            balloons[i].y += balloons[i].velocityY
            balloons[i].x += balloons[i].velocityX
            balloons[i].rotation += balloons[i].rotationSpeed
            
            // Add gentle swaying
            balloons[i].velocityX += sin(Date().timeIntervalSince1970 + Double(i)) * 0.1
            
            // Reset balloons that float off screen
            if balloons[i].y < -100 {
                balloons[i].y = UIScreen.main.bounds.height + 100
                balloons[i].x = Double.random(in: 0...UIScreen.main.bounds.width)
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
            
            // Balloon string
            Rectangle()
                .fill(Color.gray)
                .frame(width: 1, height: 20)
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
        ZStack {
            ForEach(sparkles) { sparkle in
                SparkleView(sparkle: sparkle)
            }
        }
        .onAppear {
            createSparkles()
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func createSparkles() {
        sparkles = (0..<50).map { _ in
            Sparkle(
                id: UUID(),
                x: Double.random(in: 0...UIScreen.main.bounds.width),
                y: Double.random(in: 0...UIScreen.main.bounds.height),
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
                
                // Celebration content
                VStack(spacing: 20) {
                    Text("🎉 Congratulations! 🎉")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("All tasks completed!")
                        .font(.title2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Celebration animation
                    celebrationAnimation
                        .frame(height: 300)
                }
                .padding()
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