//
//  MetricAutocompleteView.swift
//  PossibleJourney
//
//  Created by Ted Possible on 9/27/25.
//

import SwiftUI

struct MetricAutocompleteView: View {
    @ObservedObject var metricStorage: MetricStorage
    @Binding var selectedMetricId: String
    @Binding var selectedMetricName: String
    @State private var showingSuggestions = false
    var onTapToCreate: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("e.g., Sleep Hours, Weight, Steps", text: $selectedMetricName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.caption)
                .onChange(of: selectedMetricName) { _, newValue in
                    showingSuggestions = !newValue.isEmpty
                }
                .onTapGesture {
                    if selectedMetricName.isEmpty {
                        // If field is empty, show suggestions or trigger create
                        if metricStorage.getActiveMetrics().isEmpty {
                            onTapToCreate?()
                        } else {
                            showingSuggestions = true
                        }
                    } else {
                        showingSuggestions = true
                    }
                }
            
            // Autocomplete suggestions
            if showingSuggestions {
                VStack(alignment: .leading, spacing: 2) {
                    // Create new metric option
                    Button(action: {
                        onTapToCreate?()
                        showingSuggestions = false
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                                .font(.caption)
                            Text("Create new metric...")
                                .font(.caption)
                                .foregroundColor(.accentColor)
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Existing metrics
                    ForEach(filteredMetrics.prefix(5), id: \.id) { metric in
                        Button(action: {
                            selectMetric(metric)
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(metric.name)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                    Text(metric.fullDescription)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 2)
                .padding(.top, 2)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var filteredMetrics: [Metric] {
        if selectedMetricName.isEmpty {
            return metricStorage.getActiveMetrics()
        } else {
            return metricStorage.searchMetrics(query: selectedMetricName)
        }
    }
    
    // MARK: - Helper Methods
    private func selectMetric(_ metric: Metric) {
        selectedMetricName = metric.name
        selectedMetricId = metric.id
        showingSuggestions = false
    }
}
