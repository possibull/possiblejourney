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
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredTemplates) { template in
                                TemplateCardView(template: template) {
                                    print("DEBUG: Template tapped: \(template.name)")
                                    selectedTemplate = template
                                    print("DEBUG: selectedTemplate set to: \(selectedTemplate?.name ?? "nil")")
                                }
                            }
                        }
                        .padding()
                    }
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
                        onCustomProgram()
                    }
                    .fontWeight(.medium)
                }
            }

            .sheet(item: $selectedTemplate) { template in
                TemplateDetailView(template: template) { program in
                    onProgramCreated(program)
                    selectedTemplate = nil
                }
            }
        }
    }
}

struct TemplateCardView: View {
    let template: ProgramTemplate
    let onTap: () -> Void
    @State private var isExpanded = false
    
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
            .padding()
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
    
    @State private var startDate = Date()
    @State private var endOfDayTime = Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22) // Default 10pm
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Light background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection
                        tasksSection
                        startDateSection
                        endOfDaySection
                        startButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Template Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        // This will be handled by the sheet dismissal
                    }
                }
            }
            .onAppear {
                print("DEBUG: TemplateDetailView appeared for template: \(template.name)")
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
            let program = template.createProgram(startDate: startDate, endOfDayTime: endOfDayTime)
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