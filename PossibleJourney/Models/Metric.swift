//
//  Metric.swift
//  PossibleJourney
//
//  Created by Ted Possible on 9/27/25.
//

import Foundation

// MARK: - Metric Direction Enum
enum MetricDirection: String, Codable, CaseIterable, Equatable {
    case increase = "increase"
    case decrease = "decrease"
    
    var displayName: String {
        switch self {
        case .increase:
            return "Higher is Better"
        case .decrease:
            return "Lower is Better"
        }
    }
}

// MARK: - Metric Type Enum
enum MetricType: String, Codable, CaseIterable, Equatable {
    case number = "number"
    case boolean = "boolean"
    case count = "count"
    
    var displayName: String {
        switch self {
        case .number:
            return "Number"
        case .boolean:
            return "Boolean (Yes/No)"
        case .count:
            return "Count"
        }
    }
}

// MARK: - Metric Model
struct Metric: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var description: String?
    var unit: String
    var direction: MetricDirection
    var type: MetricType
    let createdAt: Date
    var archived: Bool
    
    init(
        id: String = UUID().uuidString,
        name: String,
        description: String? = nil,
        unit: String,
        direction: MetricDirection,
        type: MetricType,
        createdAt: Date = Date(),
        archived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.unit = unit
        self.direction = direction
        self.type = type
        self.createdAt = createdAt
        self.archived = archived
    }
    
    // MARK: - Computed Properties
    var displayName: String {
        if unit.isEmpty {
            return name
        } else {
            return "\(name) (\(unit))"
        }
    }
    
    var fullDescription: String {
        var desc = "\(name)"
        if !unit.isEmpty {
            desc += " (\(unit))"
        }
        if let description = description, !description.isEmpty {
            desc += " - \(description)"
        }
        desc += " - \(direction.displayName)"
        return desc
    }
}

// MARK: - Default Metrics
extension Metric {
    static let defaultMetrics: [Metric] = [
        Metric(
            name: "Sleep Hours",
            description: "Hours of sleep per night",
            unit: "hrs",
            direction: .increase,
            type: .number
        ),
        Metric(
            name: "Weight",
            description: "Body weight",
            unit: "lbs",
            direction: .decrease,
            type: .number
        ),
        Metric(
            name: "Steps",
            description: "Daily step count",
            unit: "steps",
            direction: .increase,
            type: .count
        ),
        Metric(
            name: "Water Intake",
            description: "Daily water consumption",
            unit: "oz",
            direction: .increase,
            type: .number
        ),
        Metric(
            name: "Exercise Completed",
            description: "Whether exercise was completed",
            unit: "",
            direction: .increase,
            type: .boolean
        ),
        Metric(
            name: "Meditation Minutes",
            description: "Minutes spent meditating",
            unit: "min",
            direction: .increase,
            type: .number
        ),
        Metric(
            name: "Books Read",
            description: "Number of books completed",
            unit: "books",
            direction: .increase,
            type: .count
        ),
        Metric(
            name: "Social Connections",
            description: "Number of meaningful social interactions",
            unit: "connections",
            direction: .increase,
            type: .count
        ),
        
        // 75 Hard specific metrics
        Metric(
            name: "Pages Read",
            description: "Number of pages read from non-fiction book",
            unit: "pages",
            direction: .increase,
            type: .count
        ),
        Metric(
            name: "Workout Duration",
            description: "Duration of workout in minutes",
            unit: "min",
            direction: .increase,
            type: .number
        ),
        Metric(
            name: "Water Gallons",
            description: "Amount of water consumed in gallons",
            unit: "gal",
            direction: .increase,
            type: .number
        ),
        Metric(
            name: "Diet Compliance",
            description: "Whether diet was followed with no cheat meals",
            unit: "",
            direction: .increase,
            type: .boolean
        ),
        Metric(
            name: "Alcohol Abstinence",
            description: "Whether alcohol was completely avoided",
            unit: "",
            direction: .increase,
            type: .boolean
        )
    ]
}
