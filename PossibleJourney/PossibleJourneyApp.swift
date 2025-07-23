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

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if let program = appState.loadedProgram {
                    DailyChecklistView(program: program, onReset: {
                        appState.loadedProgram = nil
                        ProgramStorage().clear()
                    })
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
