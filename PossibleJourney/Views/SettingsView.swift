import SwiftUI

struct SettingsView: View {
    var onReset: (() -> Void)? = nil
    @AppStorage("endOfDayTime") private var endOfDayTime: Date = Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22) // Default 10pm
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Text("Settings")
                    .font(.largeTitle.bold())
                    .padding(.top)
                // End of Day Time Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("End of Day Time")
                        .font(.headline)
                    DatePicker("End of Day", selection: $endOfDayTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .accessibilityIdentifier("EndOfDayTimePicker")
                }
                .padding()
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
        }
    }
} 