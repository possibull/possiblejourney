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
    @Namespace private var bottomID
    
    var onSave: (Program) -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        numberOfDaysSection
                        startDateSection
                        addTaskSection(proxy: proxy)
                        taskListSection
                        saveButton
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    .id(bottomID)
                }
            }
        }
        .accessibilityIdentifier("ProgramSetupScreen")
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
                .font(.headline)
                .foregroundColor(.hardRed)
                .padding(.bottom, 2)
            Text("Number of Days:")
                .font(.headline)
                .foregroundColor(.white)
            Picker("Number of Days", selection: $numberOfDays) {
                ForEach(1...365, id: \.self) { day in
                    Text("\(day)").tag(day)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 60) // Reduced height
            .clipped()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
            .padding(.vertical, 4)
            .onChange(of: numberOfDays) { oldValue, newValue in
                numberOfDaysText = "\(newValue)"
            }
            HStack {
                Spacer()
                TextField("Days", text: $numberOfDaysText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 28, weight: .heavy)) // Reduced font size
                    .foregroundColor(.hardRed)
                    .frame(width: 70)
                    .onChange(of: numberOfDaysText) { oldValue, newValue in
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
                    .padding(.trailing, 8)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
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

    private func addTaskSection(proxy: ScrollViewProxy) -> some View {
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
                    // Auto-scroll to bottom after adding a task
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo(bottomID, anchor: .bottom)
                        }
                    }
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
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var saveButton: some View {
        Button(action: {
            let template = ProgramTemplate(
                name: "Custom Program",
                description: "A custom program created by the user.",
                category: .custom,
                defaultNumberOfDays: numberOfDays,
                tasks: tasks,
                isDefault: false
            )
            let storage = ProgramTemplateStorage()
            storage.add(template)
            let program = Program(
                id: UUID(),
                startDate: startDate,
                endOfDayTime: Calendar.current.startOfDay(for: Date()).addingTimeInterval(60*60*22), // Default 10pm
                lastCompletedDay: nil,
                templateID: template.id,
                customNumberOfDays: nil
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