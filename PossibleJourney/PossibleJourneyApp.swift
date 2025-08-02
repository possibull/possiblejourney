//
//  PossibleJourneyApp.swift
//  PossibleJourney
//
//  Created by Ted Possible on 7/22/25.
//

import SwiftUI
import Foundation

// MARK: - Global Theme Selector
struct GlobalThemeSelector: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingThemeMenu = false
    @State private var beaTapCount = 0
    @State private var lastBeaTapTime: Date = Date()
    
    var body: some View {
        Menu {
            ForEach(ThemeMode.allCases.filter { $0 != .birthday }, id: \.self) { theme in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        themeManager.changeTheme(to: theme)
                    }
                }) {
                    HStack {
                        Image(systemName: theme.iconName)
                        Text(theme.displayName)
                        if themeManager.currentTheme == theme {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "paintbrush.fill")
                .foregroundColor(.blue)
                .font(.system(size: 18, weight: .medium))
                .onTapGesture {
                    // Check if Bea theme is currently selected
                    if themeManager.currentTheme == .bea {
                        let now = Date()
                        if now.timeIntervalSince(lastBeaTapTime) < 2.0 {
                            beaTapCount += 1
                            if beaTapCount >= 5 {
                                // Activate Birthday theme as Easter egg
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        themeManager.changeTheme(to: .birthday)
                                    }
                                }
                                beaTapCount = 0
                            }
                        } else {
                            beaTapCount = 1
                        }
                        lastBeaTapTime = now
                    } else {
                        beaTapCount = 0
                    }
                }
        }
        .accessibilityIdentifier("GlobalThemeSelector")
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
