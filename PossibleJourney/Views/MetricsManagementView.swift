//
//  MetricsManagementView.swift
//  PossibleJourney
//
//  Created by Ted Possible on 9/28/25.
//

import SwiftUI

struct MetricsManagementView: View {
    @ObservedObject var metricStorage: MetricStorage
    @Environment(\.dismiss) private var dismiss
    @State private var showingCreateMetric = false
    @State private var showingArchived = false
    
    var body: some View {
        NavigationView {
            List {
                // Active Metrics Section
                Section(header: Text("Active Metrics")) {
                    ForEach(metricStorage.getActiveMetrics()) { metric in
                        MetricRowView(metric: metric, metricStorage: metricStorage)
                    }
                }
                
                // Archived Metrics Section (if any)
                if !metricStorage.getArchivedMetrics().isEmpty {
                    Section(header: Text("Archived Metrics")) {
                        ForEach(metricStorage.getArchivedMetrics()) { metric in
                            MetricRowView(metric: metric, metricStorage: metricStorage)
                        }
                    }
                }
                
                // Default Metrics Info
                Section(header: Text("Default Metrics"), footer: Text("These are the built-in metrics available in all programs. You can create custom metrics for specific needs.")) {
                    ForEach(Metric.defaultMetrics.prefix(5)) { metric in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(metric.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                if let description = metric.description, !description.isEmpty {
                                    Text(description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
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
                        .padding(.vertical, 2)
                    }
                    
                    if Metric.defaultMetrics.count > 5 {
                        Text("+ \(Metric.defaultMetrics.count - 5) more default metrics")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            }
            .navigationTitle("Metrics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateMetric = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateMetric) {
                MetricCreationView(
                    metricStorage: metricStorage,
                    onSave: { metric in
                        metricStorage.addMetric(metric)
                    }
                )
            }
        }
    }
}

struct MetricRowView: View {
    let metric: Metric
    @ObservedObject var metricStorage: MetricStorage
    @State private var showingEditSheet = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(metric.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(metric.archived ? .secondary : .primary)
                
                if let description = metric.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
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
                    
                    if !metric.unit.isEmpty {
                        Text(metric.unit)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            if metric.archived {
                Button("Restore") {
                    metricStorage.unarchiveMetric(metric)
                }
                .font(.caption)
                .foregroundColor(.blue)
            } else {
                Menu {
                    Button("Edit") {
                        showingEditSheet = true
                    }
                    
                    Button("Archive", role: .destructive) {
                        metricStorage.archiveMetric(metric)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
        .sheet(isPresented: $showingEditSheet) {
            MetricEditView(metric: metric, metricStorage: metricStorage)
        }
    }
}

struct MetricEditView: View {
    let metric: Metric
    @ObservedObject var metricStorage: MetricStorage
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var description: String
    @State private var unit: String
    @State private var direction: MetricDirection
    @State private var type: MetricType
    
    init(metric: Metric, metricStorage: MetricStorage) {
        self.metric = metric
        self.metricStorage = metricStorage
        self._name = State(initialValue: metric.name)
        self._description = State(initialValue: metric.description ?? "")
        self._unit = State(initialValue: metric.unit)
        self._direction = State(initialValue: metric.direction)
        self._type = State(initialValue: metric.type)
    }
    
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
            .navigationTitle("Edit Metric")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let updatedMetric = Metric(
                            id: metric.id,
                            name: name,
                            description: description.isEmpty ? nil : description,
                            unit: unit,
                            direction: direction,
                            type: type,
                            createdAt: metric.createdAt,
                            archived: metric.archived
                        )
                        metricStorage.updateMetric(updatedMetric)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    MetricsManagementView(metricStorage: MetricStorage())
}
