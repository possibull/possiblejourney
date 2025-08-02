import SwiftUI
import Foundation

class DebugState: ObservableObject {
    @AppStorage("debug") var debug: Bool = false
    @AppStorage("debugWindowExpanded") var debugWindowExpanded: Bool = false // Minimized by default
}

struct SettingsView: View {
    @Binding var endOfDayTime: Date
    @EnvironmentObject var debugState: DebugState
    @EnvironmentObject var appState: ProgramAppState
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()
            
            Text("This is a test settings view")
                .padding()
            
            Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}