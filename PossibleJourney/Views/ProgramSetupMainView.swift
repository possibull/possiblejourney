//
//  ProgramSetupMainView.swift
//  PossibleJourney
//
//  Created by Ted Possible on 7/22/25.
//

import SwiftUI

struct ProgramSetupMainView: View {
    @State private var showingTemplateSelection = true
    @State private var showingCustomSetup = false
    @EnvironmentObject var themeManager: ThemeManager
    
    let onProgramCreated: (Program) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if showingTemplateSelection {
                ProgramTemplateSelectionView(
                    onTemplateSelected: { template in
                        let program = template.createProgram(numberOfDays: nil)
                        onProgramCreated(program)
                    },
                    onProgramCreated: { program in
                        onProgramCreated(program)
                    },
                    onCustomProgram: {
                        showingCustomSetup = true
                    }
                )
                .environmentObject(themeManager)
            } else if showingCustomSetup {
                ProgramSetupView(onSave: { program in
                    onProgramCreated(program)
                })
                .navigationTitle("Custom Program")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Back") {
                            showingCustomSetup = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ProgramSetupMainView { _ in }
} 