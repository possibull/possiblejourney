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
    @EnvironmentObject var celebrationManager: CelebrationManager
    @Environment(\.dismiss) private var dismiss
    @State private var forceRefresh = false
    
    // Check for August 4th birthday theme activation
    private func checkAugust4thBirthdayActivation() {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        
        // Check if it's August 4th, 2025
        if components.year == 2025 && components.month == 8 && components.day == 4 {
            // If user is currently on Bea theme, activate birthday theme
            if themeManager.currentTheme == .bea {
                print("🎂 August 4th, 2025 detected in Settings! Activating Birthday theme!")
                DispatchQueue.main.async {
                    themeManager.changeTheme(to: .birthday)
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Test simplified theme-aware background
            Rectangle()
                .fill(Color.clear)
                .themeAwareBackground()
                .ignoresSafeArea()
                .onAppear {
                    // Check for August 4th birthday theme activation
                    checkAugust4thBirthdayActivation()
                }
            
            ScrollView {
                VStack(spacing: 32) {
                    // Settings Cards
                    VStack(spacing: 20) {
                        // Program Settings Card
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Image(systemName: "gear")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.blue)
                                    .frame(width: 40, height: 40)
                                    .background(Circle().fill(Color.blue.opacity(0.1)))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Program Settings")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("Configure your daily routine")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            
                            // End of Day Time Setting
                            VStack(spacing: 16) {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.blue)
                                        .frame(width: 32, height: 32)
                                        .background(Circle().fill(Color.blue.opacity(0.1)))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("End of Day Time")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                        Text("When your daily tasks reset")
                                            .font(.system(size: 14, weight: .regular, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                
                                DatePicker("End of Day Time", selection: $endOfDayTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .accessibilityIdentifier("EndOfDayTimePicker")
                                    .onChange(of: endOfDayTime) { oldValue, newValue in
                                        let calendar = Calendar.current
                                        let comps = calendar.dateComponents([.hour, .minute], from: newValue)
                                        endOfDayTime = calendar.date(bySettingHour: comps.hour ?? 0, minute: comps.minute ?? 0, second: 0, of: Date()) ?? newValue
                                    }
                            }
                        }
                        .padding(20)
                        .themeAwareCard()
                        
                        // Celebration Settings Card
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Image(systemName: "party.popper.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.pink)
                                    .frame(width: 40, height: 40)
                                    .background(Circle().fill(Color.pink.opacity(0.1)))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Celebration Settings")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("Configure completion celebrations")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            
                            VStack(spacing: 16) {
                                // Enable/Disable Celebrations
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.pink)
                                        .frame(width: 32, height: 32)
                                        .background(Circle().fill(Color.pink.opacity(0.1)))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Enable Celebrations")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                        Text("Show celebrations when all tasks are completed")
                                            .font(.system(size: 14, weight: .regular, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    
                                    Toggle("", isOn: $celebrationManager.celebrationEnabled)
                                        .toggleStyle(SwitchToggleStyle(tint: .pink))
                                        .accessibilityIdentifier("CelebrationToggle")
                                }
                                
                                // Celebration Type Selection
                                if celebrationManager.celebrationEnabled {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.pink)
                                                .frame(width: 32, height: 32)
                                                .background(Circle().fill(Color.pink.opacity(0.1)))
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Celebration Type")
                                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                    .foregroundColor(.primary)
                                                Text("Choose your preferred celebration style")
                                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                        }
                                        
                                        Picker("Celebration Type", selection: $celebrationManager.celebrationType) {
                                            ForEach(CelebrationType.allCases) { type in
                                                HStack {
                                                    Image(systemName: type.icon)
                                                        .foregroundColor(.pink)
                                                    Text(type.displayName)
                                                }
                                                .tag(type)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .accentColor(.pink)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .themeAwareCard()
                        
                        // Development Settings Card
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Image(systemName: "ladybug.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.orange)
                                    .frame(width: 40, height: 40)
                                    .background(Circle().fill(Color.orange.opacity(0.1)))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Development")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("Debug and testing options")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: "terminal.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.orange)
                                    .frame(width: 32, height: 32)
                                    .background(Circle().fill(Color.orange.opacity(0.1)))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Debug Mode")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("Show debug information")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                
                                Toggle("", isOn: $debugState.debug)
                                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                                    .accessibilityIdentifier("DebugToggle")
                            }
                        }
                        .padding(20)
                        .themeAwareCard()
                        
                        // App Information Card
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.green)
                                    .frame(width: 40, height: 40)
                                    .background(Circle().fill(Color.green.opacity(0.1)))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("App Information")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("Version and build details")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Version")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Text("Build")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(20)
                        .themeAwareCard()
                        
                        // Select Another Program Card
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.blue)
                                    .frame(width: 40, height: 40)
                                    .background(Circle().fill(Color.blue.opacity(0.1)))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Select Another Program")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("Choose a different program to follow")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            
                            Button(action: {
                                // Navigate to ProgramSelect screen by clearing the loaded program
                                print("Settings: Select Another Program button tapped")
                                print("Settings: Current loadedProgram: \(appState.loadedProgram?.id.uuidString ?? "nil")")
                                
                                // First dismiss the Settings view
                                dismiss()
                                
                                // Then clear the program to trigger navigation to ProgramSelect
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    appState.loadedProgram = nil
                                    print("Settings: Set loadedProgram to nil - navigating to ProgramSelect")
                                }
                            }) {
                                HStack {
                                    Image(systemName: "list.bullet")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(Circle().fill(Color.blue))
                                    
                                    Text("Select Another Program")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue))
                                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .accessibilityIdentifier("SelectAnotherProgramButton")
                        }
                        .padding(20)
                        .themeAwareCard()
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.blue.opacity(0.2), lineWidth: 1))
                        
                        // Reset All Preferences Card
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Image(systemName: "trash.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.orange)
                                    .frame(width: 40, height: 40)
                                    .background(Circle().fill(Color.orange.opacity(0.1)))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Reset All Preferences")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("Clear all app data and settings")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            
                            Button(action: {
                                ProgramStorage().clear()
                                DailyProgressStorage().clearAll()
                                UserDefaults.standard.removeObject(forKey: "debug")
                                UserDefaults.standard.removeObject(forKey: "debugWindowExpanded")
                                appState.loadedProgram = nil
                                debugState.debug = false
                                debugState.debugWindowExpanded = false
                                forceRefresh.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "trash.circle.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(Circle().fill(Color.orange))
                                    
                                    Text("Reset All Preferences")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange))
                                .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .accessibilityIdentifier("ResetPreferencesButton")
                        }
                        .padding(20)
                        .themeAwareCard()
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.orange.opacity(0.2), lineWidth: 1))
                        .padding(.bottom, 32)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}