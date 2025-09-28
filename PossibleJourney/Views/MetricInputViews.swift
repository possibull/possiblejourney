import SwiftUI

// MARK: - Base Metric Input View Protocol

protocol MetricInputViewProtocol: View {
    var metric: Metric { get }
    var progressRule: ProgressRule? { get }
    var progressRuleFeedback: ProgressRuleFeedback? { get }
    var canCheckOff: Bool { get }
    var checkOffButtonState: CheckOffButtonState { get }
    var showsMissedTaskProtocol: Bool { get }
    var missedTaskProtocolView: AnyView? { get }
    
    func updateValue(_ newValue: Any)
    func createTaskInstance(for task: Task, on date: Date) -> TaskInstance?
    func createEvaluationContext() -> ProgramMetricContext?
}

// MARK: - Progress Rule Feedback

struct ProgressRuleFeedback {
    let passed: Bool
    let message: String
    let status: FeedbackStatus
}

enum FeedbackStatus: String, CaseIterable, Identifiable {
    case pending = "pending"
    case passed = "passed"
    case failed = "failed"
    
    var id: String { self.rawValue }
}

enum CheckOffButtonState: String, CaseIterable, Identifiable {
    case enabled = "enabled"
    case disabled = "disabled"
    
    var id: String { self.rawValue }
}

// MARK: - Number Metric Input View

struct NumberMetricInputView: View, MetricInputViewProtocol {
    let metric: Metric
    @Binding var value: Double
    let progressRule: ProgressRule?
    
    @State internal var progressRuleFeedback: ProgressRuleFeedback?
    @State internal var canCheckOff: Bool = false
    @State internal var checkOffButtonState: CheckOffButtonState = .disabled
    @State internal var showsMissedTaskProtocol: Bool = false
    @State internal var missedTaskProtocolView: AnyView?
    
    var metricName: String { metric.name }
    var metricUnit: String { metric.unit }
    var currentValue: Double { value }
    
    init(metric: Metric, value: Binding<Double>, progressRule: ProgressRule? = nil) {
        self.metric = metric
        self._value = value
        self.progressRule = progressRule
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(metricName)
                    .font(.headline)
                Spacer()
                Text(metricUnit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                TextField("Enter \(metricUnit)", value: $value, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .onChange(of: value) { _, newValue in
                        updateValue(newValue)
                        evaluateProgressRule()
                    }
                
                if let feedback = progressRuleFeedback {
                    Image(systemName: feedback.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(feedback.passed ? .green : .red)
                }
            }
            
            if let feedback = progressRuleFeedback {
                Text(feedback.message)
                    .font(.caption)
                    .foregroundColor(feedback.passed ? .green : .red)
            }
            
            if showsMissedTaskProtocol {
                missedTaskProtocolView
            }
        }
        .onAppear {
            evaluateProgressRule()
        }
    }
    
    func updateValue(_ newValue: Any) {
        if let doubleValue = newValue as? Double {
            value = doubleValue
        }
    }
    
    func isValidInput(_ input: String) -> Bool {
        guard let _ = Double(input) else { return false }
        return true
    }
    
    func createTaskInstance(for task: Task, on date: Date) -> TaskInstance? {
        guard let progressRule = progressRule else { return nil }
        
        let status: TaskInstanceStatus = progressRuleFeedback?.passed == true ? .passed : .blocked
        let blockReason: BlockReason? = status == .blocked ? .progressRuleFailed : nil
        let notes: String? = status == .blocked ? "Progress rule failed: \(progressRuleFeedback?.message ?? "")" : nil
        
        return TaskInstance(
            taskId: task.id.uuidString,
            programId: "default-program-id", // This would need to be passed in
            date: date,
            status: status,
            blockReason: blockReason,
            notes: notes
        )
    }
    
    func createEvaluationContext() -> ProgramMetricContext? {
        // This would need to be implemented with actual measurement data
        // For now, return nil to indicate no context available
        return nil
    }
    
    private func evaluateProgressRule() {
        guard let progressRule = progressRule else {
            progressRuleFeedback = nil
            canCheckOff = true
            checkOffButtonState = .enabled
            showsMissedTaskProtocol = false
            return
        }
        
        // Use real ProgressRuleEvaluator
        let passed = evaluateRule(progressRule, currentValue: value)
        
        progressRuleFeedback = ProgressRuleFeedback(
            passed: passed,
            message: passed ? "Rule passed" : "Rule failed",
            status: passed ? .passed : .failed
        )
        
        canCheckOff = passed
        checkOffButtonState = passed ? .enabled : .disabled
        showsMissedTaskProtocol = !passed
        
        if showsMissedTaskProtocol {
            missedTaskProtocolView = AnyView(
                MissedTaskProtocolView(
                    task: Task(id: UUID(), title: metricName, taskType: .growth),
                    onDismiss: { showsMissedTaskProtocol = false }
                )
            )
        }
    }
    
    private func evaluateRule(_ rule: ProgressRule, currentValue: Double) -> Bool {
        // Simplified rule evaluation
        // In a real implementation, this would use ProgressRuleEvaluator
        switch rule {
        case .threshold(let metricAlias, let comparator, let target):
            switch comparator {
            case ">=": return currentValue >= target
            case "<=": return currentValue <= target
            case "==": return currentValue == target
            case "!=": return currentValue != target
            default: return false
            }
        case .deltaThreshold(let minimumImprovement):
            // For demo purposes, assume we need to improve by the minimum amount
            return currentValue >= minimumImprovement
        case .countMin(let minimumCount):
            return currentValue >= Double(minimumCount)
        case .booleanCondition(let condition):
            // Simplified boolean evaluation
            return condition.lowercased() == "true" ? currentValue > 0 : currentValue == 0
        case .rollingWindow(let targetCount, _):
            // For demo purposes, just check if current value meets target
            return currentValue >= Double(targetCount)
        }
    }
}

// MARK: - Count Metric Input View

struct CountMetricInputView: View, MetricInputViewProtocol {
    let metric: Metric
    @Binding var value: Int
    let progressRule: ProgressRule?
    
    @State internal var progressRuleFeedback: ProgressRuleFeedback?
    @State internal var canCheckOff: Bool = false
    @State internal var checkOffButtonState: CheckOffButtonState = .disabled
    @State internal var showsMissedTaskProtocol: Bool = false
    @State internal var missedTaskProtocolView: AnyView?
    
    var metricName: String { metric.name }
    var metricUnit: String { metric.unit }
    var currentValue: Int { value }
    
    init(metric: Metric, value: Binding<Int>, progressRule: ProgressRule? = nil) {
        self.metric = metric
        self._value = value
        self.progressRule = progressRule
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(metricName)
                    .font(.headline)
                Spacer()
                Text(metricUnit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                TextField("Enter count", value: $value, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .onChange(of: value) { _, newValue in
                        updateValue(newValue)
                        evaluateProgressRule()
                    }
                
                if let feedback = progressRuleFeedback {
                    Image(systemName: feedback.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(feedback.passed ? .green : .red)
                }
            }
            
            if let feedback = progressRuleFeedback {
                Text(feedback.message)
                    .font(.caption)
                    .foregroundColor(feedback.passed ? .green : .red)
            }
            
            if showsMissedTaskProtocol {
                missedTaskProtocolView
            }
        }
        .onAppear {
            evaluateProgressRule()
        }
    }
    
    func updateValue(_ newValue: Any) {
        if let intValue = newValue as? Int {
            value = intValue
        }
    }
    
    func createTaskInstance(for task: Task, on date: Date) -> TaskInstance? {
        guard let progressRule = progressRule else { return nil }
        
        let status: TaskInstanceStatus = progressRuleFeedback?.passed == true ? .passed : .blocked
        let blockReason: BlockReason? = status == .blocked ? .progressRuleFailed : nil
        let notes: String? = status == .blocked ? "Progress rule failed: \(progressRuleFeedback?.message ?? "")" : nil
        
        return TaskInstance(
            taskId: task.id.uuidString,
            programId: "default-program-id", // This would need to be passed in
            date: date,
            status: status,
            blockReason: blockReason,
            notes: notes
        )
    }
    
    func createEvaluationContext() -> ProgramMetricContext? {
        return nil
    }
    
    private func evaluateProgressRule() {
        guard let progressRule = progressRule else {
            progressRuleFeedback = nil
            canCheckOff = true
            checkOffButtonState = .enabled
            showsMissedTaskProtocol = false
            return
        }
        
        let passed = evaluateRule(progressRule, currentValue: Double(value))
        
        progressRuleFeedback = ProgressRuleFeedback(
            passed: passed,
            message: passed ? "Rule passed" : "Rule failed",
            status: passed ? .passed : .failed
        )
        
        canCheckOff = passed
        checkOffButtonState = passed ? .enabled : .disabled
        showsMissedTaskProtocol = !passed
        
        if showsMissedTaskProtocol {
            missedTaskProtocolView = AnyView(
                MissedTaskProtocolView(
                    task: Task(id: UUID(), title: metricName, taskType: .growth),
                    onDismiss: { showsMissedTaskProtocol = false }
                )
            )
        }
    }
    
    private func evaluateRule(_ rule: ProgressRule, currentValue: Double) -> Bool {
        switch rule {
        case .threshold(let metricAlias, let comparator, let target):
            switch comparator {
            case ">=": return currentValue >= target
            case "<=": return currentValue <= target
            case "==": return currentValue == target
            case "!=": return currentValue != target
            default: return false
            }
        case .deltaThreshold(let minimumImprovement):
            return currentValue >= minimumImprovement
        case .countMin(let minimumCount):
            return currentValue >= Double(minimumCount)
        case .booleanCondition(let condition):
            return condition.lowercased() == "true" ? currentValue > 0 : currentValue == 0
        case .rollingWindow(let targetCount, _):
            return currentValue >= Double(targetCount)
        }
    }
}

// MARK: - Boolean Metric Input View

struct BooleanMetricInputView: View, MetricInputViewProtocol {
    let metric: Metric
    @Binding var value: Bool
    let progressRule: ProgressRule?
    
    @State internal var progressRuleFeedback: ProgressRuleFeedback?
    @State internal var canCheckOff: Bool = false
    @State internal var checkOffButtonState: CheckOffButtonState = .disabled
    @State internal var showsMissedTaskProtocol: Bool = false
    @State internal var missedTaskProtocolView: AnyView?
    
    var metricName: String { metric.name }
    var metricUnit: String { metric.unit }
    var currentValue: Bool { value }
    
    init(metric: Metric, value: Binding<Bool>, progressRule: ProgressRule? = nil) {
        self.metric = metric
        self._value = value
        self.progressRule = progressRule
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(metricName)
                    .font(.headline)
                Spacer()
                Text(metricUnit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Toggle("", isOn: $value)
                    .onChange(of: value) { _, newValue in
                        updateValue(newValue)
                        evaluateProgressRule()
                    }
                
                if let feedback = progressRuleFeedback {
                    Image(systemName: feedback.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(feedback.passed ? .green : .red)
                }
            }
            
            if let feedback = progressRuleFeedback {
                Text(feedback.message)
                    .font(.caption)
                    .foregroundColor(feedback.passed ? .green : .red)
            }
            
            if showsMissedTaskProtocol {
                missedTaskProtocolView
            }
        }
        .onAppear {
            evaluateProgressRule()
        }
    }
    
    func updateValue(_ newValue: Any) {
        if let boolValue = newValue as? Bool {
            value = boolValue
        }
    }
    
    func createTaskInstance(for task: Task, on date: Date) -> TaskInstance? {
        guard let progressRule = progressRule else { return nil }
        
        let status: TaskInstanceStatus = progressRuleFeedback?.passed == true ? .passed : .blocked
        let blockReason: BlockReason? = status == .blocked ? .progressRuleFailed : nil
        let notes: String? = status == .blocked ? "Progress rule failed: \(progressRuleFeedback?.message ?? "")" : nil
        
        return TaskInstance(
            taskId: task.id.uuidString,
            programId: "default-program-id", // This would need to be passed in
            date: date,
            status: status,
            blockReason: blockReason,
            notes: notes
        )
    }
    
    func createEvaluationContext() -> ProgramMetricContext? {
        return nil
    }
    
    private func evaluateProgressRule() {
        guard let progressRule = progressRule else {
            progressRuleFeedback = nil
            canCheckOff = true
            checkOffButtonState = .enabled
            showsMissedTaskProtocol = false
            return
        }
        
        let passed = evaluateRule(progressRule, currentValue: value)
        
        progressRuleFeedback = ProgressRuleFeedback(
            passed: passed,
            message: passed ? "Rule passed" : "Rule failed",
            status: passed ? .passed : .failed
        )
        
        canCheckOff = passed
        checkOffButtonState = passed ? .enabled : .disabled
        showsMissedTaskProtocol = !passed
        
        if showsMissedTaskProtocol {
            missedTaskProtocolView = AnyView(
                MissedTaskProtocolView(
                    task: Task(id: UUID(), title: metricName, taskType: .growth),
                    onDismiss: { showsMissedTaskProtocol = false }
                )
            )
        }
    }
    
    private func evaluateRule(_ rule: ProgressRule, currentValue: Bool) -> Bool {
        switch rule {
        case .threshold(let metricAlias, let comparator, let target):
            let targetBool = target > 0
            switch comparator {
            case "==": return currentValue == targetBool
            case "!=": return currentValue != targetBool
            default: return false
            }
        case .deltaThreshold(let minimumImprovement):
            return currentValue && minimumImprovement > 0
        case .countMin(let minimumCount):
            return currentValue && minimumCount > 0
        case .booleanCondition(let condition):
            let expectedValue = condition.lowercased() == "true"
            return currentValue == expectedValue
        case .rollingWindow(let targetCount, _):
            return currentValue && targetCount > 0
        }
    }
}

// MARK: - Composite Metric Input View

struct CompositeMetricInputView: View, MetricInputViewProtocol {
    let metric: Metric
    @Binding var weight: Double
    @Binding var reps: Int
    let progressRule: ProgressRule?
    
    @State internal var progressRuleFeedback: ProgressRuleFeedback?
    @State internal var canCheckOff: Bool = false
    @State internal var checkOffButtonState: CheckOffButtonState = .disabled
    @State internal var showsMissedTaskProtocol: Bool = false
    @State internal var missedTaskProtocolView: AnyView?
    
    var metricName: String { metric.name }
    var metricUnit: String { metric.unit }
    var currentValue: Double { weight * Double(reps) } // Volume calculation
    
    init(metric: Metric, weight: Binding<Double>, reps: Binding<Int>, progressRule: ProgressRule? = nil) {
        self.metric = metric
        self._weight = weight
        self._reps = reps
        self.progressRule = progressRule
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(metricName)
                    .font(.headline)
                Spacer()
                Text(metricUnit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Weight")
                        .font(.caption)
                    TextField("Weight", value: $weight, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .onChange(of: weight) { _, _ in evaluateProgressRule() }
                }
                
                VStack(alignment: .leading) {
                    Text("Reps")
                        .font(.caption)
                    TextField("Reps", value: $reps, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .onChange(of: reps) { _, _ in evaluateProgressRule() }
                }
                
                if let feedback = progressRuleFeedback {
                    Image(systemName: feedback.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(feedback.passed ? .green : .red)
                }
            }
            
            if let feedback = progressRuleFeedback {
                Text(feedback.message)
                    .font(.caption)
                    .foregroundColor(feedback.passed ? .green : .red)
            }
            
            if showsMissedTaskProtocol {
                missedTaskProtocolView
            }
        }
        .onAppear {
            evaluateProgressRule()
        }
    }
    
    func updateValue(_ newValue: Any) {
        // For composite metrics, we don't update a single value
        // Instead, we update the individual components
    }
    
    func createTaskInstance(for task: Task, on date: Date) -> TaskInstance? {
        guard let progressRule = progressRule else { return nil }
        
        let status: TaskInstanceStatus = progressRuleFeedback?.passed == true ? .passed : .blocked
        let blockReason: BlockReason? = status == .blocked ? .progressRuleFailed : nil
        let notes: String? = status == .blocked ? "Progress rule failed: \(progressRuleFeedback?.message ?? "")" : nil
        
        return TaskInstance(
            taskId: task.id.uuidString,
            programId: "default-program-id", // This would need to be passed in
            date: date,
            status: status,
            blockReason: blockReason,
            notes: notes
        )
    }
    
    func createEvaluationContext() -> ProgramMetricContext? {
        return nil
    }
    
    private func evaluateProgressRule() {
        guard let progressRule = progressRule else {
            progressRuleFeedback = nil
            canCheckOff = true
            checkOffButtonState = .enabled
            showsMissedTaskProtocol = false
            return
        }
        
        let passed = evaluateRule(progressRule, currentValue: currentValue)
        
        progressRuleFeedback = ProgressRuleFeedback(
            passed: passed,
            message: passed ? "Rule passed" : "Rule failed",
            status: passed ? .passed : .failed
        )
        
        canCheckOff = passed
        checkOffButtonState = passed ? .enabled : .disabled
        showsMissedTaskProtocol = !passed
        
        if showsMissedTaskProtocol {
            missedTaskProtocolView = AnyView(
                MissedTaskProtocolView(
                    task: Task(id: UUID(), title: metricName, taskType: .growth),
                    onDismiss: { showsMissedTaskProtocol = false }
                )
            )
        }
    }
    
    private func evaluateRule(_ rule: ProgressRule, currentValue: Double) -> Bool {
        switch rule {
        case .threshold(let metricAlias, let comparator, let target):
            switch comparator {
            case ">=": return currentValue >= target
            case "<=": return currentValue <= target
            case "==": return currentValue == target
            case "!=": return currentValue != target
            default: return false
            }
        case .deltaThreshold(let minimumImprovement):
            return currentValue >= minimumImprovement
        case .countMin(let minimumCount):
            return currentValue >= Double(minimumCount)
        case .booleanCondition(let condition):
            return condition.lowercased() == "true" ? currentValue > 0 : currentValue == 0
        case .rollingWindow(let targetCount, _):
            return currentValue >= Double(targetCount)
        }
    }
    
    private func evaluateRuleWithRealEvaluator(_ rule: ProgressRule, currentValue: Double) -> Bool {
        // Create a measurement from the current value
        let currentMeasurement = Measurement(
            metricId: metric.id,
            value: currentValue,
            source: .manual
        )
        
        // Create a mock context for evaluation
        let context = ProgramMetricContext(
            programMetric: ProgramMetric(programId: "default-program", metricId: metric.id, comparisonMode: .relative),
            metric: metric,
            measurements: [], // Will be populated with real data in integration
            programStartDate: Date(),
            currentDate: Date()
        )
        
        // Evaluate the progress rule using the real evaluator
        let result = ProgressRuleEvaluator.evaluate(
            progressRule: rule,
            context: context,
            currentMeasurement: currentMeasurement
        )
        
        return result.passed
    }
}

// MARK: - Missed Task Protocol View (Placeholder)

struct MissedTaskProtocolView: View {
    let task: Task
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Missed Task Protocol")
                .font(.headline)
                .foregroundColor(.red)
            
            Text("Why did you miss this task?")
                .font(.subheadline)
            
            TextField("Reflection...", text: .constant(""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                Button("Dismiss") {
                    onDismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Apply Kaizen") {
                    onDismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Task Row with Metric Input

struct TaskRow: View {
    let task: Task
    let metricInputView: AnyView
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(task.title)
                    .font(.headline)
                Spacer()
                if task.requiresPhoto {
                    Image(systemName: "camera")
                        .foregroundColor(.blue)
                }
            }
            
            if let description = task.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            metricInputView
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Task Instance Storage (Placeholder)

class TaskInstanceStorage {
    func save(_ taskInstance: TaskInstance) {
        // Placeholder implementation
    }
    
    func load(for taskId: UUID, on date: Date) -> TaskInstance? {
        // Placeholder implementation
        return nil
    }
}