//
//  SplashView.swift
//  PossibleJourney
//
//  Created by Ted Possible on 7/22/25.
//

import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool
    
    var body: some View {
        ZStack {
            // Light background with blue accent
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color.blue.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // App icon/logo
                Image(systemName: "target")
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(.blue)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: UUID())
                
                // App name
                Text("Possible Journey")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Tagline
                Text("Transform your habits, one day at a time")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .onAppear {
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    SplashView(showSplash: .constant(true))
} 