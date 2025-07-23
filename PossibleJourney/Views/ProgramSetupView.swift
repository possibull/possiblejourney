import SwiftUI

extension Color {
    static let hardRed = Color(red: 229/255, green: 57/255, blue: 53/255)
}

struct ProgramSetupView: View {
    @State private var taskTitle: String = ""
    @State private var taskDescription: String = ""
    @State private var tasks: [Task] = []
    @State private var showNameError: Bool = false
    @State private var showDescriptionError: Bool = false
    @State private var numberOfDays: Int = 75
    @State private var startDate: Date = Date()
    private let viewModel = ProgramSetupViewModel()
    var onSave: ((Program) -> Void)? = nil
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Program Setup")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 24)
                    // Number of days
                    HStack {
                        Text("Number of Days:")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        TextField("Days", value: $numberOfDays, formatter: NumberFormatter(), onEditingChanged: { _ in
                            if numberOfDays < 1 { numberOfDays = 1 }
                            if numberOfDays > 365 { numberOfDays = 365 }
                        })
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                            .multilineTextAlignment(.center)
                            .font(.title2.bold())
                            .foregroundColor(Color.hardRed)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.white))
                        Stepper(value: $numberOfDays, in: 1...365) {
                            EmptyView()
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                    // Start date
                    HStack {
                        Text("Start Date:")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .labelsHidden()
                            .colorScheme(.dark)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                    // Task entry
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add Task")
                            .font(.headline)
                            .foregroundColor(Color.hardRed)
                        TextField("Task Title", text: $taskTitle)
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                            .foregroundColor(.black)
                            .accessibilityIdentifier("Task Title")
                        TextField("Task Description (optional)", text: $taskDescription)
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                            .foregroundColor(.black)
                            .accessibilityIdentifier("Task Description")
                        Button(action: {
                            if !taskTitle.isEmpty {
                                let newTask = Task(id: UUID(), title: taskTitle, description: taskDescription.isEmpty ? nil : taskDescription)
                                tasks.append(newTask)
                                taskTitle = ""
                                taskDescription = ""
                            }
                        }) {
                            Text("Add Task")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.hardRed)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                    // Task list
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tasks")
                            .font(.headline)
                            .foregroundColor(Color.hardRed)
                        ForEach(tasks, id: \.id) { task in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(task.title)
                                    .font(.title3.bold())
                                    .foregroundColor(.black)
                                if let desc = task.description, !desc.isEmpty {
                                    Text(desc)
                                        .font(.subheadline)
                                        .foregroundColor(.black.opacity(0.7))
                                }
                            }
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                    // Save button
                    Button(action: {
                        print("DEBUG: Save Program button action triggered")
                        print("DEBUG: Save Program tapped, tasks count: \(tasks.count)")
                        viewModel.numberOfDays = numberOfDays
                        viewModel.tasks = tasks
                        if let program = viewModel.saveProgram() {
                            let saved = Program(id: program.id, startDate: startDate, numberOfDays: program.numberOfDays, tasks: program.tasks)
                            ProgramStorage().save(program: saved)
                            print("DEBUG: onSave closure called with program: \(saved)")
                            onSave?(saved)
                        } else {
                            print("DEBUG: saveProgram() returned nil")
                            print("DEBUG: Failed to save program")
                        }
                    }) {
                        Text("Save Program")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.hardRed)
                            .cornerRadius(8)
                    }
                    .disabled(tasks.isEmpty)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal)
            }
        }
    }
} 