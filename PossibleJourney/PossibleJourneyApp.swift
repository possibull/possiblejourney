//
//  PossibleJourneyApp.swift
//  PossibleJourney
//
//  Created by Ted Possible on 7/22/25.
//

import SwiftUI

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
        }
    }
}
