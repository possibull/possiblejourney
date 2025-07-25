import SwiftUI

struct SettingsView: View {
    var onReset: (() -> Void)? = nil
    @Binding var endOfDayTime: Date
    @Binding var debug: Bool
    // Minimal test-only toggle for UI test isolation
    @State private var testDebug = false
    // 75 Hard deep red
    let hardRed = Color(red: 183/255, green: 28/255, blue: 28/255)
    @Environment(\.presentationMode) private var presentationMode
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()
            VStack(spacing: 28) {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(hardRed)
                            Text("Back")
                                .font(.headline)
                                .foregroundColor(hardRed)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(0.01))
                        .cornerRadius(8)
                    }
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.horizontal)
                Text("Settings")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                // End of Day Time Picker Section in Form
                Form {
                    Section(header: Text("End of Day Time").font(.headline).foregroundColor(hardRed)) {
                        DatePicker("End of Day", selection: $endOfDayTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .accessibilityIdentifier("EndOfDayTimePicker")
                            .onChange(of: endOfDayTime) { newValue in
                                let calendar = Calendar.current
                                let comps = calendar.dateComponents([.hour, .minute], from: newValue)
                                // Always use today's date for storage
                                endOfDayTime = calendar.date(bySettingHour: comps.hour ?? 0, minute: comps.minute ?? 0, second: 0, of: Date()) ?? newValue
                            }
                    }
                    Section(header: Text("Debug").font(.headline).foregroundColor(hardRed)) {
                        Toggle("Show Debug Labels", isOn: $debug)
                            .accessibilityIdentifier("DebugToggle")
                            .onChange(of: debug) { newValue in
                                print("DEBUG TOGGLE: \(newValue)")
                            }
                    }
                }
                .cornerRadius(16)
                .padding(.horizontal)
                // Reset Button
                Button(action: {
                    ProgramStorage().clear()
                    endOfDayTime = Calendar.current.startOfDay(for: Date()) // Set to 12:00AM
                    onReset?()
                }) {
                    Text("Reset Program")
                        .foregroundColor(.red)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                Spacer()
            }
            .padding(.top, 8)
        }
        .navigationBarBackButtonHidden(true)
    }
} 