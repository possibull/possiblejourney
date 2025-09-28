//
//  ProgramMetric.swift
//  PossibleJourney
//
//  Created by Ted Possible on 9/27/25.
//

import Foundation

// MARK: - Comparison Mode Enum
enum ComparisonMode: String, Codable, CaseIterable, Equatable {
    case absolute = "absolute"        // Compare against fixed baseline
    case relative = "relative"        // Compare against previous measurement
    case rolling = "rolling"          // Compare against rolling average
    case programStart = "program_start" // Compare against program start value
    
    var displayName: String {
        switch self {
        case .absolute:
            return "Fixed Baseline"
        case .relative:
            return "Previous Value"
        case .rolling:
            return "Rolling Average"
        case .programStart:
            return "Program Start"
        }
    }
}

// MARK: - ProgramMetric Model
struct ProgramMetric: Codable, Identifiable, Equatable {
    let id: String
    let programId: String
    let metricId: String
    let baseline: Double?
    let comparisonMode: ComparisonMode
    let windowDays: Int
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        programId: String,
        metricId: String,
        baseline: Double? = nil,
        comparisonMode: ComparisonMode = .relative,
        windowDays: Int = 7,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.programId = programId
        self.metricId = metricId
        self.baseline = baseline
        self.comparisonMode = comparisonMode
        self.windowDays = windowDays
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    var effectiveBaseline: Double {
        return baseline ?? 0.0
    }
    
    var windowDescription: String {
        if windowDays == 1 {
            return "Daily"
        } else {
            return "\(windowDays) days"
        }
    }
}

// MARK: - ProgramMetric Context (for evaluation)
struct ProgramMetricContext {
    let programMetric: ProgramMetric
    let metric: Metric
    let measurements: [Measurement]
    let programStartDate: Date
    let currentDate: Date
    
    // MARK: - Computed Properties
    var latestMeasurement: Measurement? {
        return measurements.max(by: { $0.timestamp < $1.timestamp })
    }
    
    var baselineMeasurement: Measurement? {
        switch programMetric.comparisonMode {
        case .absolute:
            return measurements.first { $0.timestamp <= programStartDate }
        case .relative:
            return measurements.dropLast().last
        case .rolling:
            let cutoff = currentDate.addingTimeInterval(-TimeInterval(programMetric.windowDays * 24 * 60 * 60))
            return measurements.filter { $0.timestamp >= cutoff }.first
        case .programStart:
            return measurements.first { $0.timestamp >= programStartDate }
        }
    }
    
    var rollingAverage: Double? {
        guard programMetric.comparisonMode == .rolling else { return nil }
        let cutoff = currentDate.addingTimeInterval(-TimeInterval(programMetric.windowDays * 24 * 60 * 60))
        let recentMeasurements = measurements.filter { $0.timestamp >= cutoff }
        guard !recentMeasurements.isEmpty else { return nil }
        return recentMeasurements.map { $0.value }.reduce(0, +) / Double(recentMeasurements.count)
    }
    
    var comparisonValue: Double? {
        switch programMetric.comparisonMode {
        case .absolute:
            return programMetric.effectiveBaseline
        case .relative:
            return latestMeasurement?.value
        case .rolling:
            return rollingAverage
        case .programStart:
            return baselineMeasurement?.value
        }
    }
}
