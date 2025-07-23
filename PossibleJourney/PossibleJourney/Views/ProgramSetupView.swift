import SwiftUI

struct ProgramSetupView: View {
    @State private var numberOfDays: Int = 75
    @State private var startDate: Date = Date()
    @State private var tasks: [Task] = []
    @State private var newTaskTitle: String = ""
    @State private var newTaskDescription: String = ""
    
    var onSave: (Program) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Program Setup")
                .font(.largeTitle)
                .bold()
            HStack {
                Text("Number of Days:")
                Stepper(value: $numberOfDays, in: 1...365) {
                    Text("\(numberOfDays)")
                }
            }
            HStack {
                Text("Start Date:")
                DatePicker("", selection: $startDate, displayedComponents: .date)
                    .labelsHidden()
            }
            Divider()
            Text("Add Task")
                .font(.headline)
            TextField("Task Title", text: $newTaskTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Task Description (optional)", text: $newTaskDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Add Task") {
                guard !newTaskTitle.isEmpty else { return }
                tasks.append(Task(title: newTaskTitle, description: newTaskDescription))
                newTaskTitle = ""
                newTaskDescription = ""
            }
            Divider()
            Text("Tasks")
                .font(.headline)
            List {
                ForEach(tasks) { task in
                    VStack(alignment: .leading) {
                        Text(task.title).bold()
                        if !task.description.isEmpty {
                            Text(task.description).font(.subheadline)
                        }
                    }
                }.onDelete { indexSet in
                    tasks.remove(atOffsets: indexSet)
                }
            }
            Button("Save Program") {
                let program = Program(
                    id: UUID(),
                    numberOfDays: numberOfDays,
                    startDate: startDate,
                    tasks: tasks
                )
                onSave(program)
            }
            .disabled(tasks.isEmpty)
            .padding(.top)
        }
        .padding()
    }
} 