//
//  TemplateTaskListView.swift
//  PossibleJourney
//
//  Created by Ted Possible on 9/27/25.
//

import SwiftUI

struct TemplateTaskListView: View {
    @Binding var template: ProgramTemplate
    @ObservedObject var metricStorage: MetricStorage
    @State private var showingAddTask = false
    @State private var newTaskTitle = ""
    @State private var newTaskDescription = ""
    @State private var newTaskRequiresPhoto = false
    
    var body: some View {
        Section(header: Text("Tasks")) {
            ForEach(template.tasks) { task in
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
        .alert("Add Task", isPresented: $showingAddTask) {
            TextField("Task Title", text: $newTaskTitle)
            TextField("Description (Optional)", text: $newTaskDescription)
            Button("Add") {
                addTask()
            }
            Button("Cancel", role: .cancel) {
                newTaskTitle = ""
                newTaskDescription = ""
                newTaskRequiresPhoto = false
            }
        } message: {
            Text("Enter the details for the new task.")
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
