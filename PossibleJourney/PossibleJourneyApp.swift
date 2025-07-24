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
    }
}

@main
struct PossibleJourneyApp: App {
    init() {
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
        WindowGroup {
            NavigationStack {
                if let program = appState.loadedProgram {
                    DailyChecklistView(program: program, onReset: {
                        appState.loadedProgram = nil
                        ProgramStorage().clear()
                    }, currentTimeOverride: currentTimeOverride)
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
