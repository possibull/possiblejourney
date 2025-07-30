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
        var completed = viewModel.dailyProgress.completedTaskIDs
        if completed.contains(task.id) {
            completed.remove(task.id)
        } else {
            completed.insert(task.id)
        }
        
        let newProgress = DailyProgress(
            id: viewModel.dailyProgress.id,
            date: viewModel.dailyProgress.date,
            completedTaskIDs: completed,
            photoURLs: viewModel.dailyProgress.photoURLs
        )
        
        viewModel.dailyProgress = newProgress
        DailyProgressStorage().save(progress: newProgress)
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
    @State private var showingPhotoPicker = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var thumbnailImage: UIImage?
    @State private var fullImage: UIImage?
    @State private var showingFullPhoto = false
    @State private var hasPhoto: Bool = false
    
    // Get the photo URL for this task
    private var photoURL: URL? {
        let dailyProgressStorage = DailyProgressStorage()
        let today = Date()
        let currentProgress = dailyProgressStorage.load(for: today)
        let url = currentProgress?.photoURLs[task.id]
        
        print("DEBUG: photoURL for task '\(task.title)': \(url?.absoluteString ?? "nil")")
        print("DEBUG: Date being used: \(today)")
        print("DEBUG: DailyProgress loaded: \(currentProgress != nil)")
        if let progress = currentProgress {
            print("DEBUG: Progress photoURLs count: \(progress.photoURLs.count)")
            print("DEBUG: Progress photoURLs keys: \(progress.photoURLs.keys.map { $0.uuidString.prefix(8) })")
            print("DEBUG: Progress date: \(progress.date)")
            print("DEBUG: Progress ID: \(progress.id)")
        }
        
        // Also check what the storage key would be
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateString = formatter.string(from: today)
        print("DEBUG: Storage key would be: dailyProgress_\(dateString)")
        
        return url
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.trailing, 4)
            
            // Checkbox
            Button(action: {
                handleCheckboxTap()
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isCompleted ? .blue : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Task content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(task.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .strikethrough(isCompleted)
                        .multilineTextAlignment(.leading)
                    
                    // Photo requirement indicator
                    if task.requiresPhoto {
                        Image(systemName: hasPhoto ? "camera.fill" : "camera")
                            .foregroundColor(hasPhoto ? .green : .blue)
                            .font(.caption)
                    }
                }
                
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
            
            // Photo thumbnail (if photo exists)
            if let thumbnail = thumbnailImage {
                Button(action: {
                    showingFullPhoto = true
                }) {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Photo button for tasks that require photos
            if task.requiresPhoto {
                Button(action: {
                    showingPhotoPicker = true
                }) {
                    Image(systemName: hasPhoto ? "photo.fill" : "camera")
                        .font(.caption)
                        .foregroundColor(hasPhoto ? .green : .blue)
                }
                .buttonStyle(PlainButtonStyle())
                .actionSheet(isPresented: $showingPhotoPicker) {
                    ActionSheet(
                        title: Text(hasPhoto ? "Update Photo" : "Add Photo"),
                        message: Text("Choose how to \(hasPhoto ? "update" : "add") a photo for this task"),
                        buttons: [
                            .default(Text("Take Photo")) {
                                imageSource = .camera
                                showingImagePicker = true
                            },
                            .default(Text("Choose from Library")) {
                                imageSource = .photoLibrary
                                showingImagePicker = true
                            },
                            .cancel()
                        ]
                    )
                }
            }
            
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
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: imageSource)
        }
        .sheet(isPresented: $showingFullPhoto) {
            FullPhotoViewer(image: fullImage, taskTitle: task.title)
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
        .onChange(of: hasPhoto) { _, _ in
            loadThumbnail()
        }
    }
    
    private func handleCheckboxTap() {
        // If task requires photo and doesn't have one yet, show photo picker
        if task.requiresPhoto && !hasPhoto && !isCompleted {
            showingPhotoPicker = true
        } else {
            // Otherwise, just toggle the task completion
            onToggle()
        }
    }
    
    private func loadThumbnail() {
        guard let url = photoURL else {
            print("DEBUG: No photo URL found for task: \(task.title)")
            thumbnailImage = nil
            fullImage = nil
            hasPhoto = false
            return
        }
        
        print("DEBUG: Loading thumbnail for task: \(task.title) from URL: \(url)")
        
        // Load image asynchronously to avoid blocking the UI
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let imageData = try Data(contentsOf: url)
                print("DEBUG: Successfully loaded image data for task: \(task.title), size: \(imageData.count) bytes")
                
                if let image = UIImage(data: imageData) {
                    print("DEBUG: Successfully created UIImage for task: \(task.title)")
                    
                    // Store the full image for the viewer
                    DispatchQueue.main.async {
                        fullImage = image
                        hasPhoto = true
                        print("DEBUG: Set full image for task: \(task.title)")
                    }
                    
                    // Create a smaller thumbnail for better performance
                    image.prepareThumbnail(of: CGSize(width: 80, height: 80)) { thumbnail in
                        DispatchQueue.main.async {
                            thumbnailImage = thumbnail ?? image
                            print("DEBUG: Set thumbnail for task: \(task.title)")
                        }
                    }
                } else {
                    print("DEBUG: Failed to create UIImage from data for task: \(task.title)")
                    DispatchQueue.main.async {
                        thumbnailImage = nil
                        fullImage = nil
                        hasPhoto = false
                    }
                }
            } catch {
                print("DEBUG: Error loading image for task: \(task.title) - \(error)")
                DispatchQueue.main.async {
                    thumbnailImage = nil
                    fullImage = nil
                    hasPhoto = false
                }
            }
        }
    }
    
    private func savePhotoForTask(image: UIImage) {
        print("DEBUG: Starting to save photo for task: \(task.title)")
        
        // Save the image to documents directory and store the URL
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileName = "\(task.id.uuidString)_\(Date().timeIntervalSince1970).jpg"
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            print("DEBUG: Saving photo to: \(fileURL)")
            
            do {
                try imageData.write(to: fileURL)
                print("DEBUG: Successfully wrote image data to file")
                
                // Update the daily progress with the photo URL
                let dailyProgressStorage = DailyProgressStorage()
                let today = Date()
                var currentProgress = dailyProgressStorage.load(for: today) ?? DailyProgress(
                    id: UUID(),
                    date: today,
                    completedTaskIDs: [],
                    photoURLs: [:]
                )
                
                print("DEBUG: Current progress photoURLs count: \(currentProgress.photoURLs.count)")
                
                // Add the photo URL to the progress
                currentProgress.photoURLs[task.id] = fileURL
                dailyProgressStorage.save(progress: currentProgress)
                
                print("DEBUG: Saved progress with photoURLs count: \(currentProgress.photoURLs.count)")
                print("DEBUG: Photo URL for task \(task.title): \(fileURL)")
                
                // Debug the storage key being used
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                let dateString = formatter.string(from: today)
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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
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
        picker.sourceType = sourceType
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