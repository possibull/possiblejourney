import SwiftUI
import Foundation

struct DailyChecklistView: View {
    let program: Program
    @State private var showSettings = false
    @State private var showCalendar = false
    @State private var completedTaskIDs: Set<UUID> = []
    @AppStorage("endOfDayTime") private var endOfDayTime: Date = Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22) // Default 10pm
    var onReset: (() -> Void)? = nil
    
    // 75 Hard deep red
    let hardRed = Color(red: 183/255, green: 28/255, blue: 28/255)
    
    private var currentDay: Int {
        let start = Calendar.current.startOfDay(for: program.startDate)
        let today = Calendar.current.startOfDay(for: Date())
        let diff = Calendar.current.dateComponents([.day], from: start, to: today).day ?? 0
        return min(max(diff + 1, 1), program.numberOfDays)
    }
    private var formattedDate: String {
        let today = Calendar.current.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: today)
    }
    var body: some View {
        ZStack {
            // Hidden debug element for UI tests, outside the main VStack
            Text(program.tasks.map { $0.id.uuidString }.joined(separator: ","))
                .accessibilityIdentifier("TaskIDsDebug")
                .opacity(0)
            Text(completedTaskIDs.map { $0.uuidString }.joined(separator: ","))
                .accessibilityIdentifier("CompletedTaskIDsDebug")
                .opacity(0)
            VStack(spacing: 0) {
                // Header row with logo, DAY XX, and checklist icon
                HStack(alignment: .center) {
                    // Circle with total number of days in program (restored)
                    ZStack {
                        Circle().fill(Color.white).frame(width: 40, height: 40)
                        Text("\(program.numberOfDays)")
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundColor(hardRed)
                    }
                    HStack(spacing: 6) {
                        Text("DAY \(currentDay)")
                            .font(.system(size: 36, weight: .heavy))
                            .foregroundColor(.white)
                        Text("OF \(program.numberOfDays)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .baselineOffset(10)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    // Checklist icon placeholder
                    Image(systemName: "checklist")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 24)
                .padding(.horizontal)
                .accessibilityElement()
                .accessibilityIdentifier("ChecklistScreenHeader")
                // Date below header
                Text(formattedDate)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom, 16)
                // Task list
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(program.tasks, id: \.id) { task in
                            let isCompleted = completedTaskIDs.contains(task.id)
                            VStack(spacing: 0) {
                                HStack(alignment: .center, spacing: 16) {
                                    Button(action: {
                                        if isCompleted {
                                            completedTaskIDs.remove(task.id)
                                        } else {
                                            completedTaskIDs.insert(task.id)
                                        }
                                        // Save progress to storage
                                        let progress = DailyProgress(id: UUID(), date: Calendar.current.startOfDay(for: Date()), completedTaskIDs: Array(completedTaskIDs))
                                        DailyProgressStorage().save(progress: progress)
                                    }) {
                                        ZStack {
                                            Circle()
                                                .strokeBorder(Color.white, lineWidth: 2)
                                                .background(Circle().fill(isCompleted ? hardRed : Color.black))
                                                .frame(width: 32, height: 32)
                                            if isCompleted {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .accessibilityIdentifier("checkmark")
                                            }
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    Text(task.title)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                        .strikethrough(isCompleted, color: hardRed)
                                    Spacer()
                                    // Optional: right-side icon placeholder (e.g., camera)
                                }
                                .padding(.vertical, 18)
                                // Add Reminder row
                                HStack(spacing: 8) {
                                    Image(systemName: "clock.badge.plus")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("Add Reminder")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                    Spacer()
                                }
                                .padding(.bottom, 8)
                                .padding(.leading, 48)
                                // Separator
                                Rectangle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(height: 1)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
                // NOTES section
                VStack(alignment: .leading, spacing: 8) {
                    Text("NOTES:")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.white)
                    Divider().background(Color.white)
                    Text("Make notes of any challenges, insights, or breakthroughs you achieve.")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 2)
                        .background(Color.black)
                )
                .padding([.horizontal, .bottom])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("DailyChecklistScreen")
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            // Load today's progress from storage
            let today = Calendar.current.startOfDay(for: Date())
            if let progress = DailyProgressStorage().load(for: today) {
                completedTaskIDs = Set(progress.completedTaskIDs)
                print("DEBUG: Loaded completedTaskIDs from storage: \(progress.completedTaskIDs)")
            } else {
                print("DEBUG: No DailyProgress found for today")
            }
            print("DEBUG: Task IDs in checklist:")
            for task in program.tasks {
                print("DEBUG: Task title: \(task.title), id: \(task.id)")
            }
            print("DEBUG: completedTaskIDs in state: \(completedTaskIDs)")
            // Write completedTaskIDs to a file for debugging
            let idsString = completedTaskIDs.map { $0.uuidString }.joined(separator: ",")
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = dir.appendingPathComponent("completedTaskIDs.txt")
                print("DEBUG: Attempting to write completedTaskIDs to file at: \(fileURL.path)")
                do {
                    try idsString.write(to: fileURL, atomically: true, encoding: .utf8)
                    print("DEBUG: Successfully wrote completedTaskIDs to file at: \(fileURL.path)")
                } catch {
                    print("DEBUG: Failed to write completedTaskIDs to file at: \(fileURL.path), error: \(error)")
                }
            } else {
                print("DEBUG: Could not find documents directory to write completedTaskIDs.txt")
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { showCalendar = true }) {
                    Image(systemName: "calendar")
                        .foregroundColor(hardRed)
                }
                .accessibilityIdentifier("CalendarButton")
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape")
                        .foregroundColor(hardRed)
                }
                .accessibilityIdentifier("SettingsButton")
            }
        }
        .sheet(isPresented: $showCalendar) {
            // For now, use today and demo completed dates
            let today = Calendar.current.startOfDay(for: Date())
            let completed = Set([0, 1, 2, 10, 15].compactMap { Calendar.current.date(byAdding: .day, value: $0, to: today) })
            ProgramCalendarView(startDate: today, numberOfDays: 75, completedDates: completed)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(onReset: {
                showSettings = false
                onReset?()
            })
        }
    }
}

struct SettingsView: View {
    var onReset: (() -> Void)? = nil
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Text("Settings")
                    .font(.largeTitle.bold())
                    .padding(.top)
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

#Preview {
    DailyChecklistView(program: Program(
        id: UUID(),
        startDate: Date(),
        numberOfDays: 75,
        tasks: [
            Task(id: UUID(), title: "Drink 1 gallon of water", description: nil),
            Task(id: UUID(), title: "Read 10 pages", description: nil),
            Task(id: UUID(), title: "Follow a diet", description: nil)
        ]
    ))
} 