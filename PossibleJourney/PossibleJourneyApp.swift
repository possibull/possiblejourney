//
//  PossibleJourneyApp.swift
//  PossibleJourney
//
//  Created by Ted Possible on 7/22/25.
//

import SwiftUI

@main
struct PossibleJourneyApp: App {
    @State private var showChecklist = false
    @State private var savedProgram: Program? = nil

    init() {
        print("DEBUG: PossibleJourneyApp init called")
        // Load the saved program on launch
        if let loaded = ProgramStorage().load() {
            savedProgram = loaded
            showChecklist = true
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if showChecklist, let program = savedProgram {
                    DailyChecklistView(program: program, onReset: {
                        showChecklist = false
                        savedProgram = nil
                        ProgramStorage().clear()
                    })
                } else {
                    ProgramSetupView(onSave: { program in
                        savedProgram = program
                        showChecklist = true
                        ProgramStorage().save(program)
                    })
                }
            }
        }
    }
}
