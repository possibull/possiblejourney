import SwiftUI

extension Color {
    static let hardRed = Color(red: 229/255, green: 57/255, blue: 53/255)
}

struct ProgramSetupView: View {
    @State private var numberOfDays: Int = 75
    @State private var numberOfDaysText: String = "75"
    @State private var startDate: Date = Date()
    @State private var tasks: [Task] = []
    @State private var newTaskTitle: String = ""
    @State private var newTaskDescription: String = ""
    
    var onSave: (Program) -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        numberOfDaysSection
                        startDateSection
                        addTaskSection
                        taskListSection
                    }
                    .padding(.horizontal)
                }
                saveButton
            }
        }
    }
    
    private var headerSection: some View {
        Text("Program Setup")
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(.white)
            .padding(.top, 24)
    }
    
    private var numberOfDaysSection: some View {
        VStack(alignment: .leading) {
            Text("Days")
                .font(.title2.bold())
                .foregroundColor(.hardRed)
                .padding(.bottom, 2)
            Text("Number of Days:")
                .font(.headline)
                .foregroundColor(.white)
            HStack {
                TextField("Days", text: $numberOfDaysText)
                    .keyboardType(.numberPad)
                    .frame(width: 60)
                    .multilineTextAlignment(.center)
                    .font(.title2.bold())
                    .foregroundColor(.hardRed)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.white))
                    .onChange(of: numberOfDaysText) { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if let value = Int(filtered), value >= 1, value <= 365 {
                            numberOfDays = value
                            numberOfDaysText = "\(value)"
                        } else if filtered.isEmpty {
                            numberOfDays = 1
                            numberOfDaysText = "1"
                        } else if let value = Int(filtered), value < 1 {
                            numberOfDays = 1
                            numberOfDaysText = "1"
                        } else if let value = Int(filtered), value > 365 {
                            numberOfDays = 365
                            numberOfDaysText = "365"
                        } else {
                            numberOfDaysText = filtered
                        }
                    }
                Spacer()
            }
            Picker("Number of Days", selection: $numberOfDays) {
                ForEach(1...365, id: \.self) { day in
                    Text("\(day)").tag(day)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 100)
            .clipped()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
            .padding(.vertical, 8)
            .onChange(of: numberOfDays) { newValue in
                numberOfDaysText = "\(newValue)"
            }
            HStack {
                Spacer()
                TextField("Days", text: $numberOfDaysText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 48, weight: .heavy))
                    .foregroundColor(.hardRed)
                    .frame(width: 100)
                    .onChange(of: numberOfDaysText) { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if let value = Int(filtered), value >= 1, value <= 365 {
                            numberOfDays = value
                            numberOfDaysText = "\(value)"
                        } else if filtered.isEmpty {
                            numberOfDays = 1
                            numberOfDaysText = "1"
                        } else if let value = Int(filtered), value < 1 {
                            numberOfDays = 1
                            numberOfDaysText = "1"
                        } else if let value = Int(filtered), value > 365 {
                            numberOfDays = 365
                            numberOfDaysText = "365"
                        } else {
                            numberOfDaysText = filtered
                        }
                    }
                Spacer()
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
    }
    
    private var startDateSection: some View {
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
    }
    
    private var addTaskSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Add Task")
                .font(.headline)
                .foregroundColor(.hardRed)
            TextField("Task Title", text: $newTaskTitle)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                .foregroundColor(.black)
                .accessibilityIdentifier("Task Title")
            TextField("Task Description (optional)", text: $newTaskDescription)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                .foregroundColor(.black)
                .accessibilityIdentifier("Task Description")
            Button(action: {
                if !newTaskTitle.isEmpty {
                    let newTask = Task(id: UUID(), title: newTaskTitle, description: newTaskDescription)
                    tasks.append(newTask)
                    newTaskTitle = ""
                    newTaskDescription = ""
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
    }
    
    private var taskListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tasks")
                .font(.headline)
                .foregroundColor(.hardRed)
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
    }
    
    private var saveButton: some View {
        Button(action: {
            let program = Program(
                id: UUID(),
                startDate: startDate,
                numberOfDays: numberOfDays,
                tasks: tasks
            )
            onSave(program)
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
} 