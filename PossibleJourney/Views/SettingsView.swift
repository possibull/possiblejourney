import SwiftUI

struct SettingsView: View {
    var onReset: (() -> Void)? = nil
    @AppStorage("endOfDayTime") private var endOfDayTime: Date = Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22) // Default 10pm
    // 75 Hard deep red
    let hardRed = Color(red: 183/255, green: 28/255, blue: 28/255)
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Text("Settings")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(.top)
                // End of Day Time Picker Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("End of Day Time")
                        .font(.headline)
                        .foregroundColor(hardRed)
                    DatePicker("End of Day", selection: $endOfDayTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .accessibilityIdentifier("EndOfDayTimePicker")
                        .colorScheme(.dark)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                // Reset Button
                Button(action: {
                    ProgramStorage().clear()
                    onReset?()
                }) {
                    Text("Reset Program")
                        .foregroundColor(.red)
                        .font(.headline)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
        }
        .tint(hardRed)
    }
} 