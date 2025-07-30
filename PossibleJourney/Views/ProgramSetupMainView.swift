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
    
    let onProgramCreated: (Program) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if showingTemplateSelection {
                    ProgramTemplateSelectionView(
                        onTemplateSelected: { template in
                            let program = template.createProgram()
                            onProgramCreated(program)
                        },
                        onCustomProgram: {
                            showingCustomSetup = true
                        }
                    )
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
            .navigationTitle("Create Program")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ProgramSetupMainView { _ in }
} 