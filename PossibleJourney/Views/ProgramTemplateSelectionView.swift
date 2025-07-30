//
//  ProgramTemplateSelectionView.swift
//  PossibleJourney
//
//  Created by Ted Possible on 7/22/25.
//

import SwiftUI

struct ProgramTemplateSelectionView: View {
    @StateObject private var viewModel = ProgramTemplateViewModel()
    @State private var selectedTemplate: ProgramTemplate?
    @State private var showingCustomSetup = false
    @State private var editingTemplate: ProgramTemplate?
    @State private var templateToDelete: ProgramTemplate?
    @State private var showingTemplateCreate = false
    
    let onTemplateSelected: (ProgramTemplate) -> Void
    let onProgramCreated: (Program) -> Void
    let onCustomProgram: () -> Void
    

    
    var body: some View {
        NavigationView {
            ZStack {
                // Light background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search templates...", text: $viewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(TemplateCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    viewModel.selectedCategory = viewModel.selectedCategory == category ? nil : category
                                }) {
                                    Text(category.displayName)
                                        .font(.caption)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(viewModel.selectedCategory == category ? Color.blue : Color(.systemGray5))
                                        .foregroundColor(viewModel.selectedCategory == category ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    
                    // Templates list
                    List {
                        ForEach(viewModel.filteredTemplates) { template in
                            TemplateCardView(
                                template: template,
                                onTap: {
                                    selectedTemplate = template
                                }
                            )
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                // Delete action (for all templates) - full swipe triggers with confirmation
                                Button {
                                    templateToDelete = template
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                                
                                // Duplicate action (for all templates)
                                Button {
                                    let copy = viewModel.duplicateTemplate(template)
                                    editingTemplate = copy
                                } label: {
                                    Label("Duplicate", systemImage: "plus.square.on.square")
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                // Edit action (only for non-default templates) - separate group
                                if !template.isDefault {
                                    Button {
                                        editingTemplate = template
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.orange)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Choose Template")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        viewModel.resetToDefaults()
                    }
                    .fontWeight(.medium)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Custom") {
                        showingTemplateCreate = true
                    }
                    .fontWeight(.medium)
                }
            }

            .sheet(item: $selectedTemplate) { template in
                TemplateDetailView(
                    template: template,
                    onStartProgram: { program in
                        onProgramCreated(program)
                        selectedTemplate = nil
                    },
                    onDuplicate: { template in
                        let copy = viewModel.duplicateTemplate(template)
                        editingTemplate = copy
                        selectedTemplate = nil
                    },
                    onDelete: { template in
                        templateToDelete = template
                        selectedTemplate = nil
                    }
                )
            }
            .sheet(item: $editingTemplate) { template in
                TemplateEditView(template: template) { updatedTemplate in
                    viewModel.updateTemplate(updatedTemplate)
                    editingTemplate = nil
                }
            }
            .alert("Delete Template", isPresented: Binding(
                get: { templateToDelete != nil },
                set: { if !$0 { templateToDelete = nil } }
            )) {
                Button("Cancel", role: .cancel) {
                    templateToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let template = templateToDelete {
                        viewModel.deleteTemplate(template)
                    }
                    templateToDelete = nil
                }
            } message: {
                if let template = templateToDelete {
                    Text("Are you sure you want to delete '\(template.name)'? This action cannot be undone.")
                }
            }
            .sheet(isPresented: $showingTemplateCreate) {
                TemplateCreateView { newTemplate in
                    viewModel.addTemplate(newTemplate)
                    showingTemplateCreate = false
                }
            }
        }
    }
}

struct TemplateCardView: View {
    let template: ProgramTemplate
    let onTap: () -> Void
    @State private var isExpanded = false
    
    private func formatLastModified(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let daysAgo = calendar.dateComponents([.day], from: date, to: now).day ?? 0
            if daysAgo < 7 {
                return "\(daysAgo) days ago"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                return formatter.string(from: date)
            }
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: template.category.icon)
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(template.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(template.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(template.defaultNumberOfDays) days")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                        
                        Text(template.category.displayName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text(formatLastModified(template.lastModified))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                

                
                // Tasks preview
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tasks:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    let visibleTasks = isExpanded ? template.tasks : Array(template.tasks.prefix(3))
                    
                    ForEach(visibleTasks, id: \.id) { task in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 4))
                                .foregroundColor(.blue)
                            Text(task.title)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            Spacer()
                        }
                    }
                    
                    // Show "more tasks" button if there are more than 3 tasks
                    if template.tasks.count > 3 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isExpanded.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                                Text(isExpanded ? "Show less" : "+ \(template.tasks.count - 3) more tasks")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TemplateDetailView: View {
    let template: ProgramTemplate
    let onStartProgram: (Program) -> Void
    let onDuplicate: (ProgramTemplate) -> Void
    let onDelete: (ProgramTemplate) -> Void
    
    @State private var startDate = Date()
    @State private var endOfDayTime = Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22) // Default 10pm
    @State private var numberOfDays: Int
    @State private var useCustomDays = false
    @Environment(\.presentationMode) private var presentationMode
    
    init(template: ProgramTemplate, onStartProgram: @escaping (Program) -> Void, onDuplicate: @escaping (ProgramTemplate) -> Void, onDelete: @escaping (ProgramTemplate) -> Void) {
        self.template = template
        self.onStartProgram = onStartProgram
        self.onDuplicate = onDuplicate
        self.onDelete = onDelete
        self._numberOfDays = State(initialValue: template.defaultNumberOfDays)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    tasksSection
                    numberOfDaysSection
                    startDateSection
                    endOfDaySection
                    startButton
                }
                .padding()
            }
            .navigationTitle("Template Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button("Duplicate") {
                            onDuplicate(template)
                        }
                        
                        Button("Delete") {
                            onDelete(template)
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .onAppear {
                // Template detail view appeared
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: template.category.icon)
                    .font(.title)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(template.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack {
                Label("\(template.defaultNumberOfDays) days", systemImage: "calendar")
                Spacer()
                Label(template.category.displayName, systemImage: "tag")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Tasks")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(template.tasks, id: \.id) { task in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .font(.body)
                            .fontWeight(.medium)
                        
                        if let description = task.description {
                            Text(description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
    
    private var startDateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Start Date")
                .font(.headline)
                .fontWeight(.semibold)
            
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
    
    private var numberOfDaysSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Number of Days")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                Toggle("Custom", isOn: $useCustomDays)
                    .font(.body)
                
                Spacer()
                
                if useCustomDays {
                    Text("days")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    TextField("Days", value: $numberOfDays, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                        .keyboardType(.numberPad)
                        .onChange(of: numberOfDays) { oldValue, newValue in
                            // Ensure the value stays within valid range
                            if newValue < 1 {
                                numberOfDays = 1
                            } else if newValue > 365 {
                                numberOfDays = 365
                            }
                        }
                    
                    Stepper("", value: $numberOfDays, in: 1...365)
                        .labelsHidden()
                } else {
                    Text("\(template.defaultNumberOfDays) days (default)")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    private var endOfDaySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("End of Day Time")
                .font(.headline)
                .fontWeight(.semibold)
            
            DatePicker("End of Day Time", selection: $endOfDayTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(CompactDatePickerStyle())
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
    
    private var startButton: some View {
        Button(action: {
            let customDays = useCustomDays ? numberOfDays : nil
            let program = template.createProgram(startDate: startDate, endOfDayTime: endOfDayTime, numberOfDays: customDays)
            onStartProgram(program)
        }) {
            HStack {
                Image(systemName: "play.fill")
                Text("Start Program")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
        }
        .padding(.top)
    }
}

struct TemplateCreateView: View {
    @State private var template: ProgramTemplate
    @State private var showingAddTask = false
    @State private var newTaskTitle = ""
    @State private var newTaskDescription = ""
    
    let onSave: (ProgramTemplate) -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    init(onSave: @escaping (ProgramTemplate) -> Void) {
        // Create a new template with reasonable defaults
        let newTemplate = ProgramTemplate(
            name: "New Template",
            description: "A custom program template",
            category: .custom,
            defaultNumberOfDays: 30,
            tasks: [],
            isDefault: false
        )
        self._template = State(initialValue: newTemplate)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Template Details")) {
                    TextField("Template Name", text: $template.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Description", text: $template.description, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                    
                    Picker("Category", selection: $template.category) {
                        ForEach(TemplateCategory.allCases, id: \.self) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default Number of Days")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text("days")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            TextField("Days", value: $template.defaultNumberOfDays, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 80)
                                .keyboardType(.numberPad)
                                .onChange(of: template.defaultNumberOfDays) { oldValue, newValue in
                                    // Ensure the value stays within valid range
                                    if newValue < 1 {
                                        template.defaultNumberOfDays = 1
                                    } else if newValue > 365 {
                                        template.defaultNumberOfDays = 365
                                    }
                                }
                            
                            Stepper("", value: $template.defaultNumberOfDays, in: 1...365)
                                .labelsHidden()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                
                Section(header: Text("Tasks")) {
                    if template.tasks.isEmpty {
                        Text("No tasks yet. Tap 'Add Task' to get started.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(template.tasks, id: \.id) { task in
                            TaskEditRow(
                                task: task,
                                onUpdate: { updatedTask in
                                    if let index = template.tasks.firstIndex(where: { $0.id == task.id }) {
                                        template.tasks[index] = updatedTask
                                    }
                                }
                            )
                        }
                        .onDelete(perform: deleteTask)
                        .onMove(perform: moveTask)
                    }
                    
                    Button(action: {
                        showingAddTask = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Add Task")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Create Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        onSave(template)
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Add New Task", isPresented: $showingAddTask) {
                TextField("Task Title", text: $newTaskTitle)
                TextField("Task Description (Optional)", text: $newTaskDescription)
                Button("Cancel", role: .cancel) { }
                Button("Add") {
                    addTask()
                }
            }
        }
    }
    
    private func addTask() {
        let newTask = Task(title: newTaskTitle, description: newTaskDescription.isEmpty ? nil : newTaskDescription)
        template.tasks.append(newTask)
        newTaskTitle = ""
        newTaskDescription = ""
    }
    
    private func deleteTask(offsets: IndexSet) {
        template.tasks.remove(atOffsets: offsets)
    }
    
    private func moveTask(from source: IndexSet, to destination: Int) {
        template.tasks.move(fromOffsets: source, toOffset: destination)
    }
}

struct TemplateEditView: View {
    @State private var template: ProgramTemplate
    @State private var showingAddTask = false
    @State private var newTaskTitle = ""
    @State private var newTaskDescription = ""
    
    let onSave: (ProgramTemplate) -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    init(template: ProgramTemplate, onSave: @escaping (ProgramTemplate) -> Void) {
        self._template = State(initialValue: template)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Template Details")) {
                    TextField("Template Name", text: $template.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Description", text: $template.description, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                    
                    Picker("Category", selection: $template.category) {
                        ForEach(TemplateCategory.allCases, id: \.self) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default Number of Days")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text("days")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            TextField("Days", value: $template.defaultNumberOfDays, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 80)
                                .keyboardType(.numberPad)
                                .onChange(of: template.defaultNumberOfDays) { oldValue, newValue in
                                    // Ensure the value stays within valid range
                                    if newValue < 1 {
                                        template.defaultNumberOfDays = 1
                                    } else if newValue > 365 {
                                        template.defaultNumberOfDays = 365
                                    }
                                }
                            
                            Stepper("", value: $template.defaultNumberOfDays, in: 1...365)
                                .labelsHidden()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                
                Section(header: Text("Tasks")) {
                    ForEach(template.tasks, id: \.id) { task in
                        TaskEditRow(
                            task: task,
                            onUpdate: { updatedTask in
                                if let index = template.tasks.firstIndex(where: { $0.id == task.id }) {
                                    template.tasks[index] = updatedTask
                                }
                            }
                        )
                    }
                    .onDelete(perform: deleteTask)
                    .onMove(perform: moveTask)
                    
                    Button(action: {
                        showingAddTask = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Add Task")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Edit Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(template)
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Add New Task", isPresented: $showingAddTask) {
                TextField("Task Title", text: $newTaskTitle)
                TextField("Task Description (Optional)", text: $newTaskDescription)
                Button("Cancel", role: .cancel) { }
                Button("Add") {
                    addTask()
                }
            }
        }
    }
    
    private func addTask() {
        let newTask = Task(title: newTaskTitle, description: newTaskDescription.isEmpty ? nil : newTaskDescription)
        template.tasks.append(newTask)
        newTaskTitle = ""
        newTaskDescription = ""
    }
    
    private func deleteTask(offsets: IndexSet) {
        template.tasks.remove(atOffsets: offsets)
    }
    
    private func moveTask(from source: IndexSet, to destination: Int) {
        template.tasks.move(fromOffsets: source, toOffset: destination)
    }
}

struct TaskEditRow: View {
    let task: Task
    let onUpdate: (Task) -> Void
    
    @State private var title: String
    @State private var description: String
    
    init(task: Task, onUpdate: @escaping (Task) -> Void) {
        self.task = task
        self.onUpdate = onUpdate
        self._title = State(initialValue: task.title)
        self._description = State(initialValue: task.description ?? "")
    }
    
    var body: some View {
        HStack {
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                TextField("Task Title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: title) { _, newValue in
                        updateTask()
                    }
                
                TextField("Description (Optional)", text: $description)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.caption)
                    .onChange(of: description) { _, newValue in
                        updateTask()
                    }
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            // Update local state when task changes
            title = task.title
            description = task.description ?? ""
        }
    }
    
    private func updateTask() {
        let updatedTask = Task(
            id: task.id,
            title: title,
            description: description.isEmpty ? nil : description
        )
        onUpdate(updatedTask)
    }
}

struct TaskSelectionRow: View {
    let task: Task
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    if let description = task.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProgramTemplateSelectionView(
        onTemplateSelected: { _ in },
        onProgramCreated: { _ in },
        onCustomProgram: {}
    )
} 