import SwiftUI

struct SettingsView: View {
    var onReset: (() -> Void)? = nil
    @AppStorage("endOfDayTime") private var endOfDayTime: Date = Calendar.current.startOfDay(for: Date()) // Default 12:00AM
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
                // End of Day Time Picker Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("End of Day Time")
                        .font(.headline)
                        .foregroundColor(hardRed)
                    DatePicker("End of Day", selection: $endOfDayTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .frame(height: 150)
                        .accessibilityIdentifier("EndOfDayTimePicker")
                        .colorScheme(.dark)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.95)))
                .padding(.horizontal)
                // Reset Button
                Button(action: {
                    ProgramStorage().clear()
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