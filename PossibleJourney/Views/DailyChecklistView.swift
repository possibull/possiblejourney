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
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                    .accessibilityIdentifier("ExpandDebugWindow")
                // Removed the Debug (tap to expand/minimize) text
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.5))
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
                .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
                .background(Color.black.opacity(0.6))
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
    @StateObject private var viewModel: DailyChecklistViewModel
    @State private var showingSettings = false
    @State private var showingCalendar = false
    
    init() {
        // Load the current program and daily progress from storage
        let programStorage = ProgramStorage()
        let dailyProgressStorage = DailyProgressStorage()
        
        let program = programStorage.load() ?? Program(
            id: UUID(),
            startDate: Date(),
            endOfDayTime: Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22),
            lastCompletedDay: nil,
            templateID: UUID(), // This will be set when a program is actually created
            customNumberOfDays: nil
        )
        
        let today = Date()
        let dailyProgress = dailyProgressStorage.load(for: today) ?? DailyProgress(
            id: UUID(),
            date: today,
            completedTaskIDs: []
        )
        
        _viewModel = StateObject(wrappedValue: DailyChecklistViewModel(
            program: program,
            dailyProgress: dailyProgress
        ))
    }
    
    var body: some View {
        ZStack {
            // Light background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            if viewModel.isDayMissed {
                missedDayScreen
            } else {
                checklistContent
            }
        }
        .navigationTitle("Daily Checklist")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    calendarLink
                    settingsLink
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(endOfDayTime: $viewModel.program.endOfDayTime)
        }
        .sheet(isPresented: $showingCalendar) {
            NavigationView {
                ProgramCalendarView(
                    startDate: viewModel.program.startDate,
                    numberOfDays: viewModel.program.numberOfDays(),
                    completedDates: viewModel.getCompletedDates()
                )
                .navigationTitle("Program Calendar")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingCalendar = false
                        }
                    }
                }
            }
        }
    }
    
    private var missedDayScreen: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("You missed yesterday!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("You need to complete all tasks for the missed days to continue your program.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                Button("I Missed It") {
                    viewModel.resetProgramToToday()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(12)
                
                Button("Continue Anyway") {
                    viewModel.ignoreMissedDayForCurrentSession = true
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var checklistContent: some View {
        VStack(spacing: 0) {
            headerView
            
            taskListView
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Day \(currentDay) of \(viewModel.program.numberOfDays())")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(viewModel.program.startDate, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(completedTasksCount)/\(viewModel.program.tasks().count)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("tasks completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar
            ProgressView(value: progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var taskListView: some View {
        List {
            ForEach(viewModel.program.tasks(), id: \.id) { task in
                TaskRowView(
                    task: task,
                    isCompleted: viewModel.dailyProgress.completedTaskIDs.contains(task.id),
                    onToggle: {
                        toggleTask(task)
                    },
                    onSetReminder: {
                        // TODO: Implement reminder functionality
                        print("Set reminder for task: \(task.title)")
                    }
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button("Reminder") {
                        // TODO: Implement reminder functionality
                        print("Set reminder for task: \(task.title)")
                    }
                    .tint(.orange)
                }
            }
            .onMove(perform: moveTasks)
        }
        .listStyle(PlainListStyle())
        .onAppear {
            // Debug: Print task information to help identify missing descriptions
            print("=== Task Debug Info ===")
            for (index, task) in viewModel.program.tasks().enumerated() {
                print("Task \(index + 1): '\(task.title)' - Description: '\(task.description ?? "nil")'")
            }
            print("=======================")
        }
    }
    
    private var calendarLink: some View {
        Button(action: {
            showingCalendar = true
        }) {
            Image(systemName: "calendar")
                .foregroundColor(.blue)
        }
    }
    
    private var settingsLink: some View {
        Button(action: {
            showingSettings = true
        }) {
            Image(systemName: "gearshape.fill")
                .foregroundColor(.blue)
        }
    }
    
    // Computed properties
    private var currentDay: Int {
        let start = Calendar.current.startOfDay(for: viewModel.program.startDate)
        let today = Calendar.current.startOfDay(for: Date())
        let diff = Calendar.current.dateComponents([.day], from: start, to: today).day ?? 0
        return min(max(diff + 1, 1), viewModel.program.numberOfDays())
    }
    
    private var completedTasksCount: Int {
        viewModel.dailyProgress.completedTaskIDs.count
    }
    
    private var progressPercentage: Double {
        guard !viewModel.program.tasks().isEmpty else { return 0 }
        return Double(completedTasksCount) / Double(viewModel.program.tasks().count)
    }
    
    private func toggleTask(_ task: Task) {
        var completed = Set(viewModel.dailyProgress.completedTaskIDs)
        if completed.contains(task.id) {
            completed.remove(task.id)
        } else {
            completed.insert(task.id)
        }
        
        let newProgress = DailyProgress(
            id: viewModel.dailyProgress.id,
            date: viewModel.dailyProgress.date,
            completedTaskIDs: Array(completed)
        )
        
        viewModel.dailyProgress = newProgress
        DailyProgressStorage().save(progress: newProgress)
        
        // If all tasks are now complete, update lastCompletedDay
        if viewModel.program.tasks().allSatisfy({ completed.contains($0.id) }) {
            viewModel.completeCurrentDay()
        }
    }
    
    private func moveTasks(from source: IndexSet, to destination: Int) {
        // TODO: Implement task reordering
        // This would require updating the program template to store task order
        print("Move tasks from \(source) to \(destination)")
    }
}

struct TaskRowView: View {
    let task: Task
    let isCompleted: Bool
    let onToggle: () -> Void
    let onSetReminder: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.trailing, 4)
            
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isCompleted ? .blue : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Task content
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .strikethrough(isCompleted)
                    .multilineTextAlignment(.leading)
                
                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .strikethrough(isCompleted)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // Reminder button
            Button(action: onSetReminder) {
                Image(systemName: "bell")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    DailyChecklistView()
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