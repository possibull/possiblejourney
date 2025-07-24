import SwiftUI
import Foundation

// Wrapper for Identifiable UUID for sheet
struct TaskIDWrapper: Identifiable, Equatable {
    let id: UUID
}

struct DailyChecklistView: View {
    @State var program: Program
    @State private var showSettings = false
    @State private var showCalendar = false
    @State private var showSettingsNav = false
    @State private var showMissedDayModal = false
    @State private var completedTaskIDs: Set<UUID> = []
    @State private var hideCompletedTasks = false
    @State private var notesForTask: [UUID: String] = [:]
    // Wrapper for Identifiable UUID for sheet
    @State private var notesSheetTaskID: TaskIDWrapper? = nil
    @State private var notesSheetText: String = ""
    @State private var reminderAlertTaskID: UUID? = nil
    // endOfDayTime is now part of Program
    var onReset: (() -> Void)? = nil
    var currentTimeOverride: Date? = nil // For test injection
    
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
    // Helper to compute app day start and end based on endOfDayTime
    private func appDayBounds(for date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let endHour = calendar.component(.hour, from: program.endOfDayTime)
        let endMinute = calendar.component(.minute, from: program.endOfDayTime)
        let startOfToday = calendar.startOfDay(for: date)
        var endOfAppDay: Date
        if endHour < 12 {
            // AM: end of day is next calendar day at that time
            let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
            endOfAppDay = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: nextDay) ?? date
        } else {
            // PM: end of day is today at that time
            endOfAppDay = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: startOfToday) ?? date
        }
        // Start of app day is previous end of day + 1 second
        let startOfAppDay = calendar.date(byAdding: .second, value: 1, to: endOfAppDay.addingTimeInterval(-86400)) ?? date
        return (startOfAppDay, endOfAppDay)
    }

    private var isAfterEndOfDay: Bool {
        let now = currentTimeOverride ?? Date()
        let bounds = appDayBounds(for: now)
        return now >= bounds.end
    }

    private var appToday: Date {
        // Returns the app's logical "today" date (start of app day)
        let now = currentTimeOverride ?? Date()
        let bounds = appDayBounds(for: now)
        return bounds.start
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
                        Circle().fill(Color.white).frame(width: 48, height: 48)
                        Text("\(program.numberOfDays)")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundColor(hardRed)
                    }
                    HStack(spacing: 6) {
                        Text("DAY \(currentDay)")
                            .font(.system(size: 40, weight: .black))
                            .foregroundColor(.white)
                        Text("OF \(program.numberOfDays)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .baselineOffset(12)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    // Checklist icon toggle for hiding/showing finished tasks
                    Button(action: { hideCompletedTasks.toggle() }) {
                        Image(systemName: hideCompletedTasks ? "checklist.checked" : "checklist")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .opacity(hideCompletedTasks ? 0.7 : 1.0)
                    }
                    .accessibilityIdentifier("ChecklistToggleButton")
                }
                .padding(.top, 32)
                .padding(.horizontal)
                .accessibilityElement()
                .accessibilityIdentifier("ChecklistScreenHeader")
                // Date below header
                Text(formattedDate)
                    .font(.headline.weight(.medium))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.bottom, 24)
                // Checklist Card
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(red: 24/255, green: 24/255, blue: 24/255))
                        .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 6)
                    // Break up filtered tasks for type-checking
                    let visibleTasks: [Task] = program.tasks.filter { !hideCompletedTasks || !completedTaskIDs.contains($0.id) }
                    List {
                        ForEach(visibleTasks, id: \.id) { task in
                            let isCompleted = completedTaskIDs.contains(task.id)
                            HStack(alignment: .center, spacing: 16) {
                                // Notes icon
                                Button(action: {
                                    notesSheetTaskID = TaskIDWrapper(id: task.id)
                                    notesSheetText = notesForTask[task.id, default: ""]
                                }) {
                                    Image(systemName: "note.text")
                                        .foregroundColor(Color.purple)
                                        .font(.system(size: 20, weight: .medium))
                                }
                                .accessibilityIdentifier("NotesButton_\(task.id.uuidString)")
                                Button(action: {
                                    if isCompleted {
                                        completedTaskIDs.remove(task.id)
                                    } else {
                                        completedTaskIDs.insert(task.id)
                                    }
                                    // Haptic feedback
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    // Save progress to storage
                                    let progress = DailyProgress(id: UUID(), date: appToday, completedTaskIDs: Array(completedTaskIDs))
                                    DailyProgressStorage().save(progress: progress)
                                }) {
                                    ZStack {
                                        Circle()
                                            .strokeBorder(isCompleted ? hardRed : Color.white, lineWidth: 3)
                                            .background(Circle().fill(isCompleted ? hardRed : Color.black))
                                            .frame(width: 36, height: 36)
                                            .shadow(color: isCompleted ? hardRed.opacity(0.3) : .clear, radius: 6, x: 0, y: 2)
                                        if isCompleted {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(.white)
                                                .scaleEffect(isCompleted ? 1.2 : 1.0)
                                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCompleted)
                                                .accessibilityIdentifier("checkmark")
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                Text(task.title)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.white)
                                    .strikethrough(isCompleted, color: hardRed)
                                Spacer()
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(Color.white.opacity(0.35))
                                    .font(.system(size: 20, weight: .medium))
                                    .padding(.trailing, 4)
                                    .accessibilityHidden(true)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 32/255, green: 32/255, blue: 32/255))
                                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                            )
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    // Request notification permission and schedule a local notification (demo: 5 seconds from now)
                                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                                        if granted {
                                            let content = UNMutableNotificationContent()
                                            content.title = "Task Reminder"
                                            content.body = task.title
                                            content.sound = .default
                                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                                            let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
                                            UNUserNotificationCenter.current().add(request)
                                        }
                                    }
                                } label: {
                                    Label("Remind Me", systemImage: "bell")
                                }
                                .tint(Color.purple)
                            }
                        }
                        .onMove { indices, newOffset in
                            program.tasks.move(fromOffsets: indices, toOffset: newOffset)
                            ProgramStorage().save(program)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .padding([.horizontal, .bottom], 8)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 16)
            }
            // NavigationLink for SettingsView
            NavigationLink(destination: SettingsView(onReset: {
                showSettingsNav = false
                onReset?()
            }, endOfDayTime: $program.endOfDayTime), isActive: $showSettingsNav) {
                EmptyView()
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("DailyChecklistScreen")
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            // Load today's progress from storage using appToday
            let today = appToday
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
            // Debug: Print current time, computed endOfAppDay, and isAfterEndOfDay
            let now = currentTimeOverride ?? Date()
            let bounds = appDayBounds(for: now)
            print("DEBUG: Now: \(now)")
            print("DEBUG: Computed endOfAppDay: \(bounds.end)")
            print("DEBUG: isAfterEndOfDay: \(isAfterEndOfDay)")
            // Show missed day modal if after end of day and not all tasks are complete
            if isAfterEndOfDay && completedTaskIDs.count < program.tasks.count {
                showMissedDayModal = true
            }
        }
        .onChange(of: program.endOfDayTime) { newValue in
            ProgramStorage().save(program)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { showCalendar = true }) {
                    Image(systemName: "calendar")
                        .foregroundColor(hardRed)
                }
                .accessibilityIdentifier("CalendarButton")
                Button(action: { showSettingsNav = true }) {
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
        // Missed Day Modal
        .sheet(isPresented: $showMissedDayModal) {
            VStack(spacing: 24) {
                Text("Did you miss yesterday?")
                    .font(.title.bold())
                    .foregroundColor(hardRed)
                Text("It looks like you didn't complete all your tasks before your end of day. Please confirm if you missed the day or want to continue.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                HStack(spacing: 16) {
                    Button("I Missed It") {
                        showMissedDayModal = false
                        // Handle missed day logic here
                    }
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(8)
                    Button("Continue Anyway") {
                        showMissedDayModal = false
                        // Handle continue logic here
                    }
                    .padding()
                    .background(hardRed.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            .padding()
            .accessibilityIdentifier("MissedDayModal")
        }
        // Dedicated subview for editing notes
        .sheet(item: $notesSheetTaskID) { wrapper in
            let taskID = wrapper.id
            let task = program.tasks.first(where: { $0.id == taskID })
            TaskNotesSheet(
                title: task?.title ?? "",
                note: $notesSheetText,
                onDone: {
                    notesForTask[taskID] = notesSheetText
                    notesSheetTaskID = nil
                }
            )
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
        ],
        endOfDayTime: Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22) // Default 10pm
    ))
} 

// Dedicated subview for editing notes
struct TaskNotesSheet: View {
    let title: String
    @Binding var note: String
    var onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notes for Task")
                .font(.headline)
            Text(title)
                .font(.title3.bold())
            TextEditor(text: $note)
                .frame(minHeight: 120)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            Spacer()
            Button("Done") { onDone() }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .padding()
    }
} 