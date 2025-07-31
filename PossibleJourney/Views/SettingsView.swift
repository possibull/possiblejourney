import SwiftUI
import Foundation

class DebugState: ObservableObject {
    @AppStorage("debug") var debug: Bool = false
    @AppStorage("debugWindowExpanded") var debugWindowExpanded: Bool = false // Minimized by default
}

struct SettingsView: View {
    var onReset: (() -> Void)? = nil
    @Binding var endOfDayTime: Date
    @EnvironmentObject var debugState: DebugState
    @EnvironmentObject var appState: ProgramAppState
    // Minimal test-only toggle for UI test isolation
    @State private var testDebug = false
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Customize your program experience")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 8)
                // Settings Form
                Form {
                    Section {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("End of Day Time")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("When your daily tasks reset")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        
                        DatePicker("End of Day Time", selection: $endOfDayTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                            .accessibilityIdentifier("EndOfDayTimePicker")
                            .onChange(of: endOfDayTime) { oldValue, newValue in
                                let calendar = Calendar.current
                                let comps = calendar.dateComponents([.hour, .minute], from: newValue)
                                // Always use today's date for storage
                                endOfDayTime = calendar.date(bySettingHour: comps.hour ?? 0, minute: comps.minute ?? 0, second: 0, of: Date()) ?? newValue
                            }
                    } header: {
                        Text("Program Settings")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .textCase(.uppercase)
                            .fontWeight(.semibold)
                    }
                    
                    Section {
                        HStack {
                            Image(systemName: "ladybug.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Debug Mode")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Show additional information for testing")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $debugState.debug)
                                .accessibilityIdentifier("DebugToggle")
                                .onChange(of: debugState.debug) { oldValue, newValue in
                                    print("DEBUG TOGGLE: \(newValue)")
                                }
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("Development")
                            .font(.headline)
                            .foregroundColor(.orange)
                            .textCase(.uppercase)
                            .fontWeight(.semibold)
                    }
                    
                    Section {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("App Version")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Current version information")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .accessibilityIdentifier("AppVersionText")
                                Text("Build \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .accessibilityIdentifier("BuildNumberText")
                            }
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("About")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .textCase(.uppercase)
                            .fontWeight(.semibold)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
                // Reset Button
                VStack(spacing: 16) {
                    Button(action: {
                        // Clear all program data
                        ProgramStorage().clear()
                        DailyProgressStorage().clearAll()
                        
                        // Clear the program from app state to trigger navigation back to template selection
                        appState.loadedProgram = nil
                        
                        // Reset end of day time to default
                        endOfDayTime = Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22) // Default 10pm
                        
                        // Call the onReset callback if provided
                        onReset?()
                        
                        // Dismiss the settings sheet
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title3)
                            Text("Reset Program")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Text("This will clear all your progress and start fresh")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    presentationMode.wrappedValue.dismiss()
                }
                .fontWeight(.medium)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .fontWeight(.medium)
            }
        }
    }
} 