//
//  MetricStorage.swift
//  PossibleJourney
//
//  Created by Ted Possible on 9/27/25.
//

import Foundation

class MetricStorage: ObservableObject {
    @Published var metrics: [Metric] = []
    
    private let userDefaults = UserDefaults.standard
    private let metricsKey = "saved_metrics"
    
    init() {
        loadMetrics()
    }
    
    // MARK: - CRUD Operations
    
    func addMetric(_ metric: Metric) {
        metrics.append(metric)
        saveMetrics()
    }
    
    func updateMetric(_ metric: Metric) {
        if let index = metrics.firstIndex(where: { $0.id == metric.id }) {
            metrics[index] = metric
            saveMetrics()
        }
    }
    
    func deleteMetric(_ metric: Metric) {
        metrics.removeAll { $0.id == metric.id }
        saveMetrics()
    }
    
    func archiveMetric(_ metric: Metric) {
        if let index = metrics.firstIndex(where: { $0.id == metric.id }) {
            metrics[index].archived = true
            saveMetrics()
        }
    }
    
    func unarchiveMetric(_ metric: Metric) {
        if let index = metrics.firstIndex(where: { $0.id == metric.id }) {
            metrics[index].archived = false
            saveMetrics()
        }
    }
    
    // MARK: - Query Methods
    
    func getActiveMetrics() -> [Metric] {
        return metrics.filter { !$0.archived }
    }
    
    func getArchivedMetrics() -> [Metric] {
        return metrics.filter { $0.archived }
    }
    
    func getMetric(by id: String) -> Metric? {
        return metrics.first { $0.id == id }
    }
    
    func getMetricsByType(_ type: MetricType) -> [Metric] {
        return getActiveMetrics().filter { $0.type == type }
    }
    
    func getMetricsByDirection(_ direction: MetricDirection) -> [Metric] {
        return getActiveMetrics().filter { $0.direction == direction }
    }
    
    // MARK: - Persistence
    
    private func saveMetrics() {
        do {
            let data = try JSONEncoder().encode(metrics)
            userDefaults.set(data, forKey: metricsKey)
        } catch {
            print("Failed to save metrics: \(error)")
        }
    }
    
    private func loadMetrics() {
        guard let data = userDefaults.data(forKey: metricsKey) else {
            // First time setup - load default metrics
            print("📊 MetricStorage: No metrics found in UserDefaults, loading default metrics")
            loadDefaultMetrics()
            return
        }
        
        do {
            metrics = try JSONDecoder().decode([Metric].self, from: data)
            print("📊 MetricStorage: Loaded \(metrics.count) metrics from UserDefaults")
        } catch {
            print("Failed to load metrics: \(error)")
            // Fallback to default metrics if loading fails
            loadDefaultMetrics()
        }
    }
    
    private func loadDefaultMetrics() {
        metrics = Metric.defaultMetrics
        print("📊 MetricStorage: Loaded \(metrics.count) default metrics: \(metrics.map { $0.name })")
        saveMetrics()
    }
    
    // MARK: - Utility Methods
    
    func resetToDefaults() {
        metrics = Metric.defaultMetrics
        saveMetrics()
    }
    
    func duplicateMetric(_ metric: Metric) -> Metric {
        let newMetric = Metric(
            name: "\(metric.name) Copy",
            description: metric.description,
            unit: metric.unit,
            direction: metric.direction,
            type: metric.type
        )
        addMetric(newMetric)
        return newMetric
    }
    
    func searchMetrics(query: String) -> [Metric] {
        let activeMetrics = getActiveMetrics()
        guard !query.isEmpty else { return activeMetrics }
        
        return activeMetrics.filter { metric in
            metric.name.localizedCaseInsensitiveContains(query) ||
            metric.description?.localizedCaseInsensitiveContains(query) == true ||
            metric.unit.localizedCaseInsensitiveContains(query)
        }
    }
}
