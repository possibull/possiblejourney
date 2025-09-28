//
//  Measurement.swift
//  PossibleJourney
//
//  Created by Ted Possible on 9/27/25.
//

import Foundation

// MARK: - Measurement Source Enum
enum MeasurementSource: String, Codable, CaseIterable, Equatable {
    case manual = "manual"
    case import_health = "import_health"
    case import_garmin = "import_garmin"
    case import_oura = "import_oura"
    case import_strava = "import_strava"
    
    var displayName: String {
        switch self {
        case .manual:
            return "Manual Entry"
        case .import_health:
            return "Apple Health"
        case .import_garmin:
            return "Garmin"
        case .import_oura:
            return "Oura"
        case .import_strava:
            return "Strava"
        }
    }
}

// MARK: - Measurement Model
struct Measurement: Codable, Identifiable, Equatable {
    let id: String
    let metricId: String
    let timestamp: Date
    let value: Double
    let booleanValue: Bool? // For boolean metrics like "phone in bedroom"
    let compositeValue: [String: Double]? // For composite metrics like weight + reps
    let source: MeasurementSource
    let notes: String?
    
    init(
        id: String = UUID().uuidString,
        metricId: String,
        timestamp: Date = Date(),
        value: Double,
        booleanValue: Bool? = nil,
        compositeValue: [String: Double]? = nil,
        source: MeasurementSource = .manual,
        notes: String? = nil
    ) {
        self.id = id
        self.metricId = metricId
        self.timestamp = timestamp
        self.value = value
        self.booleanValue = booleanValue
        self.compositeValue = compositeValue
        self.source = source
        self.notes = notes
    }
    
    // MARK: - Computed Properties
    var formattedValue: String {
        // This will be enhanced based on the metric's unit
        return String(format: "%.1f", value)
    }
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

// MARK: - Composite Measurement (for strength training, etc.)
struct CompositeMeasurement: Codable, Identifiable, Equatable {
    let id: String
    let metricId: String
    let timestamp: Date
    let primaryValue: Double
    let secondaryValue: Double
    let source: MeasurementSource
    let notes: String?
    
    init(
        id: String = UUID().uuidString,
        metricId: String,
        timestamp: Date = Date(),
        primaryValue: Double,
        secondaryValue: Double,
        source: MeasurementSource = .manual,
        notes: String? = nil
    ) {
        self.id = id
        self.metricId = metricId
        self.timestamp = timestamp
        self.primaryValue = primaryValue
        self.secondaryValue = secondaryValue
        self.source = source
        self.notes = notes
    }
    
    // MARK: - Computed Properties
    var volume: Double {
        return primaryValue * secondaryValue
    }
    
    var formattedPrimary: String {
        return String(format: "%.1f", primaryValue)
    }
    
    var formattedSecondary: String {
        return String(format: "%.0f", secondaryValue)
    }
    
    var formattedVolume: String {
        return String(format: "%.1f", volume)
    }
}
