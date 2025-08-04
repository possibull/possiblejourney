import SwiftUI
import Foundation
// Import the view model
import Combine

// Wrapper for Identifiable UUID for sheet
struct TaskIDWrapper: Identifiable, Equatable {
    let id: UUID
}



struct DailyChecklistView: View {
    @StateObject private var viewModel: DailyChecklistViewModel
    @EnvironmentObject var appState: ProgramAppState
    @EnvironmentObject var updateChecker: AppUpdateChecker
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var debugState: DebugState
    @State private var showingCalendar = false
    @State private var autoAdvanceTimer: Timer?
    @State private var showingReleaseNotes = false
    
    // Computed property to check if current date is August 4th, 2025
    private var isAugust4th2025: Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: viewModel.selectedDate)
        return components.year == 2025 && components.month == 8 && components.day == 4
    }
    
    // Check for August 4th birthday theme activation
    private func checkAugust4thBirthdayActivation() {
        let calendar = Calendar.current
        let dateToCheck = viewModel.selectedDate // Use the view model's selected date
        let components = calendar.dateComponents([.year, .month, .day], from: dateToCheck)
        
        // Check if it's August 4th, 2025
        if components.year == 2025 && components.month == 8 && components.day == 4 {
            // If user is currently on Bea theme, activate birthday theme
            if themeManager.currentTheme == .bea {
                print("🎂 August 4th, 2025 detected in DailyChecklist (selected date: \(dateToCheck))! Activating Birthday theme!")
                DispatchQueue.main.async {
                    themeManager.changeTheme(to: .birthday)
                }
            }
        }
    }
    
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
        
        let now = Date()
        // Start with today's date - the missed day logic will handle finding the first missed day
        let today = Calendar.current.startOfDay(for: now)
        let dailyProgress = dailyProgressStorage.load(for: today) ?? DailyProgress(
            id: UUID(),
            date: today,
            completedTaskIDs: []
        )
        
        _viewModel = StateObject(wrappedValue: DailyChecklistViewModel(
            program: program,
            dailyProgress: dailyProgress,
            now: now
        ))
    }
    
    var body: some View {
        ZStack {
            // Theme-aware background
            Color.clear
                .themeAwareBackground()
                .ignoresSafeArea()
                .onAppear {
                    // Check for August 4th birthday theme activation
                    checkAugust4thBirthdayActivation()
                }
            
            VStack(spacing: 0) {
                // Update notification at the top
                UpdateNotificationView(updateChecker: updateChecker)
                
                if viewModel.isDayMissed {
                    missedDayScreen
                } else {
                    checklistContent
                }
            }
        }
        // Custom header since navigation context is unreliable
        .safeAreaInset(edge: .top) {
            VStack(spacing: 0) {
                HStack {
                    Text("Daily Checklist")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    HStack(spacing: 16) {
                        GlobalThemeSelector()
                        calendarLink
                        settingsLink
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                Divider()
            }
        }


        .sheet(isPresented: $showingCalendar) {
            NavigationView {
                ProgramCalendarView(
                    startDate: viewModel.program.startDate,
                    numberOfDays: viewModel.program.numberOfDays(),
                    completedDates: viewModel.getCompletedDates(),
                    selectedDate: viewModel.selectedDate,
                    onDateSelected: { date in
                        viewModel.selectDate(date)
                        // Set the selected date in ThemeManager for theme change logic
                        themeManager.setSelectedDate(date)
                        // Check for August 4th birthday theme activation
                        print("🔍 DailyChecklist Birthday Check - Date selected: \(date)")
                        print("🔍 DailyChecklist Birthday Check - Current theme: \(themeManager.currentTheme)")
                        themeManager.checkBirthdayActivationForDate(date)
                        showingCalendar = false
                    }
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
        .sheet(isPresented: $showingReleaseNotes) {
            if let releaseNotes = ReleaseNotes.getReleaseNotesForBuild18() {
                ReleaseNotesView(releaseNotes: releaseNotes) {
                    showingReleaseNotes = false
                }
            }
        }
        .onAppear {
            // Check for missed days and navigate to the first missed day if needed
            checkForMissedDaysAndNavigate()
            
            // Always load progress for the selected date (which acts as the current date for the app)
            loadDailyProgressForDate(viewModel.selectedDate)
            
            // Start timer to check for auto-advancement every minute
            startAutoAdvanceTimer()
            
            // Check for app updates
            updateChecker.checkForUpdates()
            
            // Force a refresh of thumbnails after a short delay to handle app update scenarios
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("DEBUG: Forcing thumbnail refresh after app appear")
                // Trigger a UI refresh by updating the view model
                self.viewModel.objectWillChange.send()
            }
            
            // Check for release notes to show after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                checkForReleaseNotes()
            }
        }
        .onDisappear {
            // Stop timer when view disappears
            stopAutoAdvanceTimer()
        }
    }
    
    // Add function to load daily progress for a specific date
    private func loadDailyProgressForDate(_ date: Date) {
        let dailyProgressStorage = DailyProgressStorage()
        let dailyProgress = dailyProgressStorage.load(for: date) ?? DailyProgress(
            id: UUID(),
            date: date,
            completedTaskIDs: [],
            isCompleted: false // Default to not completed until completed
        )
        viewModel.updateDailyProgress(dailyProgress)
        
        // Force UI update by triggering objectWillChange
        DispatchQueue.main.async {
            self.viewModel.objectWillChange.send()
        }
        
        // Force thumbnail refresh after a short delay to ensure UI has updated
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("DEBUG: Forcing thumbnail refresh after loading daily progress for date: \(date)")
            self.viewModel.objectWillChange.send()
        }
    }
    
    // Check for missed days and navigate to the first missed day
    private func checkForMissedDaysAndNavigate() {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: viewModel.program.startDate)
        let today = calendar.startOfDay(for: Date())
        let dailyProgressStorage = DailyProgressStorage()
        
        // Check all days from start date up to today
        var currentDate = startDate
        while currentDate <= today {
            // Skip if we're past the program duration
            let dayNumber = calendar.dateComponents([.day], from: startDate, to: currentDate).day ?? 0
            if dayNumber >= viewModel.program.numberOfDays() {
                break
            }
            
            // Load the progress for this day and check if it was completed
            let dayProgress = dailyProgressStorage.load(for: currentDate) ?? DailyProgress(
                id: UUID(),
                date: currentDate,
                completedTaskIDs: [],
                isCompleted: false
            )
            
            if !dayProgress.isCompleted {
                // Found the first missed day, navigate to it
                viewModel.selectDate(currentDate)
                return
            }
            
            // Move to next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // No missed days found, stay on today
        viewModel.selectDate(today)
    }
    
    // Navigate to the first missed day from the start of the program
    private func navigateToFirstMissedDay() {
        print("🔍 navigateToFirstMissedDay() called")
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: viewModel.program.startDate)
        let today = calendar.startOfDay(for: Date())
        let dailyProgressStorage = DailyProgressStorage()
        
        print("🔍 Start date: \(startDate)")
        print("🔍 Today: \(today)")
        print("🔍 Program duration: \(viewModel.program.numberOfDays()) days")
        
        // Check all days from start date up to today
        var currentDate = startDate
        while currentDate <= today {
            // Skip if we're past the program duration
            let dayNumber = calendar.dateComponents([.day], from: startDate, to: currentDate).day ?? 0
            if dayNumber >= viewModel.program.numberOfDays() {
                print("🔍 Past program duration, stopping at day \(dayNumber)")
                break
            }
            
            // Load the progress for this day and check if it was completed
            let dayProgress = dailyProgressStorage.load(for: currentDate) ?? DailyProgress(
                id: UUID(),
                date: currentDate,
                completedTaskIDs: [],
                isCompleted: false
            )
            
            print("🔍 Checking day \(dayNumber + 1): \(currentDate) - completed: \(dayProgress.isCompleted)")
            
            if !dayProgress.isCompleted {
                // Found the first missed day, navigate to it
                print("🔍 Found first missed day: \(currentDate) (day \(dayNumber + 1))")
                // Set ignore flag and navigate without clearing it
                viewModel.ignoreMissedDayForCurrentSession = true
                viewModel.selectDate(currentDate, clearIgnoreFlag: false)
                return
            }
            
            // Move to next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // No missed days found, stay on today
        print("🔍 No missed days found, staying on today: \(today)")
        viewModel.selectDate(today)
    }
    
    // Start timer to check for auto-advancement
    private func startAutoAdvanceTimer() {
        // Stop any existing timer
        stopAutoAdvanceTimer()
        
        // Create a timer that fires every minute
        autoAdvanceTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            checkForAutoAdvancement()
        }
    }
    
    // Stop the auto-advancement timer
    private func stopAutoAdvanceTimer() {
        autoAdvanceTimer?.invalidate()
        autoAdvanceTimer = nil
    }
    
    // Check if we should auto-advance to the next day
    private func checkForAutoAdvancement() {
        let now = Date()
        
        // Only auto-advance if the current day is completed
        let allTasksCompleted = viewModel.program.tasks().allSatisfy { 
            viewModel.dailyProgress.completedTaskIDs.contains($0.id) 
        }
        
        if allTasksCompleted && viewModel.program.shouldAutoAdvanceToNextDay(now: now, lastCompletedDay: viewModel.program.lastCompletedDay) {
            // Auto-advance to the next day
            autoAdvanceToNextDay()
        }
    }
    
    // Check for release notes to show
    private func checkForReleaseNotes() {
        // Use build 18 logic: always show release notes, but combine if multiple versions
        if let releaseNotes = ReleaseNotes.getReleaseNotesForBuild18() {
            let lastSeenVersion = UserDefaults.standard.string(forKey: "LastSeenReleaseNotesVersion") ?? "0.0"
            let lastSeenBuild = UserDefaults.standard.integer(forKey: "LastSeenReleaseNotesBuild")
            
            // Show if this is a new version/build the user hasn't seen
            if releaseNotes.version > lastSeenVersion || 
               (releaseNotes.version == lastSeenVersion && releaseNotes.buildNumber > lastSeenBuild) {
                print("DEBUG: Showing release notes for version \(releaseNotes.version) build \(releaseNotes.buildNumber)")
                showingReleaseNotes = true
            }
        }
    }
    
    // Auto-advance to the next day
    private func autoAdvanceToNextDay() {
        let calendar = Calendar.current
        let nextDay = calendar.date(byAdding: .day, value: 1, to: viewModel.selectedDate)!
        
        // Navigate to the next day
        viewModel.selectDate(nextDay)
        
        // Force UI update
        DispatchQueue.main.async {
            self.viewModel.objectWillChange.send()
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
                    appState.loadedProgram = nil
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(12)
                
                Button("Continue Anyway") {
                    print("🔍 Continue Anyway button tapped")
                    // Navigate to the first missed day from the start of the program
                    navigateToFirstMissedDay()
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
            
            ZStack {
                taskListView
                
                // Add balloons floating from bottom to top when birthday theme is active
                if themeManager.currentTheme == .birthday {
                    BirthdayBalloons()
                        .allowsHitTesting(false) // Allow taps to pass through to the tasks
                }
            }
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
                    
                    // Show "My Happy Birthday" on August 4th, 2025 when birthday theme is active
                    if isAugust4th2025 && themeManager.currentTheme == .birthday {
                        Text("My Happy Birthday")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text(viewModel.selectedDate, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
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
                .progressViewStyle(LinearProgressViewStyle(tint: themeAccentColor))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(12)
    }
    
    private var taskListView: some View {
        List {
            ForEach(viewModel.program.tasks(), id: \.id) { task in
                VStack(spacing: 0) {
                    TaskRowView(
                        task: task,
                        isCompleted: viewModel.dailyProgress.completedTaskIDs.contains(task.id),
                        currentDailyProgress: viewModel.dailyProgress,
                        onToggle: {
                            toggleTask(task)
                        },
                        onSetReminder: {
                            // TODO: Implement reminder functionality
                            print("Set reminder for task: \(task.title)")
                        },
                        onUpdateDailyProgress: { newProgress in
                            viewModel.dailyProgress = newProgress
                            DailyProgressStorage().save(progress: newProgress)
                        },
                        onPhotoRemoved: {
                            // Clear photo state when task is unchecked
                            print("DEBUG: Photo removed for task: \(task.title)")
                        }
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button("Reminder") {
                            // TODO: Implement reminder functionality
                            print("Set reminder for task: \(task.title)")
                        }
                        .tint(themeAccentColor)
                    }
                    
                    // Add custom separator between cards (except for the last one)
                    if task.id != viewModel.program.tasks().last?.id {
                        Divider()
                            .themeAwareDivider()
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
            .onMove(perform: moveTasks)
        }
        .listStyle(PlainListStyle())
        .background(Color.clear)
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
        NavigationLink(destination: SettingsView(endOfDayTime: $viewModel.program.endOfDayTime)
            .environmentObject(debugState)
            .environmentObject(appState)
            .environmentObject(themeManager)) {
            Image(systemName: "gearshape.fill")
                .foregroundColor(.blue)
        }
        .accessibilityIdentifier("SettingsButton")
    }
    
    // Computed properties
    private var themeAccentColor: Color {
        switch themeManager.currentTheme {
        case .birthday:
            return Color(red: 1.0, green: 0.8, blue: 0.9) // Pastel pink
        case .bea:
            return Color(red: 0.9, green: 0.8, blue: 1.0) // Pastel purple
        case .usa:
            return Color(red: 0.8, green: 0.1, blue: 0.2) // Red for USA theme
        case .lasVegas:
            return Color(red: 1.0, green: 1.0, blue: 0.0) // Yellow neon (sign bulbs) for Las Vegas theme
        case .dark:
            return Color.blue
        case .light, .system:
            return Color.blue
        }
    }
    
    private var currentDay: Int {
        let start = Calendar.current.startOfDay(for: viewModel.program.startDate)
        let selectedDay = Calendar.current.startOfDay(for: viewModel.selectedDate)
        let diff = Calendar.current.dateComponents([.day], from: start, to: selectedDay).day ?? 0
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
        var completed = viewModel.dailyProgress.completedTaskIDs
        var photoURLs = viewModel.dailyProgress.photoURLs
        
        if completed.contains(task.id) {
            // Task is being unchecked - remove photo if it exists
            completed.remove(task.id)
            if let photoURL = photoURLs[task.id] {
                // Delete the photo file from storage
                do {
                    try FileManager.default.removeItem(at: photoURL)
                    print("DEBUG: Deleted photo file for unchecked task: \(task.title)")
                } catch {
                    print("DEBUG: Error deleting photo file: \(error)")
                }
                // Remove photo URL from progress
                photoURLs.removeValue(forKey: task.id)
                print("DEBUG: Removed photo URL for unchecked task: \(task.title)")
            }
        } else {
            // Task is being checked - keep existing photo if any
            completed.insert(task.id)
        }
        
        let newProgress = DailyProgress(
            id: viewModel.dailyProgress.id,
            date: viewModel.dailyProgress.date,
            completedTaskIDs: completed,
            photoURLs: photoURLs,
            isCompleted: viewModel.dailyProgress.isCompleted // Preserve current completion status
        )
        
        viewModel.dailyProgress = newProgress
        DailyProgressStorage().save(progress: newProgress)
        
        // Check if all tasks are completed and mark day as completed if so
        let allTasksCompleted = viewModel.program.tasks().allSatisfy { completed.contains($0.id) }
        if allTasksCompleted {
            viewModel.completeCurrentDay()
        } else if viewModel.dailyProgress.isCompleted {
            // If not all tasks are completed but the day was marked as completed, unmark it
            viewModel.dailyProgress.isCompleted = false
            DailyProgressStorage().save(progress: viewModel.dailyProgress)
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
    let currentDailyProgress: DailyProgress
    let onToggle: () -> Void
    let onSetReminder: () -> Void
    let onUpdateDailyProgress: (DailyProgress) -> Void
    let onPhotoRemoved: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingPhotoPicker = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var thumbnailImage: UIImage?
    @State private var fullImage: UIImage?
    @State private var showingFullPhoto = false
    @State private var hasPhoto: Bool = false
    @State private var currentLoadingProgressID: UUID?
    @State private var isLoadingThumbnail: Bool = false
    @State private var cardScale: CGFloat = 1.0
    @State private var checkboxScale: CGFloat = 1.0
    
    // Get the photo URL for this task
    private func photoURL(from dailyProgress: DailyProgress) -> URL? {
        let url = dailyProgress.photoURLs[task.id]
        
        print("DEBUG: photoURL for task '\(task.title)': \(url?.absoluteString ?? "nil")")
        print("DEBUG: Progress photoURLs count: \(dailyProgress.photoURLs.count)")
        print("DEBUG: Progress photoURLs keys: \(dailyProgress.photoURLs.keys.map { $0.uuidString.prefix(8) })")
        print("DEBUG: Progress date: \(dailyProgress.date)")
        print("DEBUG: Progress ID: \(dailyProgress.id)")
        
        return url
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Modern card design
            HStack(spacing: 16) {
                // Modern checkbox with animation (no longer clickable - entire card handles taps)
                ZStack {
                    ZStack {
                        Circle()
                            .fill(checkboxFillColor)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(checkboxStrokeColor, lineWidth: 2)
                            )
                            .shadow(
                                color: checkboxShadowColor,
                                radius: checkboxShadowRadius,
                                x: 0,
                                y: 2
                            )
                        
                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .scaleEffect(checkboxScale)
                
                // Task content
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            // Task title with modern typography
                            Text(task.title)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(isCompleted ? .secondary : .primary)
                                .strikethrough(isCompleted)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                            
                            // Task description
                            if let description = task.description, !description.isEmpty {
                                Text(description)
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .strikethrough(isCompleted)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Photo thumbnail with modern design
                        if let thumbnail = thumbnailImage {
                            Button(action: {
                                showingFullPhoto = true
                            }) {
                                Image(uiImage: thumbnail)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // Action buttons row
                    HStack(spacing: 12) {
                        // Photo button for tasks that require photos
                        if task.requiresPhoto && !hasPhoto {
                                                            Button(action: {
                                    showingPhotoPicker = true
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "camera")
                                            .font(.system(size: 12, weight: .medium))
                                        Text("Add Photo")
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                    }
                                    .foregroundColor(themeAccentColor)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(themeAccentColor.opacity(0.1))
                                    )
                                }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Photo indicator for tasks with photos
                        if task.requiresPhoto && hasPhoto {
                                                            HStack(spacing: 4) {
                                    Image(systemName: "photo.fill")
                                        .font(.system(size: 12, weight: .medium))
                                    Text("Photo Added")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                }
                            .foregroundColor(.green)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.green.opacity(0.1))
                            )
                        }
                        
                        Spacer()
                        
                        // Reminder button
                                                    Button(action: onSetReminder) {
                                Image(systemName: "bell")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeAccentColor)
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(themeAccentColor.opacity(0.1))
                                    )
                            }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(16)
            .themeAwareCard()
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isCompleted ? themeAccentColor.opacity(0.3) : Color.gray.opacity(0.1),
                        lineWidth: isCompleted ? 2 : 1
                    )
            )
            .scaleEffect(cardScale)
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    cardScale = 0.98
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        cardScale = 1.0
                    }
                    // Handle checkbox tap when entire card is tapped
                    handleCheckboxTap()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .actionSheet(isPresented: $showingPhotoPicker) {
            ActionSheet(
                title: Text("Add Photo"),
                message: Text("Choose how to add a photo for this task"),
                buttons: {
                    var buttons: [ActionSheet.Button] = []
                    
                    // Only show camera option if camera is available
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        buttons.append(.default(Text("Take Photo")) {
                            imageSource = .camera
                            showingImagePicker = true
                        })
                    }
                    
                    // Always show photo library option
                    buttons.append(.default(Text("Choose from Library")) {
                        imageSource = .photoLibrary
                        showingImagePicker = true
                    })
                    
                    buttons.append(.cancel())
                    return buttons
                }()
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: imageSource)
        }
        .sheet(isPresented: $showingFullPhoto) {
            FullPhotoViewer(image: fullImage, taskTitle: task.title)
        }
        .alert("Remove Photo?", isPresented: $showingUncheckAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove Photo", role: .destructive) {
                onToggle()
            }
        } message: {
            Text("Unchecking this task will remove the photo you've taken. This action cannot be undone.")
        }
        .onChange(of: showingFullPhoto) { _, isShowing in
            if isShowing {
                print("DEBUG: Opening FullPhotoViewer for task: \(task.title)")
                print("DEBUG: fullImage is nil: \(fullImage == nil)")
                if let image = fullImage {
                    print("DEBUG: fullImage size: \(image.size)")
                }
            } else {
                print("DEBUG: Closing FullPhotoViewer for task: \(task.title)")
                print("DEBUG: fullImage is nil: \(fullImage == nil)")
            }
        }
        .onChange(of: selectedImage) { _, newImage in
            if let image = newImage {
                savePhotoForTask(image: image)
                // After saving photo, complete the task if it was being checked
                if !isCompleted && task.requiresPhoto {
                    onToggle()
                }
            }
        }
        .onAppear {
            loadThumbnail()
        }
        .id(currentDailyProgress.id) // Force view recreation when daily progress changes

        .onChange(of: isCompleted) { _, newIsCompleted in
            if !newIsCompleted {
                // Task was unchecked - clear photo state
                thumbnailImage = nil
                fullImage = nil
                hasPhoto = false
                onPhotoRemoved()
                print("DEBUG: Cleared photo state for unchecked task: \(task.title)")
            }
        }
    }
    
    @State private var showingUncheckAlert = false
    
            // MARK: - Computed Properties for Checkbox Styling
        private var themeAccentColor: Color {
            switch themeManager.currentTheme {
            case .birthday:
                return Color(red: 1.0, green: 0.8, blue: 0.9) // Pastel pink
            case .bea:
                return Color(red: 0.9, green: 0.8, blue: 1.0) // Pastel purple
            case .usa:
                return Color(red: 0.8, green: 0.1, blue: 0.2) // Red for USA theme
            case .lasVegas:
                return Color(red: 1.0, green: 1.0, blue: 0.0) // Yellow neon (sign bulbs) for Las Vegas theme
            case .dark:
                return Color.blue
            case .light, .system:
                return Color.blue
            }
        }
    
            private var themeSecondaryColor: Color {
            switch themeManager.currentTheme {
            case .birthday:
                return Color(red: 0.8, green: 0.9, blue: 1.0) // Pastel blue
            case .bea:
                return Color(red: 0.8, green: 0.9, blue: 1.0) // Pastel blue
            case .usa:
                return Color(red: 0.1, green: 0.3, blue: 0.8) // Blue for USA theme
            case .lasVegas:
                return Color(red: 1.0, green: 0.0, blue: 0.0) // Red neon (letters/star) for Las Vegas theme
            case .dark:
                return Color.blue.opacity(0.7)
            case .light, .system:
                return Color.blue.opacity(0.7)
            }
        }
    
    private var checkboxFillColor: Color {
        isCompleted ? themeAccentColor : Color.clear
    }
    
    private var checkboxStrokeColor: Color {
        if isCompleted {
            return themeAccentColor
        } else {
            return themeManager.colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray.opacity(0.4)
        }
    }
    
    private var checkboxShadowColor: Color {
        (isCompleted && themeManager.colorScheme == .dark) ? themeAccentColor.opacity(0.3) : Color.clear
    }
    
    private var checkboxShadowRadius: CGFloat {
        (isCompleted && themeManager.colorScheme == .dark) ? 4 : 0
    }
    
    private func handleCheckboxTap() {
        // If task requires photo and doesn't have one yet, show photo picker
        if task.requiresPhoto && !hasPhoto && !isCompleted {
            showingPhotoPicker = true
        } else if task.requiresPhoto && hasPhoto && isCompleted {
            // If task has a photo and is currently completed, show warning before unchecking
            showingUncheckAlert = true
        } else {
            // Otherwise, just toggle the task completion
            onToggle()
        }
    }
    
    private func loadThumbnail() {
        // Prevent multiple simultaneous loading operations
        guard !isLoadingThumbnail else {
            print("DEBUG: Skipping loadThumbnail for task: \(task.title) - already loading")
            return
        }
        
        print("DEBUG: loadThumbnail called for task: \(task.title)")
        print("DEBUG: fullImage before loadThumbnail: \(fullImage == nil ? "nil" : "not nil")")
        print("DEBUG: currentDailyProgress photoURLs count: \(currentDailyProgress.photoURLs.count)")
        
        // Track which daily progress we're loading for to prevent race conditions
        let progressID = currentDailyProgress.id
        currentLoadingProgressID = progressID
        isLoadingThumbnail = true
        
        // Only clear images if we're loading for a different daily progress
        if currentLoadingProgressID != progressID {
            thumbnailImage = nil
            fullImage = nil
            hasPhoto = false
        }
        
        // Check if we have a photo URL for this task
        guard let url = photoURL(from: currentDailyProgress) else {
            print("DEBUG: No photo URL found for task: \(task.title)")
            print("DEBUG: fullImage after clearing: \(fullImage == nil ? "nil" : "not nil")")
            isLoadingThumbnail = false
            return
        }
        
        print("DEBUG: Loading thumbnail for task: \(task.title) from URL: \(url)")
        
        // Try to load the image, and if it fails, try to find it in other possible locations
        loadImageFromURL(url) { image in
            // Check if we're still loading for the same daily progress (prevent race conditions)
            guard self.currentLoadingProgressID == progressID else {
                print("DEBUG: Ignoring image load result for task: \(self.task.title) - daily progress changed")
                return
            }
            
            if let image = image {
                print("DEBUG: Successfully loaded image for task: \(self.task.title)")
                DispatchQueue.main.async {
                    self.fullImage = image
                    self.hasPhoto = true
                    self.isLoadingThumbnail = false
                    print("DEBUG: Set full image for task: \(self.task.title)")
                    print("DEBUG: fullImage after setting: \(self.fullImage == nil ? "nil" : "not nil")")
                }
                
                image.prepareThumbnail(of: CGSize(width: 80, height: 80)) { thumbnail in
                    // Check if we're still loading for the same daily progress
                    guard self.currentLoadingProgressID == progressID else {
                        print("DEBUG: Ignoring thumbnail result for task: \(self.task.title) - daily progress changed")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.thumbnailImage = thumbnail ?? image
                        print("DEBUG: Set thumbnail for task: \(self.task.title)")
                    }
                }
            } else {
                print("DEBUG: Failed to load image for task: \(self.task.title)")
                
                // Check if we're still loading for the same daily progress
                guard self.currentLoadingProgressID == progressID else {
                    print("DEBUG: Ignoring failed load for task: \(self.task.title) - daily progress changed")
                    return
                }
                
                DispatchQueue.main.async {
                    // Only clear state if we don't already have a valid image
                    if self.fullImage == nil {
                        self.thumbnailImage = nil
                        self.hasPhoto = false
                    }
                    self.isLoadingThumbnail = false
                    print("DEBUG: fullImage after clearing (failed): \(self.fullImage == nil ? "nil" : "not nil")")
                }
                
                // Retry loading after a longer delay to prevent rapid retries
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    // Check again before retrying
                    guard self.currentLoadingProgressID == progressID else {
                        print("DEBUG: Skipping retry for task: \(self.task.title) - daily progress changed")
                        return
                    }
                    print("DEBUG: Retrying thumbnail load for task: \(self.task.title)")
                    self.isLoadingThumbnail = false // Reset for retry
                    self.loadThumbnail()
                }
            }
        }
    }
    
    private func loadImageFromURL(_ url: URL, completion: @escaping (UIImage?) -> Void) {
        // Always try original URL first, then search other locations if needed
        // This handles both simulator directory changes and app upgrade path changes
        loadImageFromSpecificURL(url) { image in
            if image != nil {
                completion(image)
                return
            }
            
            // If that fails, try to find the file in other possible locations
            self.findImageInOtherLocations(url) { foundImage in
                if let foundImage = foundImage {
                    // If we found the image in a different location, update the stored URL
                    self.updatePhotoURLIfNeeded(oldURL: url, foundImage: foundImage)
                }
                completion(foundImage)
            }
        }
    }
    
    private func loadImageFromSpecificURL(_ url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let imageData = try Data(contentsOf: url)
                print("DEBUG: Successfully loaded image data from URL: \(url), size: \(imageData.count) bytes")
                
                if let image = UIImage(data: imageData) {
                    print("DEBUG: Successfully created UIImage from URL: \(url)")
                    completion(image)
                } else {
                    print("DEBUG: Failed to create UIImage from data for URL: \(url)")
                    completion(nil)
                }
            } catch {
                print("DEBUG: Error loading image from URL: \(url) - \(error)")
                completion(nil)
            }
        }
    }
    
    private func findImageInOtherLocations(_ originalURL: URL, completion: @escaping (UIImage?) -> Void) {
        print("DEBUG: Attempting to find image in other locations for: \(originalURL)")
        
        // Extract the filename from the original URL
        let fileName = originalURL.lastPathComponent
        print("DEBUG: Looking for filename: \(fileName)")
        
        // Try different possible base directories
        let possibleDirectories = [
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first,
            FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        ].compactMap { $0 }
        
        // Also try with Photos subdirectory
        var allPossiblePaths: [URL] = []
        for directory in possibleDirectories {
            allPossiblePaths.append(directory.appendingPathComponent(fileName))
            allPossiblePaths.append(directory.appendingPathComponent("Photos").appendingPathComponent(fileName))
        }
        
        print("DEBUG: Checking \(allPossiblePaths.count) possible paths for image")
        
        // Try each possible path
        for (index, path) in allPossiblePaths.enumerated() {
            print("DEBUG: Checking path \(index + 1): \(path)")
            
            loadImageFromSpecificURL(path) { image in
                if image != nil {
                    print("DEBUG: Found image at path: \(path)")
                    completion(image)
                    return
                }
                
                // If this was the last path to check, return nil
                if index == allPossiblePaths.count - 1 {
                    print("DEBUG: Image not found in any of the checked paths")
                    completion(nil)
                }
            }
        }
    }
    
    private func updatePhotoURLIfNeeded(oldURL: URL, foundImage: UIImage) {
        // Extract the filename from the original URL
        let fileName = oldURL.lastPathComponent
        
        // Find where the image actually exists
        let possibleDirectories = [
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first,
            FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        ].compactMap { $0 }
        
        for directory in possibleDirectories {
            let directPath = directory.appendingPathComponent(fileName)
            let photosPath = directory.appendingPathComponent("Photos").appendingPathComponent(fileName)
            
            if FileManager.default.fileExists(atPath: directPath.path) {
                updateStoredPhotoURL(from: oldURL, to: directPath)
                return
            } else if FileManager.default.fileExists(atPath: photosPath.path) {
                updateStoredPhotoURL(from: oldURL, to: photosPath)
                return
            }
        }
    }
    
    private func updateStoredPhotoURL(from oldURL: URL, to newURL: URL) {
        print("DEBUG: Updating stored photo URL from \(oldURL) to \(newURL)")
        
        // Get the current daily progress and update the photo URL
        let dailyProgressStorage = DailyProgressStorage()
        let targetDate = currentDailyProgress.date
        var currentProgress = dailyProgressStorage.load(for: targetDate) ?? currentDailyProgress
        
        // Find the task ID that has the old URL and update it
        for (taskID, url) in currentProgress.photoURLs {
            if url == oldURL {
                currentProgress.photoURLs[taskID] = newURL
                print("DEBUG: Updated photo URL for task ID \(taskID)")
                break
            }
        }
        
        // Save the updated progress
        dailyProgressStorage.save(progress: currentProgress)
        print("DEBUG: Saved updated progress with corrected photo URL")
    }
    
    private func savePhotoForTask(image: UIImage) {
        print("DEBUG: Starting to save photo for task: \(task.title)")
        
        // Save the image to Application Support directory for persistence across app launches
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let photosDirectory = applicationSupportDirectory.appendingPathComponent("Photos", isDirectory: true)
            
            // Create the Photos directory if it doesn't exist
            do {
                try FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("DEBUG: Error creating Photos directory: \(error)")
            }
            
            let fileName = "\(task.id.uuidString)_\(Date().timeIntervalSince1970).jpg"
            let fileURL = photosDirectory.appendingPathComponent(fileName)
            
            print("DEBUG: Saving photo to: \(fileURL)")
            
            do {
                try imageData.write(to: fileURL)
                print("DEBUG: Successfully wrote image data to file")
                
                // Get the current daily progress from storage to ensure we have the latest
                let dailyProgressStorage = DailyProgressStorage()
                let targetDate = currentDailyProgress.date // Use the date from current daily progress
                var currentProgress = dailyProgressStorage.load(for: targetDate) ?? DailyProgress(
                    id: UUID(),
                    date: targetDate,
                    completedTaskIDs: [],
                    photoURLs: [:]
                )
                
                print("DEBUG: Current progress photoURLs count: \(currentProgress.photoURLs.count)")
                
                // Add the photo URL to the progress
                currentProgress.photoURLs[task.id] = fileURL
                
                // Use the callback to update the view model and save to storage
                onUpdateDailyProgress(currentProgress)
                
                print("DEBUG: Updated progress with photoURLs count: \(currentProgress.photoURLs.count)")
                print("DEBUG: Photo URL for task \(task.title): \(fileURL)")
                
                // Debug the storage key being used
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                let dateString = formatter.string(from: targetDate)
                print("DEBUG: Saving to storage key: dailyProgress_\(dateString)")
                print("DEBUG: Progress date: \(currentProgress.date)")
                print("DEBUG: Progress ID: \(currentProgress.id)")
                
                // Update both thumbnail and full image immediately
                fullImage = image
                hasPhoto = true
                image.prepareThumbnail(of: CGSize(width: 80, height: 80)) { thumbnail in
                    DispatchQueue.main.async {
                        thumbnailImage = thumbnail ?? image
                        print("DEBUG: Set thumbnail for task: \(task.title)")
                    }
                }
                
                print("DEBUG: Photo saved for task: \(task.title) at \(fileURL)")
            } catch {
                print("DEBUG: Error saving photo: \(error)")
            }
        } else {
            print("DEBUG: Failed to create JPEG data from image")
        }
    }
}

// Full-screen photo viewer
struct FullPhotoViewer: View {
    let image: UIImage?
    let taskTitle: String
    @Environment(\.presentationMode) private var presentationMode
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaleEffect(scale)
                        .offset(offset)
                        .clipped()
                        .gesture(
                            SimultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let delta = value / lastScale
                                        lastScale = value
                                        scale = min(max(scale * delta, 1.0), 4.0)
                                    }
                                    .onEnded { _ in
                                        lastScale = 1.0
                                    },
                                DragGesture()
                                    .onChanged { value in
                                        let delta = CGSize(
                                            width: value.translation.width - lastOffset.width,
                                            height: value.translation.height - lastOffset.height
                                        )
                                        lastOffset = value.translation
                                        offset = CGSize(
                                            width: offset.width + delta.width,
                                            height: offset.height + delta.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = .zero
                                    }
                            )
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                if scale > 1.0 {
                                    scale = 1.0
                                    offset = .zero
                                } else {
                                    scale = 2.0
                                }
                            }
                        }
                        .ignoresSafeArea()
                } else {
                    VStack {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.6))
                        Text("Photo not available")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.headline)
                            .padding(.top)
                    }
                }
            }
            .navigationTitle(taskTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    DailyChecklistView()
}

// ImagePicker for photo selection
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    let sourceType: UIImagePickerController.SourceType
    
    init(selectedImage: Binding<UIImage?>, sourceType: UIImagePickerController.SourceType = .photoLibrary) {
        self._selectedImage = selectedImage
        self.sourceType = sourceType
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        // Check if camera is available when trying to use camera
        if sourceType == .camera && !UIImagePickerController.isSourceTypeAvailable(.camera) {
            // Fallback to photo library if camera is not available
            picker.sourceType = .photoLibrary
        } else {
            picker.sourceType = sourceType
        }
        
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
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