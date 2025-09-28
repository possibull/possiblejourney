//
//  TaskRuleBuilderView.swift
//  PossibleJourney
//
//  Created by Ted Possible on 9/28/25.
//

import SwiftUI

struct TaskRuleBuilderView: View {
    @ObservedObject var metricStorage: MetricStorage
    @Binding var progressRule: ProgressRule?
    
    // Form state
    @State private var selectedMetricId: String = ""
    @State private var selectedMetricName: String = ""
    @State private var selectedMetricType: MetricType = .number
    @State private var selectedMetricUnit: String = ""
    @State private var selectedComparator: String = ">="
    @State private var targetValue: String = ""
    @State private var targetBoolean: Bool = false
    
    // UI state
    @State private var showingMetricCreation = false
    @State private var showingMetricPicker = false
    @State private var isLoadingExistingRule = false
    
    // Available comparators based on metric type
    private var availableComparators: [(String, String)] {
        switch selectedMetricType {
        case .number, .count:
            return [(">=", "≥"), ("<=", "≤")]
        case .boolean:
            return [("==", "="), ("!=", "≠")]
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            Text("Progress Rule")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Rule Type (read-only for MVP)
            VStack(alignment: .leading, spacing: 4) {
                Text("Rule Type")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Threshold")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Linked Metric
            VStack(alignment: .leading, spacing: 4) {
                Text("Linked Metric")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    MetricAutocompleteView(
                        metricStorage: metricStorage,
                        selectedMetricId: $selectedMetricId,
                        selectedMetricName: $selectedMetricName
                    )
                    
                    Button(action: {
                        showingMetricCreation = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            
            // Comparator and Target (only show if metric is selected)
            if !selectedMetricId.isEmpty {
                HStack(spacing: 12) {
                    // Comparator
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Comparator")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("Comparator", selection: $selectedComparator) {
                            ForEach(availableComparators, id: \.0) { value, display in
                                Text(display).tag(value)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Target
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Target")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if selectedMetricType == .boolean {
                            Toggle("", isOn: $targetBoolean)
                                .labelsHidden()
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        } else {
                            HStack {
                                TextField("0", text: $targetValue)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(PlainTextFieldStyle())
                                
                                if !selectedMetricUnit.isEmpty {
                                    Text(selectedMetricUnit)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            
            // Live Preview
            if !selectedMetricId.isEmpty && !selectedMetricName.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Preview")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("Pass if:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(previewText)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .onAppear {
            loadExistingRule()
        }
        .onChange(of: selectedMetricId) { _, newValue in
            if !isLoadingExistingRule && !newValue.isEmpty {
                updateMetricInfo()
                updateRule()
            }
        }
        .onChange(of: selectedComparator) { _, newValue in
            print("🔍 TaskRuleBuilderView: selectedComparator onChange triggered - newValue: '\(newValue)', isLoadingExistingRule: \(isLoadingExistingRule)")
            if !isLoadingExistingRule {
                updateRule()
            }
        }
        .onChange(of: targetValue) { _, newValue in
            print("🔍 TaskRuleBuilderView: targetValue onChange triggered - newValue: '\(newValue)', isLoadingExistingRule: \(isLoadingExistingRule)")
            if !isLoadingExistingRule {
                updateRule()
            }
        }
        .onChange(of: targetBoolean) { _, _ in
            if !isLoadingExistingRule {
                updateRule()
            }
        }
        .sheet(isPresented: $showingMetricCreation) {
            MetricCreationView(metricStorage: metricStorage) { newMetric in
                selectedMetricId = newMetric.id
                selectedMetricName = newMetric.name
                selectedMetricType = newMetric.type
                selectedMetricUnit = newMetric.unit
            }
        }
        .sheet(isPresented: $showingMetricPicker) {
            MetricPickerView(metricStorage: metricStorage) { selectedMetric in
                selectedMetricId = selectedMetric.id
                selectedMetricName = selectedMetric.name
                selectedMetricType = selectedMetric.type
                selectedMetricUnit = selectedMetric.unit
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var previewText: String {
        if selectedMetricName.isEmpty {
            return ""
        }
        
        var target: String
        if selectedMetricType == .boolean {
            target = targetBoolean ? "true" : "false"
        } else {
            target = targetValue.isEmpty ? "0" : targetValue
            if !selectedMetricUnit.isEmpty {
                target = "\(target) \(selectedMetricUnit)"
            }
        }
        
        let comparatorDisplay = availableComparators.first { $0.0 == selectedComparator }?.1 ?? selectedComparator
        
        return "\(selectedMetricName) \(comparatorDisplay) \(target)"
    }
    
    // MARK: - Helper Methods
    
    private func loadExistingRule() {
        isLoadingExistingRule = true
        
        print("🔍 TaskRuleBuilderView: loadExistingRule() called")
        print("🔍 TaskRuleBuilderView: progressRule = \(String(describing: progressRule))")
        
        if case .threshold(let metricAlias, let comparator, let target) = progressRule {
            print("🔍 TaskRuleBuilderView: Found threshold rule - alias: '\(metricAlias)', comparator: '\(comparator)', target: \(target)")
            
            // Find metric by alias (name)
            if let metric = metricStorage.metrics.first(where: { $0.name.lowercased() == metricAlias.lowercased() }) {
                print("🔍 TaskRuleBuilderView: Found matching metric: \(metric.name)")
                selectedMetricId = metric.id
                selectedMetricName = metric.name
                selectedMetricType = metric.type
                selectedMetricUnit = metric.unit
                selectedComparator = comparator
                
                if metric.type == .boolean {
                    targetBoolean = target > 0
                } else {
                    targetValue = String(target)
                }
                
                print("🔍 TaskRuleBuilderView: Set selectedMetricName = '\(selectedMetricName)'")
                print("🔍 TaskRuleBuilderView: Set selectedComparator = '\(selectedComparator)'")
                print("🔍 TaskRuleBuilderView: Set targetValue = '\(targetValue)'")
                print("🔍 TaskRuleBuilderView: Set targetBoolean = \(targetBoolean)")
                print("🔍 TaskRuleBuilderView: isLoadingExistingRule = \(isLoadingExistingRule)")
            } else {
                print("❌ TaskRuleBuilderView: No metric found for alias: '\(metricAlias)'")
            }
        } else {
            print("❌ TaskRuleBuilderView: progressRule is not a threshold rule")
        }
        
        isLoadingExistingRule = false
    }
    
    private func updateMetricInfo() {
        if let metric = metricStorage.getMetric(by: selectedMetricId) {
            selectedMetricName = metric.name
            selectedMetricType = metric.type
            selectedMetricUnit = metric.unit
            
            // Only set defaults if we're not loading an existing rule
            if !isLoadingExistingRule {
                // Set default comparator based on type
                if metric.type == .boolean {
                    selectedComparator = "=="
                } else {
                    selectedComparator = ">="
                }
                
                // Set sensible defaults for common metrics
                switch metric.name {
                case "Pages Read":
                    targetValue = "10"
                case "Workout Duration":
                    targetValue = "45"
                case "Water Gallons":
                    targetValue = "1"
                case "Diet Compliance", "Alcohol Abstinence":
                    targetBoolean = true
                default:
                    targetValue = ""
                    targetBoolean = false
                }
            }
        }
    }
    
    private func updateRule() {
        guard !selectedMetricId.isEmpty && !selectedMetricName.isEmpty else {
            progressRule = nil
            return
        }
        
        let target: Double
        if selectedMetricType == .boolean {
            target = targetBoolean ? 1.0 : 0.0
        } else {
            target = Double(targetValue) ?? 0.0
        }
        
        let newRule = ProgressRule.threshold(
            metricAlias: selectedMetricName,
            comparator: selectedComparator,
            target: target
        )
        
        print("🔍 TaskRuleBuilderView: updateRule() called")
        print("🔍 TaskRuleBuilderView: selectedMetricName = '\(selectedMetricName)'")
        print("🔍 TaskRuleBuilderView: selectedComparator = '\(selectedComparator)'")
        print("🔍 TaskRuleBuilderView: target = \(target)")
        print("🔍 TaskRuleBuilderView: newRule = \(newRule)")
        
        progressRule = newRule
    }
}

// MARK: - Metric Creation View

struct MetricCreationView: View {
    @ObservedObject var metricStorage: MetricStorage
    let onSave: (Metric) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var unit: String = ""
    @State private var direction: MetricDirection = .increase
    @State private var type: MetricType = .number
    
    var body: some View {
        NavigationView {
            Form {
                Section("Metric Details") {
                    TextField("Name", text: $name)
                    TextField("Description (optional)", text: $description)
                    TextField("Unit (optional)", text: $unit)
                }
                
                Section("Type") {
                    Picker("Type", selection: $type) {
                        ForEach(MetricType.allCases, id: \.self) { metricType in
                            Text(metricType.displayName).tag(metricType)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Direction") {
                    Picker("Direction", selection: $direction) {
                        ForEach(MetricDirection.allCases, id: \.self) { direction in
                            Text(direction.displayName).tag(direction)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Create Metric")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newMetric = Metric(
                            name: name,
                            description: description.isEmpty ? nil : description,
                            unit: unit,
                            direction: direction,
                            type: type
                        )
                        metricStorage.addMetric(newMetric)
                        onSave(newMetric)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Metric Picker View

struct MetricPickerView: View {
    @ObservedObject var metricStorage: MetricStorage
    let onSelect: (Metric) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText: String = ""
    
    private var filteredMetrics: [Metric] {
        if searchText.isEmpty {
            return metricStorage.metrics.filter { !$0.archived }
        } else {
            return metricStorage.metrics.filter { 
                !$0.archived && $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredMetrics) { metric in
                Button(action: {
                    onSelect(metric)
                    dismiss()
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(metric.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let description = metric.description, !description.isEmpty {
                            Text(description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text(metric.type.displayName)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(4)
                            
                            Text(metric.direction.displayName)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .searchable(text: $searchText, prompt: "Search metrics...")
            .navigationTitle("Select Metric")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TaskRuleBuilderView(
        metricStorage: MetricStorage(),
        progressRule: .constant(nil)
    )
    .padding()
}
