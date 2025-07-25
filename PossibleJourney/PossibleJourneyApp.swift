//
//  PossibleJourneyApp.swift
//  PossibleJourney
//
//  Created by Ted Possible on 7/22/25.
//

import SwiftUI
import Foundation

// Global DebugWindow for all screens
import SwiftUI

struct GlobalDebugWindow: View {
    @AppStorage("debug") var debug: Bool = false
    @AppStorage("debugWindowExpanded") var debugWindowExpanded: Bool = true
    @EnvironmentObject var appState: ProgramAppState
    var checklistDebugContent: () -> AnyView
    var body: some View {
        if debug {
            DebugWindow(isExpanded: $debugWindowExpanded) {
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
    init() {
        print("DEBUG: PossibleJourneyApp init")
        resetForUITestingIfNeeded()
    }
    @StateObject private var appState = ProgramAppState()
    var currentTimeOverride: Date? {
        if let idx = CommandLine.arguments.firstIndex(of: "--uitesting-current-time"),
           CommandLine.arguments.count > idx + 1,
           let timestamp = Double(CommandLine.arguments[idx + 1]) {
            return Date(timeIntervalSince1970: timestamp)
        }
        return nil
    }
    var body: some Scene {
        print("DEBUG: Launching DailyChecklistView with now = \(currentTimeOverride ?? Date())")
        return WindowGroup {
            ZStack(alignment: .top) {
                NavigationStack {
                    if let program = appState.loadedProgram {
                        let now = currentTimeOverride ?? Date()
                        let activeDay = program.nextActiveDay(currentDate: now) ?? Calendar.current.startOfDay(for: now)
                        let dailyProgress = DailyProgressStorage().load(for: activeDay) ?? DailyProgress(id: UUID(), date: activeDay, completedTaskIDs: [])
                        DailyChecklistView(
                            viewModel: DailyChecklistViewModel(
                                program: program,
                                dailyProgress: dailyProgress,
                                now: now
                            ),
                            onReset: {
                                appState.loadedProgram = nil
                                ProgramStorage().clear()
                            },
                            currentTimeOverride: currentTimeOverride
                        )
                    } else {
                        ProgramSetupView(onSave: { program in
                            appState.loadedProgram = program
                            ProgramStorage().save(program)
                        })
                    }
                }
                // Global DebugWindow always visible at top
                GlobalDebugWindow(checklistDebugContent: {
                    if let program = appState.loadedProgram {
                        let now = currentTimeOverride ?? Date()
                        let activeDay = program.nextActiveDay(currentDate: now) ?? Calendar.current.startOfDay(for: now)
                        let dailyProgress = DailyProgressStorage().load(for: activeDay) ?? DailyProgress(id: UUID(), date: activeDay, completedTaskIDs: [])
                        let viewModel = DailyChecklistViewModel(program: program, dailyProgress: dailyProgress, now: now)
                        return AnyView(Group {
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
                            Text("TaskTitles: \(viewModel.program.tasks.map { $0.title }.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .accessibilityIdentifier("TaskTitlesDebug")
                            Text("TaskIDs: \(viewModel.program.tasks.map { $0.id.uuidString }.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.purple)
                                .accessibilityIdentifier("TaskIDsDebug")
                        })
                    } else {
                        return AnyView(EmptyView())
                    }
                })
            }
        }
    }
}
