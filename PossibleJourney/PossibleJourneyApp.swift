//
//  PossibleJourneyApp.swift
//  PossibleJourney
//
//  Created by Ted Possible on 7/22/25.
//

import SwiftUI
import Foundation

// MARK: - Bea Number Sequence View
struct BeaNumberSequenceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentIndex = 0
    @State private var numberOpacity: Double = 0.0
    @State private var numberScale: CGFloat = 0.5
    @State private var beePositions: [CGPoint] = []
    @State private var beeRotations: [Double] = []
    @State private var beeScales: [CGFloat] = []
    
    private let numbers = ["1", "0", "0", "0", "1", "1", "1", "1"]
    private let displayDuration: TimeInterval = 0.8
    private let transitionDuration: TimeInterval = 0.3
    private let beeCount = 15
    
    private var themeAccentColor: Color {
        switch themeManager.currentTheme {
        case .birthday:
            return Color(red: 1.0, green: 0.95, blue: 0.7) // Pastel yellow
        case .bea:
            return Color(red: 1.0, green: 0.98, blue: 0.8) // Pastel yellow for Bea theme
        case .dark:
            return Color.blue
        case .light, .system:
            return Color.blue
        }
    }
    
    private var themeSecondaryColor: Color {
        switch themeManager.currentTheme {
        case .birthday:
            return Color(red: 0.8, green: 0.9, blue: 1.0) // Pastel blue
        case .bea:
            return Color(red: 0.8, green: 0.9, blue: 1.0) // Pastel blue for Bea theme
        case .dark:
            return Color.blue.opacity(0.7)
        case .light, .system:
            return Color.blue.opacity(0.7)
        }
    }
    
    var body: some View {
        ZStack {
            // Transparent background
            Color.clear
                .ignoresSafeArea()
            
            // Animated bees
            ForEach(0..<beeCount, id: \.self) { index in
                if index < beePositions.count {
                    BeeView()
                        .foregroundColor(themeSecondaryColor)
                        .frame(width: 30, height: 30)
                        .position(beePositions[index])
                        .rotationEffect(.degrees(beeRotations[index]))
                        .scaleEffect(beeScales[index])
                        .animation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true), value: beeRotations[index])
                        .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: beeScales[index])
                }
            }
            
            // Giant number display
            if currentIndex < numbers.count {
                Text(numbers[currentIndex])
                    .font(.system(size: 300, weight: .bold, design: .monospaced))
                    .foregroundColor(themeAccentColor)
                    .shadow(color: .black, radius: 15, x: 0, y: 0)
                    .opacity(numberOpacity)
                    .scaleEffect(numberScale)
                    .animation(.easeInOut(duration: transitionDuration), value: numberOpacity)
                    .animation(.easeInOut(duration: transitionDuration), value: numberScale)
            }
        }
        .onAppear {
            initializeBees()
            startNumberSequence()
        }
    }
    
    private func startNumberSequence() {
        displayNextNumber()
    }
    
    private func displayNextNumber() {
        guard currentIndex < numbers.count else {
            // Sequence complete, dismiss the sheet
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
            }
            return
        }
        
        // Animate number appearance
        withAnimation(.easeInOut(duration: transitionDuration)) {
            numberOpacity = 1.0
            numberScale = 1.0
        }
        
        // Display number for specified duration
        DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) {
            // Animate number disappearance
            withAnimation(.easeInOut(duration: transitionDuration)) {
                numberOpacity = 0.0
                numberScale = 0.5
            }
            
            // Move to next number after transition
            DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) {
                currentIndex += 1
                displayNextNumber()
            }
        }
    }
    
    private func initializeBees() {
        beePositions = []
        beeRotations = []
        beeScales = []
        
        // Start all bees off-screen
        for _ in 0..<beeCount {
            beePositions.append(CGPoint(x: -100, y: -100)) // Off-screen
            beeRotations.append(Double.random(in: -15...15))
            beeScales.append(CGFloat.random(in: 0.9...1.1))
        }
        
        // Start sequential letter animations
        startSequentialLetterAnimations()
    }
    
    private func startSequentialLetterAnimations() {
        let centerX: CGFloat = 200 // Center of screen
        let baseY: CGFloat = 150   // Above the numbers
        let letterSpacing: CGFloat = 80 // Space between letters
        let beeSpacing: CGFloat = 25 // Space between bees in each letter
        
        // Letter "B" positions
        let bStartX = centerX - letterSpacing
        let bPositions = [
            CGPoint(x: bStartX, y: baseY - 30), // Top left
            CGPoint(x: bStartX, y: baseY),      // Middle left
            CGPoint(x: bStartX, y: baseY + 30), // Bottom left
            CGPoint(x: bStartX + beeSpacing, y: baseY - 15), // Top curve
            CGPoint(x: bStartX + beeSpacing, y: baseY + 15)  // Bottom curve
        ]
        
        // Letter "E" positions
        let eStartX = centerX
        let ePositions = [
            CGPoint(x: eStartX, y: baseY - 30), // Top left
            CGPoint(x: eStartX, y: baseY),      // Middle left
            CGPoint(x: eStartX, y: baseY + 30), // Bottom left
            CGPoint(x: eStartX + beeSpacing, y: baseY - 30), // Top bar
            CGPoint(x: eStartX + beeSpacing, y: baseY + 30)  // Bottom bar
        ]
        
        // Letter "A" positions
        let aStartX = centerX + letterSpacing
        let aPositions = [
            CGPoint(x: aStartX, y: baseY + 30), // Bottom left
            CGPoint(x: aStartX + beeSpacing, y: baseY + 30), // Bottom right
            CGPoint(x: aStartX + beeSpacing/2, y: baseY - 30), // Top point
            CGPoint(x: aStartX + beeSpacing/2, y: baseY),    // Middle cross
            CGPoint(x: aStartX + beeSpacing/2, y: baseY + 15) // Middle cross lower
        ]
        
        // Animate letter "B" first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.animateLetter(positions: bPositions, startIndex: 0)
        }
        
        // Animate letter "E" second
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.animateLetter(positions: ePositions, startIndex: 5)
        }
        
        // Animate letter "A" third
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            self.animateLetter(positions: aPositions, startIndex: 10)
        }
    }
    
    private func animateLetter(positions: [CGPoint], startIndex: Int) {
        // Animate each bee in the letter to its position
        for (index, position) in positions.enumerated() {
            let beeIndex = startIndex + index
            if beeIndex < beePositions.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                    withAnimation(.easeOut(duration: 0.8)) {
                        self.beePositions[beeIndex] = position
                    }
                    
                    // Start gentle hovering after reaching position
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                            self.beePositions[beeIndex].x += CGFloat.random(in: -8...8)
                            self.beePositions[beeIndex].y += CGFloat.random(in: -5...5)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Bee View
struct BeeView: View {
    var body: some View {
        ZStack {
            // Bee body
            Ellipse()
                .fill(Color.yellow)
                .frame(width: 20, height: 12)
            
            // Bee stripes
            Rectangle()
                .fill(Color.black)
                .frame(width: 20, height: 2)
                .offset(y: -2)
            
            Rectangle()
                .fill(Color.black)
                .frame(width: 20, height: 2)
                .offset(y: 2)
            
            // Wings
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 8, height: 8)
                .offset(x: -8, y: -4)
            
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 8, height: 8)
                .offset(x: 8, y: -4)
        }
    }
}

// MARK: - Global Theme Selector
struct GlobalThemeSelector: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingThemeMenu = false
    @State private var beaTapCount = 0
    @State private var lastBeaTapTime: Date = Date()
    @State private var showingBeaNumberSequence = false
    
    var body: some View {
        HStack(spacing: 8) {
            Menu {
                ForEach(ThemeMode.allCases.filter { $0 != .birthday }, id: \.self) { theme in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            themeManager.changeTheme(to: theme)
                        }
                        
                        // Trigger Bea number sequence if Bea theme is selected
                        if theme == .bea {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showingBeaNumberSequence = true
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: themeManager.currentTheme == theme ? "checkmark" : theme.iconName)
                                .foregroundColor(themeManager.currentTheme == theme ? .blue : .primary)
                            Text(theme.displayName)
                            Spacer()
                        }
                    }
                }
            } label: {
                Image(systemName: "paintbrush.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 18, weight: .medium))
            }
            .accessibilityIdentifier("GlobalThemeSelector")
            
            // Hidden Easter egg button (only visible when Bea theme is active)
            if themeManager.currentTheme == .bea {
                Button(action: {
                    print("🎨 Easter egg button tapped! Count: \(beaTapCount + 1)")
                    let now = Date()
                    if now.timeIntervalSince(lastBeaTapTime) < 2.0 {
                        beaTapCount += 1
                        print("🎨 Bea tap count: \(beaTapCount)")
                        if beaTapCount >= 5 {
                            print("🎂 BIRTHDAY THEME UNLOCKED!")
                            // Activate Birthday theme as Easter egg
                            withAnimation(.easeInOut(duration: 0.3)) {
                                themeManager.changeTheme(to: .birthday)
                            }
                            beaTapCount = 0
                        }
                    } else {
                        beaTapCount = 1
                        print("🎨 Bea tap count reset to: \(beaTapCount)")
                    }
                    lastBeaTapTime = now
                }) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.clear) // Invisible but tappable
                        .font(.system(size: 18, weight: .medium))
                        .frame(width: 44, height: 44) // Minimum tap target
                }
                .accessibilityIdentifier("EasterEggButton")
            }
        }
        .sheet(isPresented: $showingBeaNumberSequence) {
            BeaNumberSequenceView()
                .background(.clear)
                .presentationBackground(.clear)
        }
    }
}

// Global DebugWindow for all screens
import SwiftUI

struct GlobalDebugWindow: View {
    @EnvironmentObject var debugState: DebugState
    @EnvironmentObject var appState: ProgramAppState
    var checklistDebugContent: () -> AnyView
    var body: some View {
        if debugState.debug {
            DebugWindow(isExpanded: $debugState.debugWindowExpanded) {
                checklistDebugContent()
            }
        }
    }
}

func resetForUITestingIfNeeded() {
    if CommandLine.arguments.contains("--uitesting-reset") {
        ProgramStorage().clear()
        DailyProgressStorage().clearAll()
    }
}

@main
struct PossibleJourneyApp: App {
    @StateObject private var appState = ProgramAppState()
    @StateObject private var debugState = DebugState()
    @StateObject private var updateChecker = AppUpdateChecker()
    @StateObject private var themeManager = ThemeManager()
    @State private var showSplash = true
    
    init() {
        resetForUITestingIfNeeded()
        // Always minimize debug window on launch
        UserDefaults.standard.set(false, forKey: "debugWindowExpanded")
    }
    var currentTimeOverride: Date? {
        if let idx = CommandLine.arguments.firstIndex(of: "--uitesting-current-time"),
           CommandLine.arguments.count > idx + 1,
           let timestamp = Double(CommandLine.arguments[idx + 1]) {
            return Date(timeIntervalSince1970: timestamp)
        }
        return nil
    }
    var body: some Scene {
        return WindowGroup {
            if showSplash {
                SplashView(showSplash: $showSplash)
                    .environmentObject(themeManager)
                    .onAppear {
                        // Check for updates when app starts
                        updateChecker.checkForUpdates()
                    }
            } else {
                ZStack(alignment: .top) {
                    NavigationStack {
                        if let program = appState.loadedProgram {
                            let now = currentTimeOverride ?? Date()
                            AnyView(
                                DailyChecklistView()
                                .environmentObject(debugState)
                                .environmentObject(themeManager)
                            )
                        } else {
                            AnyView(
                                ProgramSetupMainView(onProgramCreated: { program in
                                    appState.loadedProgram = program
                                    ProgramStorage().save(program)
                                })
                                .environmentObject(debugState)
                                .environmentObject(themeManager)
                            )
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            GlobalThemeSelector()
                        }
                    }
                // Global DebugWindow always visible at top
                GlobalDebugWindow(checklistDebugContent: {
                    let debugTime = currentTimeOverride ?? Date()
                    let rawTimeArg: String? = {
                        if let idx = CommandLine.arguments.firstIndex(of: "--uitesting-current-time"),
                           CommandLine.arguments.count > idx + 1 {
                            return CommandLine.arguments[idx + 1]
                        }
                        return nil
                    }()
                    if let program = appState.loadedProgram {
                        let now = currentTimeOverride ?? Date()
                        let activeDay = program.nextActiveDay(currentDate: now) ?? Calendar.current.startOfDay(for: now)
                        let dailyProgress = DailyProgressStorage().load(for: activeDay) ?? DailyProgress(id: UUID(), date: activeDay, completedTaskIDs: [])
                        let viewModel = DailyChecklistViewModel(program: program, dailyProgress: dailyProgress, now: now)
                        return AnyView(Group {
                            Text("DEBUG Overridden Time: \(debugTime)")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .accessibilityIdentifier("DebugCurrentTimeLabel")
                            if let raw = rawTimeArg {
                                Text("DEBUG Raw Time Arg: \(raw)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .accessibilityIdentifier("DebugRawTimeArgLabel")
                            }
                            Text("DEBUG Program UUID: \(viewModel.program.id.uuidString)")
                                .font(.caption)
                                .foregroundColor(.pink)
                                .accessibilityIdentifier("DebugProgramUUIDLabel")
                            Text("DEBUG now: \(viewModel.now)")
                                .font(.caption)
                                .foregroundColor(.yellow)
                                .accessibilityIdentifier("DebugNowLabel")
                            Text("DEBUG isDayMissed: \(viewModel.isDayMissed ? "YES" : "NO")")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .accessibilityIdentifier("DebugIsDayMissedLabel")
                            Text("DEBUG completedTaskIDs: \(viewModel.dailyProgress.completedTaskIDs.map { $0.uuidString }.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.green)
                                .accessibilityIdentifier("DebugCompletedTaskIDsLabel")
                            Text("DEBUG showMissedDayModal: \(viewModel.isDayMissed ? "YES" : "NO")")
                                .font(.caption)
                                .foregroundColor(.red)
                                .accessibilityIdentifier("DebugShowMissedDayModalLabel")
                            Text("TaskTitles: \(viewModel.program.tasks().map { $0.title }.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .accessibilityIdentifier("TaskTitlesDebug")
                            Text("TaskIDs: \(viewModel.program.tasks().map { $0.id.uuidString }.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.purple)
                                .accessibilityIdentifier("TaskIDsDebug")
                            Text("DEBUG Program Start Date: \(viewModel.program.startDate)")
                                .font(.caption)
                                .foregroundColor(.cyan)
                                .accessibilityIdentifier("DebugProgramStartDateLabel")
                        })
                    } else {
                        // Show debug info for setup screen in the debug window
                        let storedProgram = ProgramStorage().load()
                        return AnyView(
                            VStack(alignment: .leading, spacing: 4) {
                                Text("DEBUG Overridden Time: \(debugTime)")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .accessibilityIdentifier("DebugCurrentTimeLabel")
                                if let raw = rawTimeArg {
                                    Text("DEBUG Raw Time Arg: \(raw)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .accessibilityIdentifier("DebugRawTimeArgLabel")
                                }
                                if let program = storedProgram {
                                    Text("DEBUG Program Start Date: \(program.startDate)")
                                        .font(.caption)
                                        .foregroundColor(.cyan)
                                        .accessibilityIdentifier("DebugProgramStartDateLabel")
                                }
                                Text("DEBUG: Program Setup Screen")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                    .accessibilityIdentifier("DebugSetupScreenLabel")
                                if let program = storedProgram {
                                    Text("Saved Program UUID: \(program.id.uuidString)")
                                        .font(.caption)
                                        .foregroundColor(.pink)
                                        .accessibilityIdentifier("DebugSavedProgramUUIDLabel")
                                    Text("Start Date: \(program.startDate)")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                    Text("Number of Days: \(program.numberOfDays())")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                    Text("Task Count: \(program.tasks().count)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    Text("Task Titles: \(program.tasks().map { $0.title }.joined(separator: ", "))")
                                        .font(.caption)
                                        .foregroundColor(.purple)
                                } else {
                                    Text("No program saved.")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding()
                        )
                    }
                }).padding(.top, 80)
                .environmentObject(debugState)
            }
                                    .environmentObject(appState)
                        .environmentObject(updateChecker)
                        .environmentObject(themeManager)
                        .preferredColorScheme(themeManager.colorScheme)
            .onAppear {
                // Check for updates when main content appears (backup)
                updateChecker.checkForUpdates()
            }
            }
        }
    }
}
