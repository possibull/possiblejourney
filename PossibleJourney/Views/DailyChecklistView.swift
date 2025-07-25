import SwiftUI
import Foundation
// Import the view model
import Combine

// Wrapper for Identifiable UUID for sheet
struct TaskIDWrapper: Identifiable, Equatable {
    let id: UUID
}

// Add DebugWindow reusable view
struct DebugWindow<Content: View>: View {
    @Binding var isExpanded: Bool
    let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(isExpanded ? "Debug (tap to collapse)" : "Debug (tap to expand)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.8))
            .onTapGesture {
                withAnimation { isExpanded.toggle() }
            }
            if isExpanded {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 4) {
                        content()
                    }
                    .padding(8)
                }
                .background(Color.black.opacity(0.85))
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .cornerRadius(12)
        .shadow(radius: 8)
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .zIndex(100)
    }
}

struct DailyChecklistView: View {
    @ObservedObject var viewModel: DailyChecklistViewModel
    @State private var showSettings = false
    @State private var showCalendar = false
    @State private var showSettingsNav = false
    @State private var hideCompletedTasks = false
    @State private var notesForTask: [UUID: String] = [:]
    // Wrapper for Identifiable UUID for sheet
    @State private var notesSheetTaskID: TaskIDWrapper? = nil
    @State private var notesSheetText: String = ""
    @State private var reminderAlertTaskID: UUID? = nil
    var onReset: (() -> Void)? = nil
    var currentTimeOverride: Date? = nil // For test injection
    @State private var debug = false
    @State private var debugWindowExpanded = false
    
    // 75 Hard deep red
    let hardRed = Color(red: 183/255, green: 28/255, blue: 28/255)
    
    private var currentDay: Int {
        let start = Calendar.current.startOfDay(for: viewModel.program.startDate)
        let today = Calendar.current.startOfDay(for: Date())
        let diff = Calendar.current.dateComponents([.day], from: start, to: today).day ?? 0
        return min(max(diff + 1, 1), viewModel.program.numberOfDays)
    }
    private var formattedDate: String {
        let today = Calendar.current.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: today)
    }

    var body: some View {
        ZStack(alignment: .top) {
            if viewModel.isDayMissed {
                MissedDayScreen(
                    onContinue: {
                        print("DEBUG: User clicked 'Continue Anyway' - dismissing Missed Day screen and returning to checklist (no changes to program or progress)")
                        viewModel.ignoreMissedDayForCurrentSession = true
                    },
                    onMissed: {
                        print("DEBUG: User clicked 'I Missed It' - resetting program start date to today, keeping progress for history")
                        viewModel.resetProgramToToday()
                    }
                )
                .accessibilityIdentifier("MissedDayScreen")
            } else {
                // Use currentActiveDay for checklist
                let checklistDate = viewModel.currentActiveDay ?? viewModel.now
                let visibleTasks: [Task] = viewModel.program.tasks.filter { !hideCompletedTasks || !viewModel.dailyProgress.completedTaskIDs.contains($0.id) }
                VStack(spacing: 0) {
                    // Header row with logo, DAY XX, and checklist icon
                    HStack(alignment: .center) {
                        // Circle with total number of days in program (restored)
                        ZStack {
                            Circle().fill(Color.white).frame(width: 48, height: 48)
                            Text("\(viewModel.program.numberOfDays)")
                                .font(.system(size: 22, weight: .heavy))
                                .foregroundColor(hardRed)
                        }
                        HStack(spacing: 6) {
                            Text("DAY \(currentDay)")
                                .font(.system(size: 40, weight: .black))
                                .foregroundColor(.white)
                            Text("OF \(viewModel.program.numberOfDays)")
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
                    if debug {
                        DebugWindow(isExpanded: $debugWindowExpanded) {
                            Group {
                                Text("DEBUG now: \(viewModel.now)")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                    .accessibilityIdentifier("DebugNowLabel")
                                Text("DEBUG isDayMissed: \(viewModel.isDayMissed ? "YES" : "NO")")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .accessibilityIdentifier("DebugIsDayMissedLabel")
                                Text("DEBUG completedTaskIDs: \(viewModel.dailyProgress.completedTaskIDs.map { $0.uuidString }.joined(separator: ", "))")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .accessibilityIdentifier("DebugCompletedTaskIDsLabel")
                                Text("DEBUG showMissedDayModal: \(viewModel.isDayMissed ? "YES" : "NO")")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .accessibilityIdentifier("DebugShowMissedDayModalLabel")
                                Text("TaskTitles: \(viewModel.program.tasks.map { $0.title }.joined(separator: ", "))")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .accessibilityIdentifier("TaskTitlesDebug")
                                Text("TaskIDs: \(viewModel.program.tasks.map { $0.id.uuidString }.joined(separator: ", "))")
                                    .font(.caption)
                                    .foregroundColor(.purple)
                                    .accessibilityIdentifier("TaskIDsDebug")
                            }
                        }
                    }
                    // Checklist Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(red: 24/255, green: 24/255, blue: 24/255))
                            .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 6)
                        List {
                            ForEach(visibleTasks, id: \.id) { task in
                                let isCompleted = viewModel.dailyProgress.completedTaskIDs.contains(task.id)
                                HStack(alignment: .center, spacing: 16) {
                                    Button(action: {
                                        var completed = Set(viewModel.dailyProgress.completedTaskIDs)
                                        if isCompleted {
                                            completed.remove(task.id)
                                        } else {
                                            completed.insert(task.id)
                                        }
                                        // Haptic feedback
                                        let generator = UIImpactFeedbackGenerator(style: .medium)
                                        generator.impactOccurred()
                                        // Save progress to storage
                                        let progress = DailyProgress(id: UUID(), date: viewModel.dailyProgress.date, completedTaskIDs: Array(completed))
                                        viewModel.dailyProgress = progress
                                        DailyProgressStorage().save(progress: progress)
                                        // If all tasks are now complete, update lastCompletedDay
                                        if viewModel.program.tasks.allSatisfy({ completed.contains($0.id) }) {
                                            viewModel.completeCurrentDay()
                                        }
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
                                    // Notes icon (now on the right, before handle)
                                    Button(action: {
                                        notesSheetTaskID = TaskIDWrapper(id: task.id)
                                        notesSheetText = notesForTask[task.id, default: ""]
                                    }) {
                                        Image(systemName: "note.text")
                                            .foregroundColor(Color.purple)
                                            .font(.system(size: 20, weight: .medium))
                                    }
                                    .accessibilityIdentifier("NotesButton_\(task.id.uuidString)")
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
                                viewModel.program.tasks.move(fromOffsets: indices, toOffset: newOffset)
                                ProgramStorage().save(viewModel.program)
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
                }, endOfDayTime: $viewModel.program.endOfDayTime, debug: $debug), isActive: $showSettingsNav) {
                    EmptyView()
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("DailyChecklistScreen")
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            // Update the view model's 'now' property to the injected time (for UI tests) or current time
            if let currentTimeOverride = currentTimeOverride {
                viewModel.now = currentTimeOverride
            } else {
                viewModel.now = Date()
            }
            print("DEBUG: onAppear - viewModel.now = \(viewModel.now), currentTimeOverride = \(String(describing: currentTimeOverride))")
        }
        .onChange(of: viewModel.program.endOfDayTime) { newValue in
            ProgramStorage().save(viewModel.program)
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
        // Missed Day Modal (remove this .sheet)
        // .sheet(isPresented: $showMissedDayModal) { ... }
        // Dedicated subview for editing notes
        .sheet(item: $notesSheetTaskID) { wrapper in
            let taskID = wrapper.id
            let task = viewModel.program.tasks.first(where: { $0.id == taskID })
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
    let program = Program(
        id: UUID(),
        startDate: Date(),
        numberOfDays: 75,
        tasks: [
            Task(id: UUID(), title: "Drink 1 gallon of water", description: nil),
            Task(id: UUID(), title: "Read 10 pages", description: nil),
            Task(id: UUID(), title: "Follow a diet", description: nil)
        ],
        endOfDayTime: Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22) // Default 10pm
    )
    let dailyProgress = DailyProgress(id: UUID(), date: Date(), completedTaskIDs: [])
    return DailyChecklistView(viewModel: DailyChecklistViewModel(program: program, dailyProgress: dailyProgress))
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
            Button(action: onDone) {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
    }
} 

// Add MissedDayScreen struct at the end of the file
struct MissedDayScreen: View {
    var onContinue: () -> Void
    var onMissed: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Did you miss yesterday?")
                .font(.title.bold())
                .foregroundColor(.red)
            Text("It looks like you didn't complete all your tasks before your end of day. Please confirm if you missed the day or want to continue.")
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            HStack(spacing: 16) {
                Button("I Missed It", action: onMissed)
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(8)
                    .overlay(
                        Text("Reset to Day 1")
                            .font(.caption)
                            .foregroundColor(.red)
                            .offset(y: 30)
                    )
                Button("Continue Anyway", action: onContinue)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                    .overlay(
                        Text("Advance to Next Day")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .offset(y: 30)
                    )
            }
        }
        .padding()
    }
} 