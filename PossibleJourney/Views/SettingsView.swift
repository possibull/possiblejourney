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
    @State private var forceRefresh = false
    
    var body: some View {
        ZStack {
            // Test simplified theme-aware background
            Rectangle()
                .fill(Color.clear)
                .themeAwareBackground()
                .ignoresSafeArea()
            
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
                        
                        // Theme Settings Card
                        ThemeSettingsCard()
                        
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
                                    Text("1.0.0")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Text("Build")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("18")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(20)
                        .themeAwareCard()
                        
                        // Reset Program Card
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.red)
                                    .frame(width: 40, height: 40)
                                    .background(Circle().fill(Color.red.opacity(0.1)))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Reset Program")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("Clear current program data")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            
                            Button(action: {
                                ProgramStorage().clear()
                                DailyProgressStorage().clearAll()
                                appState.loadedProgram = nil
                            }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(Circle().fill(Color.red))
                                    
                                    Text("Reset Program")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.red))
                                .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .accessibilityIdentifier("ResetProgramButton")
                        }
                        .padding(20)
                        .themeAwareCard()
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.red.opacity(0.2), lineWidth: 1))
                        
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
                                UserDefaults.standard.removeObject(forKey: "selectedTheme")
                                UserDefaults.standard.removeObject(forKey: "debug")
                                UserDefaults.standard.removeObject(forKey: "debugWindowExpanded")
                                appState.loadedProgram = nil
                                debugState.debug = false
                                debugState.debugWindowExpanded = false
                                themeManager.changeTheme(to: .system)
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

// MARK: - Theme Settings Card
struct ThemeSettingsCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "paintbrush.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.purple)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.purple.opacity(0.1)))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Theme")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Choose your preferred appearance")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            ThemeSelectionView()
        }
        .padding(20)
        .themeAwareCard()
    }
}

// MARK: - Theme Selection View
struct ThemeSelectionView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(ThemeMode.allCases, id: \.self) { theme in
                ThemeButton(theme: theme)
            }
        }
    }
}

// MARK: - Theme Button
struct ThemeButton: View {
    let theme: ThemeMode
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                themeManager.changeTheme(to: theme)
            }
        }) {
            HStack {
                Image(systemName: theme.iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.currentTheme == theme ? .white : .purple)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(themeManager.currentTheme == theme ? Color.purple : Color.purple.opacity(0.1)))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.displayName)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(themeManager.currentTheme == theme ? .white : .primary)
                    Text(theme == .system ? "Follows system setting" : "Fixed appearance")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(themeManager.currentTheme == theme ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                if themeManager.currentTheme == theme {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(RoundedRectangle(cornerRadius: 12).fill(themeManager.currentTheme == theme ? Color.purple : Color(.systemBackground)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(themeManager.currentTheme == theme ? Color.purple : Color.gray.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityIdentifier(theme.displayName)
    }
}