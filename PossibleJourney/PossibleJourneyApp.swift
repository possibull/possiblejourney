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
    
    private let sequences = [
        ["1", "0", "0", "0", "1", "1", "1", "1"],
        ["0", "x", "8", "F"],
        ["1", "4", "3", "B"],
        ["x", "o", "o", "o", "x", "x", "x", "x"],
        ["X", "O", "O", "O", "X", "X", "X", "X"],
        [".", "-", "-", "-", ".", ".", "."],
        ["💜", "💛", "💛", "💛", "💜", "💜", "💜", "💜"]
    ]
    @State private var currentSequence: [String] = []
    @State private var isAnimating = false
    @State private var animationTimer: Timer?
    @State private var sequenceActive = false
    @State private var lastSequenceEndTime: Date = Date.distantPast
    private let displayDuration: TimeInterval = 0.8
    private let cooldownPeriod: TimeInterval = 1.0
    private let transitionDuration: TimeInterval = 0.3
    private let beeCount = 15
    
    private var themeAccentColor: Color {
        switch themeManager.currentTheme {
        case .birthday:
            return Color(red: 1.0, green: 0.95, blue: 0.7) // Pastel yellow
        case .bea:
            return Color(red: 0.9, green: 0.8, blue: 1.0) // Pastel purple for Bea theme
        case .usa:
            return Color(red: 0.8, green: 0.1, blue: 0.2) // Red for USA theme
                                case .lasVegas:
                            return Color(red: 1.0, green: 1.0, blue: 0.0) // Yellow neon (sign bulbs) for Las Vegas theme
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
        case .usa:
            return Color(red: 0.1, green: 0.3, blue: 0.8) // Blue for USA theme
                                case .lasVegas:
                            return Color(red: 1.0, green: 0.0, blue: 0.0) // Red neon (letters/star) for Las Vegas theme
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
            if currentIndex < currentSequence.count {
                Text(currentSequence[currentIndex])
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
        .onDisappear {
            // Clean up any lingering timers
            print("View disappearing, cleaning up sequence state")
            sequenceActive = false
            isAnimating = false
            lastSequenceEndTime = Date()
            animationTimer?.invalidate()
            animationTimer = nil
        }
    }
    
    private func startNumberSequence() {
        // Check cooldown period
        let timeSinceLastSequence = Date().timeIntervalSince(lastSequenceEndTime)
        guard timeSinceLastSequence >= cooldownPeriod else {
            print("Sequence in cooldown period (\(String(format: "%.1f", cooldownPeriod - timeSinceLastSequence))s remaining), ignoring start request")
            return
        }
        
        // Prevent multiple sequences from starting
        guard !sequenceActive else {
            print("Sequence already active, ignoring start request")
            return
        }
        
        // Randomly select a sequence
        currentSequence = sequences.randomElement() ?? sequences[0]
        currentIndex = 0
        isAnimating = false
        sequenceActive = true
        
        print("Starting new sequence: \(currentSequence)")
        print("Sequence length: \(currentSequence.count)")
        print("Sequence index: \(currentIndex)")
        
        // Cancel any existing timer
        animationTimer?.invalidate()
        animationTimer = nil
        
        // Start the sequence
        displayNextNumber()
    }
    
    private func displayNextNumber() {
        // Double-check we're still active
        guard sequenceActive else {
            print("Sequence no longer active, stopping")
            return
        }
        
        // Prevent multiple instances from running simultaneously
        guard !isAnimating else { 
            print("Animation already in progress, skipping")
            return 
        }
        
        guard currentIndex < currentSequence.count else {
            // Sequence complete, dismiss the sheet
            print("Sequence complete, dismissing sheet")
            sequenceActive = false
            isAnimating = false
            lastSequenceEndTime = Date()
            animationTimer?.invalidate()
            animationTimer = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
            }
            return
        }
        
        isAnimating = true
        print("Displaying item \(currentIndex + 1) of \(currentSequence.count): '\(currentSequence[currentIndex])' (index: \(currentIndex))")
        
        // Animate number appearance
        withAnimation(.easeInOut(duration: transitionDuration)) {
            numberOpacity = 1.0
            numberScale = 1.0
        }
        
        // Create a single timer for the entire sequence
        animationTimer = Timer.scheduledTimer(withTimeInterval: displayDuration + transitionDuration, repeats: false) { _ in
            DispatchQueue.main.async {
                // Check if sequence is still active
                guard self.sequenceActive else {
                    print("Sequence deactivated during timer, stopping")
                    return
                }
                
                // Animate number disappearance
                withAnimation(.easeInOut(duration: self.transitionDuration)) {
                    self.numberOpacity = 0.0
                    self.numberScale = 0.5
                }
                
                // Move to next number after transition
                DispatchQueue.main.asyncAfter(deadline: .now() + self.transitionDuration) {
                    self.currentIndex += 1
                    self.isAnimating = false
                    self.displayNextNumber()
                }
            }
        }
    }
    
    private func initializeBees() {
        beePositions = []
        beeRotations = []
        beeScales = []
        
        // Start all bees at random positions on screen
        for _ in 0..<beeCount {
            beePositions.append(CGPoint(x: CGFloat.random(in: 50...350), y: CGFloat.random(in: 50...800)))
            beeRotations.append(Double.random(in: -15...15))
            beeScales.append(CGFloat.random(in: 0.9...1.1))
        }
        
        // Start random flying animations
        startRandomBeeAnimations()
    }
    
    private func startRandomBeeAnimations() {
        // Animate each bee to fly randomly around the screen
        for i in 0..<beeCount {
            animateBeeToRandomPosition(beeIndex: i)
        }
    }
    
    private func animateBeeToRandomPosition(beeIndex: Int) {
        guard beeIndex < beePositions.count else { return }
        
        // Generate random position within screen bounds
        let newX = CGFloat.random(in: 50...350)
        let newY = CGFloat.random(in: 50...800)
        
        // Smooth, realistic animation to new position
        withAnimation(.easeInOut(duration: 2.0)) {
            beePositions[beeIndex] = CGPoint(x: newX, y: newY)
        }
        
        // Continue with next random position after a longer delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.animateBeeToRandomPosition(beeIndex: beeIndex)
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
    @EnvironmentObject var debugState: DebugState
    @State private var showingThemeMenu = false
    @State private var beaTapCount = 0
    @State private var lastBeaTapTime: Date = Date()
    @State private var showingBeaNumberSequence = false
    @State private var hiddenThemesUnlocked = false
    
    // Check for August 4th birthday theme activation
    private func checkAugust4thBirthdayActivation() {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        
        // Check if it's August 4th, 2025
        if components.year == 2025 && components.month == 8 && components.day == 4 {
            // If user is currently on Bea theme, activate birthday theme
            if themeManager.currentTheme == .bea {
                print("🎂 August 4th, 2025 detected in Theme Selector! Activating Birthday theme!")
                DispatchQueue.main.async {
                    themeManager.changeTheme(to: .birthday)
                }
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Hidden Easter egg button (only visible when Bea theme or Birthday theme is active) - moved to left
            if themeManager.currentTheme == .bea || themeManager.currentTheme == .birthday {
                Button(action: {
                    print("🎨 Easter egg button tapped! Count: \(beaTapCount + 1)")
                    let now = Date()
                    if now.timeIntervalSince(lastBeaTapTime) < 2.0 {
                        beaTapCount += 1
                        print("🎨 Bea tap count: \(beaTapCount)")
                        if beaTapCount >= 5 {
                            print("🎂 HIDDEN THEMES UNLOCKED!")
                            // Unlock hidden themes instead of directly activating birthday theme
                            hiddenThemesUnlocked = true
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
            
            // Theme selector (paintbrush)
            Menu {
                // Regular themes
                ForEach(ThemeMode.allCases.filter { $0 != .birthday && $0 != .usa && $0 != .lasVegas }, id: \.self) { theme in
                    Button(action: {

                        
                        withAnimation(.easeInOut(duration: 0.3)) {
                            themeManager.changeTheme(to: theme)
                        }
                        
                        // Check for August 4th birthday theme activation
                        checkAugust4thBirthdayActivation()
                        
                        // Trigger Bea number sequence if Bea theme is selected AND it's not August 4th
                        if theme == .bea {
                            // Check if it's August 4th using the effective date
                            let effectiveDate = themeManager.getEffectiveCurrentDate()
                            let calendar = Calendar.current
                            let components = calendar.dateComponents([.year, .month, .day], from: effectiveDate)
                            
                            let isAugust4th = components.year == 2025 && components.month == 8 && components.day == 4
                            
                            if !isAugust4th {
                                // Only show Bea sequence if it's NOT August 4th
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showingBeaNumberSequence = true
                                }
                            }
                        }
                    }) {
                                                                HStack {
                                            Image(systemName: theme.iconName)
                                                .foregroundColor(themeManager.currentTheme == theme ? .blue : .primary)
                                            Text(theme.displayName)
                                            Spacer()
                                        }
                    }
                }
                
                // Hidden themes section (only show when unlocked)
                if hiddenThemesUnlocked {
                    Divider()
                    
                    Text("Hidden Themes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    
                    // Birthday theme as first hidden theme
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            themeManager.changeTheme(to: .birthday)
                        }
                        
                        // Check for August 4th birthday theme activation
                        checkAugust4thBirthdayActivation()
                    }) {
                                                                HStack {
                                            Image(systemName: ThemeMode.birthday.iconName)
                                                .foregroundColor(themeManager.currentTheme == .birthday ? .blue : .primary)
                                            Text(ThemeMode.birthday.displayName)
                                            Spacer()
                                        }
                    }
                    
                    // USA theme as second hidden theme
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            themeManager.changeTheme(to: .usa)
                        }
                    }) {
                                                                HStack {
                                            Image(systemName: ThemeMode.usa.iconName)
                                                .foregroundColor(themeManager.currentTheme == .usa ? .blue : .primary)
                                            Text(ThemeMode.usa.displayName)
                                            Spacer()
                                        }
                    }
                    
                    // Las Vegas theme as third hidden theme
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            themeManager.changeTheme(to: .lasVegas)
                        }
                    }) {
                                                                HStack {
                                            Image(systemName: ThemeMode.lasVegas.iconName)
                                                .foregroundColor(themeManager.currentTheme == .lasVegas ? .blue : .primary)
                                            Text(ThemeMode.lasVegas.displayName)
                                            Spacer()
                                        }
                    }
                    
                    Divider()
                    
                    // Hide hidden themes option
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            hiddenThemesUnlocked = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "eye.slash.fill")
                                .foregroundColor(.secondary)
                            Text("Hide Hidden Themes")
                                .foregroundColor(.secondary)
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
            
            // Debug toggle button (ladybug icon) - only show when debug mode is enabled
            if debugState.debug {
                Button(action: {
                    debugState.debugWindowExpanded.toggle()
                    print("🐛 Debug window toggled: \(debugState.debugWindowExpanded)")
                }) {
                    Image(systemName: "ladybug.fill")
                        .foregroundColor(debugState.debugWindowExpanded ? .gray : .blue)
                        .font(.system(size: 18, weight: .medium))
                }
                .accessibilityIdentifier("DebugToggleButton")
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
        if debugState.debug && debugState.debugWindowExpanded {
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 4) {
                        checklistDebugContent()
                    }
                    .padding(8)
                }
                .frame(maxHeight: UIScreen.main.bounds.height * 0.3)
                .background(Color.black.opacity(0.8))
                .cornerRadius(12)
                .shadow(radius: 8)
                .padding(.horizontal, 8)
                .padding(.top, 8)
                .zIndex(100)
            }
        }
    }
}

func resetForUITestingIfNeeded() {
    if CommandLine.arguments.contains("--uitesting-reset") {
        ProgramStorage().clear()
        DailyProgressStorage().clearAll()
        UserDefaults.standard.removeObject(forKey: "measurements")
    }
}





@main
struct PossibleJourneyApp: App {
    @StateObject private var appState = ProgramAppState()
    @StateObject private var debugState = DebugState()
    @StateObject private var updateChecker = AppUpdateChecker()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var celebrationManager = CelebrationManager()
    @State private var showSplash = true
    @State private var forceNavigationUpdate = false
    @State private var navigationKey = UUID()
    
    init() {
        resetForUITestingIfNeeded()
        // Always minimize debug window on launch
        UserDefaults.standard.set(false, forKey: "debugWindowExpanded")
    }
    
    // Check for August 4th birthday theme activation
    private func checkAugust4thBirthdayActivation() {
        let calendar = Calendar.current
        let now = currentTimeOverride ?? Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        
        // Check if it's August 4th, 2025
        if components.year == 2025 && components.month == 8 && components.day == 4 {
            // If user is currently on Bea theme, activate birthday theme
            if themeManager.currentTheme == .bea {
                print("🎂 August 4th, 2025 detected in main app! Activating Birthday theme!")
                DispatchQueue.main.async {
                    themeManager.changeTheme(to: .birthday)
                }
            }
        }
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
                    .environmentObject(celebrationManager)
                    .onAppear {
                        // Check for updates when app starts
                        updateChecker.checkForUpdates()
                        // Check for August 4th birthday theme activation
                        checkAugust4thBirthdayActivation()
                    }
            } else {
                ZStack(alignment: .top) {
                    NavigationStack {
                        if let program = appState.loadedProgram {
                            let now = currentTimeOverride ?? Date()
                            DailyChecklistView()
                                .environmentObject(debugState)
                                .environmentObject(themeManager)
                                .environmentObject(appState)
                                .environmentObject(celebrationManager)
                                .onAppear {
                                    // Check for August 4th birthday theme activation
                                    checkAugust4thBirthdayActivation()
                                }
                        } else {
                            ProgramSetupMainView(onProgramCreated: { program in
                                appState.loadedProgram = program
                                ProgramStorage().save(program)
                            })
                            .environmentObject(debugState)
                            .environmentObject(themeManager)
                                .environmentObject(appState)
                                .environmentObject(celebrationManager)
                                .onAppear {
                                    // Check for August 4th birthday theme activation
                                    checkAugust4thBirthdayActivation()
                                }
                        }
                    }
                    .id(navigationKey)
                    
                    // Global Birthday Cake Popup
                    .sheet(isPresented: $themeManager.shouldShowBirthdayCake, onDismiss: {
                        themeManager.resetBirthdayCakeFlag()
                    }) {
                        BirthdayCakePopup()
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
