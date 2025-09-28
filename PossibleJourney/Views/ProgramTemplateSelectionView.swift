//
//  ProgramTemplateSelectionView.swift
//  PossibleJourney
//
//  Created by Ted Possible on 7/22/25.
//

import SwiftUI

struct ProgramTemplateSelectionView: View {
    @StateObject private var viewModel = ProgramTemplateViewModel()
    @StateObject private var metricStorage = MetricStorage()
    @State private var selectedTemplate: ProgramTemplate?
    @State private var showingCustomSetup = false
    @State private var editingTemplate: ProgramTemplate?
    @State private var templateToDelete: ProgramTemplate?
    @State private var showingTemplateCreate = false
    @EnvironmentObject var themeManager: ThemeManager
    
    let onTemplateSelected: (ProgramTemplate) -> Void
    let onProgramCreated: (Program) -> Void
    let onCustomProgram: () -> Void
    
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
            return Color(red: 1.0, green: 0.98, blue: 0.8) // Pastel yellow
        case .usa:
            return Color(red: 0.1, green: 0.3, blue: 0.8) // Blue for USA theme
        case .lasVegas:
            return Color(red: 1.0, green: 0.2, blue: 0.8) // Neon pink for Las Vegas theme
        case .dark:
            return Color.blue.opacity(0.7)
        case .light, .system:
            return Color.blue.opacity(0.7)
        }
    }
    

    
    var body: some View {
        NavigationView {
            ZStack {
                // Theme-aware background
                Color.clear
                    .themeAwareBackground()
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
                    .themeAwareCard()
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
                                        .background(viewModel.selectedCategory == category ? themeAccentColor : Color(.systemGray5))
                                        .foregroundColor(viewModel.selectedCategory == category ? .white : .primary)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(viewModel.selectedCategory == category ? themeAccentColor : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
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
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                // Edit action (only for non-default templates)
                                if !template.isDefault {
                                    Button {
                                        editingTemplate = template
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.orange)
                                }
                                
                                // Duplicate action (for all templates)
                                Button {
                                    let copy = viewModel.duplicateTemplate(template)
                                    editingTemplate = copy
                                } label: {
                                    Label("Duplicate", systemImage: "plus.square.on.square")
                                }
                                .tint(themeAccentColor)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                // Delete action (for all templates) - full swipe triggers with confirmation
                                Button {
                                    templateToDelete = template
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
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
                    HStack(spacing: 16) {
                        GlobalThemeSelector()
                        
                        Button("Custom") {
                            showingTemplateCreate = true
                        }
                        .fontWeight(.medium)
                    }
                }
            }

            .sheet(item: $selectedTemplate) { template in
                TemplateDetailView(
                    template: template,
                    onStartProgram: { program in
                        onProgramCreated(program)
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
                TemplateEditView(template: template, onSave: { updatedTemplate in
                    viewModel.updateTemplate(updatedTemplate)
                    editingTemplate = nil
                }, metricStorage: metricStorage)
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
                TemplateCreateView(onSave: { newTemplate in
                    viewModel.addTemplate(newTemplate)
                    showingTemplateCreate = false
                }, metricStorage: metricStorage)
            }
        }
    }
}

struct TemplateCardView: View {
    let template: ProgramTemplate
    let onTap: () -> Void
    @State private var isExpanded = false
    @EnvironmentObject var themeManager: ThemeManager
    
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
    
    private var themeAccentColor: Color {
        switch themeManager.currentTheme {
        case .birthday:
            return Color(red: 1.0, green: 0.8, blue: 0.9) // Pastel pink
        case .bea:
            return Color(red: 0.8, green: 0.9, blue: 1.0) // Pastel blue
        case .usa:
            return Color(red: 0.8, green: 0.1, blue: 0.2) // Red for USA theme
        case .lasVegas:
            return Color(red: 1.0, green: 0.8, blue: 0.2) // Neon gold for Las Vegas theme
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
            return Color(red: 1.0, green: 0.98, blue: 0.8) // Pastel yellow
        case .usa:
            return Color(red: 0.1, green: 0.3, blue: 0.8) // Blue for USA theme
        case .lasVegas:
            return Color(red: 1.0, green: 0.2, blue: 0.8) // Neon pink for Las Vegas theme
        case .dark:
            return Color.blue.opacity(0.7)
        case .light, .system:
            return Color.blue.opacity(0.7)
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                                            HStack {
                                Image(systemName: template.category.icon)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(themeAccentColor)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(themeSecondaryColor.opacity(0.2))
                                    )
                    
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
                            .foregroundColor(themeAccentColor)
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
                                .foregroundColor(themeAccentColor)
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
                            .foregroundColor(themeAccentColor)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .themeAwareCard()
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
    @EnvironmentObject var themeManager: ThemeManager
    
    init(template: ProgramTemplate, onStartProgram: @escaping (Program) -> Void, onDuplicate: @escaping (ProgramTemplate) -> Void, onDelete: @escaping (ProgramTemplate) -> Void) {
        self.template = template
        self.onStartProgram = onStartProgram
        self.onDuplicate = onDuplicate
        self.onDelete = onDelete
        self._numberOfDays = State(initialValue: template.defaultNumberOfDays)
    }
    
    private var themeAccentColor: Color {
        switch themeManager.currentTheme {
        case .birthday:
            return Color(red: 1.0, green: 0.8, blue: 0.9) // Pastel pink
        case .bea:
            return Color(red: 0.8, green: 0.9, blue: 1.0) // Pastel blue
        case .usa:
            return Color(red: 0.8, green: 0.1, blue: 0.2) // Red for USA theme
        case .lasVegas:
            return Color(red: 1.0, green: 0.8, blue: 0.2) // Neon gold for Las Vegas theme
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
            return Color(red: 1.0, green: 0.98, blue: 0.8) // Pastel yellow
        case .usa:
            return Color(red: 0.1, green: 0.3, blue: 0.8) // Blue for USA theme
        case .lasVegas:
            return Color(red: 1.0, green: 0.2, blue: 0.8) // Neon pink for Las Vegas theme
        case .dark:
            return Color.blue.opacity(0.7)
        case .light, .system:
            return Color.blue.opacity(0.7)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Theme-aware background
                Color.clear
                    .themeAwareBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        tasksSection
                        configurationSection
                        startButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Template Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(themeAccentColor)
                    .fontWeight(.medium)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button("Duplicate") {
                            onDuplicate(template)
                        }
                        .foregroundColor(themeAccentColor)
                        .fontWeight(.medium)
                        
                        Button("Delete") {
                            onDelete(template)
                        }
                        .foregroundColor(.red)
                        .fontWeight(.medium)
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Icon and title section
            HStack(spacing: 16) {
                // Category icon with themed background
                ZStack {
                    Circle()
                        .fill(themeSecondaryColor.opacity(0.3))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: template.category.icon)
                        .font(.title)
                        .foregroundColor(themeAccentColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(template.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            
            // Stats row
            HStack(spacing: 20) {
                StatItem(
                    icon: "calendar",
                    value: "\(template.defaultNumberOfDays)",
                    label: "days",
                    color: themeAccentColor
                )
                
                StatItem(
                    icon: "tag",
                    value: template.category.displayName,
                    label: "category",
                    color: themeSecondaryColor
                )
                
                StatItem(
                    icon: "checkmark.circle",
                    value: "\(template.tasks.count)",
                    label: "tasks",
                    color: themeAccentColor
                )
                
                Spacer()
            }
        }
        .padding(20)
        .themeAwareCard()
    }
    
    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(themeAccentColor)
                    .font(.title2)
                
                Text("Daily Tasks")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            LazyVStack(spacing: 12) {
                ForEach(Array(template.tasks.enumerated()), id: \.element.id) { index, task in
                    TaskDetailRow(
                        task: task,
                        index: index + 1,
                        accentColor: themeAccentColor,
                        secondaryColor: themeSecondaryColor
                    )
                }
            }
        }
    }
    
    private var configurationSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "gear")
                    .foregroundColor(themeAccentColor)
                    .font(.title2)
                
                Text("Program Configuration")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Start Date
                ConfigurationRow(
                    icon: "calendar.badge.plus",
                    title: "Start Date",
                    content: {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .accentColor(themeAccentColor)
                    },
                    accentColor: themeAccentColor
                )
                
                // Number of Days
                ConfigurationRow(
                    icon: "number.circle",
                    title: "Number of Days",
                    content: {
                        VStack(spacing: 12) {
                            HStack {
                                Toggle("Custom Duration", isOn: $useCustomDays)
                                    .font(.body)
                                    .accentColor(themeAccentColor)
                                
                                Spacer()
                            }
                            
                            if useCustomDays {
                                HStack {
                                    Text("days")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("Days", value: $numberOfDays, format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                        .keyboardType(.numberPad)
                                        .onChange(of: numberOfDays) { oldValue, newValue in
                                            if newValue < 1 {
                                                numberOfDays = 1
                                            } else if newValue > 365 {
                                                numberOfDays = 365
                                            }
                                        }
                                    
                                    Stepper("", value: $numberOfDays, in: 1...365)
                                        .labelsHidden()
                                        .accentColor(themeAccentColor)
                                    
                                    Spacer()
                                }
                            } else {
                                HStack {
                                    Text("\(template.defaultNumberOfDays) days (default)")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                        }
                    },
                    accentColor: themeAccentColor
                )
                
                // End of Day Time
                ConfigurationRow(
                    icon: "clock",
                    title: "End of Day Time",
                    content: {
                        DatePicker("End of Day Time", selection: $endOfDayTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                            .accentColor(themeAccentColor)
                    },
                    accentColor: themeAccentColor
                )
            }
        }
    }
    
    private var startButton: some View {
        Button(action: {
            let customDays = useCustomDays ? numberOfDays : nil
            let program = template.createProgram(startDate: startDate, endOfDayTime: endOfDayTime, numberOfDays: customDays)
            // Dismiss the sheet first, then start the program
            presentationMode.wrappedValue.dismiss()
            // Use a slight delay to ensure the sheet is dismissed before starting the program
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onStartProgram(program)
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "play.fill")
                    .font(.title3)
                Text("Start Program")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [themeAccentColor, themeAccentColor.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(
                color: themeAccentColor.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .padding(.top, 8)
    }
}

// MARK: - Supporting Views

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TaskDetailRow: View {
    let task: Task
    let index: Int
    let accentColor: Color
    let secondaryColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Task number badge
            ZStack {
                Circle()
                    .fill(secondaryColor.opacity(0.3))
                    .frame(width: 32, height: 32)
                
                Text("\(index)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(accentColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(task.title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if task.requiresPhoto {
                        Image(systemName: "camera.fill")
                            .foregroundColor(accentColor)
                            .font(.caption)
                    }
                }
                
                if let description = task.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .themeAwareCard()
    }
}

struct ConfigurationRow<Content: View>: View {
    let icon: String
    let title: String
    let content: Content
    let accentColor: Color
    
    init(icon: String, title: String, @ViewBuilder content: () -> Content, accentColor: Color) {
        self.icon = icon
        self.title = title
        self.content = content()
        self.accentColor = accentColor
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(accentColor)
                    .font(.title3)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            content
        }
        .padding(16)
        .themeAwareCard()
    }
}

struct TemplateCreateView: View {
    @State private var template: ProgramTemplate
    @State private var showingAddTask = false
    @State private var newTaskTitle = ""
    @State private var newTaskDescription = ""
    @State private var newTaskRequiresPhoto = false
    @ObservedObject var metricStorage: MetricStorage
    
    let onSave: (ProgramTemplate) -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    init(onSave: @escaping (ProgramTemplate) -> Void, metricStorage: MetricStorage) {
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
        self.metricStorage = metricStorage
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
                                },
                                metricStorage: metricStorage
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
        let newTask = Task(
            title: newTaskTitle, 
            description: newTaskDescription.isEmpty ? nil : newTaskDescription, 
            requiresPhoto: newTaskRequiresPhoto,
            taskType: .growth, // Default to growth task type
            progressRule: nil, // No progress rule initially
            linkedMetricId: nil  // No linked metric initially
        )
        template.tasks.append(newTask)
        newTaskTitle = ""
        newTaskDescription = ""
        newTaskRequiresPhoto = false
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
    @State private var newTaskRequiresPhoto = false
    @ObservedObject var metricStorage: MetricStorage
    
    let onSave: (ProgramTemplate) -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    init(template: ProgramTemplate, onSave: @escaping (ProgramTemplate) -> Void, metricStorage: MetricStorage) {
        self._template = State(initialValue: template)
        self.metricStorage = metricStorage
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
                            },
                            metricStorage: metricStorage
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
        let newTask = Task(
            title: newTaskTitle, 
            description: newTaskDescription.isEmpty ? nil : newTaskDescription, 
            requiresPhoto: newTaskRequiresPhoto,
            taskType: .growth, // Default to growth task type
            progressRule: nil, // No progress rule initially
            linkedMetricId: nil  // No linked metric initially
        )
        template.tasks.append(newTask)
        newTaskTitle = ""
        newTaskDescription = ""
        newTaskRequiresPhoto = false
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
    @ObservedObject var metricStorage: MetricStorage
    
    @State private var title: String
    @State private var description: String
    @State private var requiresPhoto: Bool
    @State private var taskType: String = "growth"
    @State private var linkedMetricId: String = ""
    @State private var linkedMetricName: String = ""
    @State private var progressRuleType: String = "delta_threshold"
    @State private var ruleConfiguration: String = ""
    @State private var progressRule: ProgressRule?
    
    init(task: Task, onUpdate: @escaping (Task) -> Void, metricStorage: MetricStorage) {
        self.task = task
        self.onUpdate = onUpdate
        self.metricStorage = metricStorage
        self._title = State(initialValue: task.title)
        self._description = State(initialValue: task.description ?? "")
        self._requiresPhoto = State(initialValue: task.requiresPhoto)
        self._progressRule = State(initialValue: task.progressRule)
    }
    
    
    var body: some View {
        HStack {
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TextField("Task Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: title) { _, newValue in
                            updateTask()
                        }
                    
                    // Photo requirement indicator
                    if requiresPhoto {
                        Image(systemName: "camera.fill")
                            .foregroundColor(.blue)
                            .accessibilityIdentifier("PhotoRequirementIndicator")
                    }
                }
                
                TextField("Description (Optional)", text: $description)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.caption)
                    .onChange(of: description) { _, newValue in
                        updateTask()
                    }
                
                // Task Type Selection
                Picker("Task Type", selection: $taskType) {
                    Text("Growth").tag("growth")
                    Text("Maintenance").tag("maintenance")
                    Text("Recovery").tag("recovery")
                }
                .pickerStyle(SegmentedPickerStyle())
                .font(.caption)
                .onChange(of: taskType) { _, newValue in
                    updateTask()
                }
                
                // Progress Rules UI (only show for Growth tasks)
                if taskType == "growth" {
                    TaskRuleBuilderView(
                        metricStorage: metricStorage,
                        progressRule: $progressRule
                    )
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(8)
                    .onChange(of: progressRule) { _, _ in
                        updateTask()
                    }
                }
                
                Toggle("Requires Photo", isOn: $requiresPhoto)
                    .font(.caption)
                    .onChange(of: requiresPhoto) { _, newValue in
                        updateTask()
                    }
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            // Update local state when task changes
            title = task.title
            description = task.description ?? ""
            requiresPhoto = task.requiresPhoto
            taskType = task.taskType.rawValue // Use actual taskType from data model
            linkedMetricId = task.linkedMetricId ?? ""
            progressRule = task.progressRule // Initialize progress rule
            
            
            // Initialize metric name from ID
            if let metricId = task.linkedMetricId,
               let metric = metricStorage.getMetric(by: metricId) {
                linkedMetricName = metric.name
            } else {
                linkedMetricName = ""
            }
        }
    }
    
    private func updateTask() {
        let updatedTask = Task(
            id: task.id,
            title: title,
            description: description.isEmpty ? nil : description,
            requiresPhoto: requiresPhoto,
            taskType: TaskType(rawValue: taskType) ?? .growth,
            progressRule: progressRule,
            linkedMetricId: linkedMetricId.isEmpty ? nil : linkedMetricId
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