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
    @EnvironmentObject var themeManager: ThemeManager
    // Minimal test-only toggle for UI test isolation
    @State private var testDebug = false
    @Environment(\.presentationMode) private var presentationMode
    // Force view refresh after Reset All
    @State private var forceRefresh = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.03)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Modern header with gradient
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Settings")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            
                            Text("Customize your program experience")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    // Modern Settings Cards
                    VStack(spacing: 20) {
                        // Program Settings Card
                        VStack(alignment: .leading, spacing: 20) {
                            // Card Header
                            HStack {
                                Image(systemName: "gear")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.blue)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(Color.blue.opacity(0.1))
                                    )
                                
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
                                        .background(
                                            Circle()
                                                .fill(Color.blue.opacity(0.1))
                                        )
                                    
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
                                        // Always use today's date for storage
                                        endOfDayTime = calendar.date(bySettingHour: comps.hour ?? 0, minute: comps.minute ?? 0, second: 0, of: Date()) ?? newValue
                                    }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                    
                        ThemeSettingsCard()
                    
                        // Development Settings Card
                        VStack(alignment: .leading, spacing: 20) {
                            // Card Header
                            HStack {
                                Image(systemName: "ladybug.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.orange)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(Color.orange.opacity(0.1))
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Development")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("Advanced settings for testing")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            
                            // Debug Mode Setting
                            HStack {
                                Image(systemName: "ladybug.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.orange)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        Circle()
                                            .fill(Color.orange.opacity(0.1))
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Debug Mode")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("Show additional information for testing")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $debugState.debug)
                                    .accessibilityIdentifier("DebugToggle")
                                    .onChange(of: debugState.debug) { oldValue, newValue in
                                        print("DEBUG TOGGLE: \(newValue)")
                                    }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                        
                        // App Information Card
                        VStack(alignment: .leading, spacing: 20) {
                            // Card Header
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.blue)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(Color.blue.opacity(0.1))
                                    )
                                
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
                            
                            // Version Information
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("App Version")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A")")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(.blue)
                                    }
                                    
                                    HStack {
                                        Text("Build Number")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text("\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A")")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                    
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
                    .background(Color(.systemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                        // Reset Program Card
                        VStack(alignment: .leading, spacing: 20) {
                            // Card Header
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.red)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(Color.red.opacity(0.1))
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Reset Program")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("Start fresh with a new program")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            
                            // Warning text
                            Text("This will permanently delete all your current program data and progress. This action cannot be undone.")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                            
                            // Reset Button
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
                                
                                // Dismiss the settings view
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Reset Program")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .accessibilityIdentifier("ResetProgramButton")
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.bottom, 16)
                        
                        // Reset All UserPreferences Card
                        VStack(alignment: .leading, spacing: 20) {
                            // Card Header
                            HStack {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.orange)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(Color.orange.opacity(0.1))
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Reset All Preferences")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("Clear all app settings and preferences")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            
                            // Warning text
                            Text("This will reset all app preferences including theme settings, debug settings, and other customizations. Your program data will remain intact.")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                            
                            // Reset Preferences Button
                            Button(action: {
                                // Clear all UserDefaults except program data
                                let defaults = UserDefaults.standard
                                let allKeys = defaults.dictionaryRepresentation().keys
                                
                                // Keep program-related keys
                                let keysToKeep = [
                                    "SavedProgram"
                                    // Note: We'll handle theme reset separately
                                ]
                                
                                // Clear all other keys
                                for key in allKeys {
                                    if !keysToKeep.contains(key) && !key.hasPrefix("dailyProgress_") {
                                        defaults.removeObject(forKey: key)
                                    }
                                }
                                
                                // Reset theme to system default and clear stored preference
                                themeManager.currentTheme = .system
                                UserDefaults.standard.removeObject(forKey: "selectedTheme")
                                
                                // Reset debug state
                                debugState.debug = false
                                debugState.debugWindowExpanded = false
                                
                                // Reset end of day time to default
                                endOfDayTime = Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22) // Default 10pm
                                
                                // Force view refresh to ensure theme changes are immediately visible
                                forceRefresh.toggle()
                                
                                // Show confirmation
                                // Note: In a real app, you might want to show an alert here
                                
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Reset All Preferences")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .accessibilityIdentifier("ResetPreferencesButton")
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.bottom, 32)
                    }
                }
                .padding(.horizontal)
            }
            .background(Color(.systemBackground))
        }
        .id("\(themeManager.currentTheme)-\(forceRefresh)") // Force entire view to refresh when theme changes or after reset
        .onReceive(themeManager.$currentTheme) { _ in
            // Force view refresh when theme changes
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

// MARK: - Theme Settings Card
struct ThemeSettingsCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Card Header
            HStack {
                Image(systemName: "paintbrush.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.purple)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.purple.opacity(0.1))
                    )
                
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
            
            // Theme Selection
            ThemeSelectionView()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .id(themeManager.currentTheme) // Force refresh when theme changes
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
                    .background(
                        Circle()
                            .fill(themeManager.currentTheme == theme ? Color.purple : Color.purple.opacity(0.1))
                    )
                
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
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.currentTheme == theme ? Color.purple : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(themeManager.currentTheme == theme ? Color.purple : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityIdentifier(theme.displayName)
    }
}