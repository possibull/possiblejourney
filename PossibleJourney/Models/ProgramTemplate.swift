//
//  ProgramTemplate.swift
//  PossibleJourney
//
//  Created by Ted Possible on 7/22/25.
//

import Foundation

struct ProgramTemplate: Codable, Identifiable {
    let id: UUID
    var name: String
    var description: String
    var category: TemplateCategory
    var defaultNumberOfDays: Int
    var tasks: [Task]
    let isDefault: Bool
    var lastModified: Date
    
    init(id: UUID = UUID(), name: String, description: String, category: TemplateCategory, defaultNumberOfDays: Int, tasks: [Task], isDefault: Bool = false, lastModified: Date = Date()) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.defaultNumberOfDays = defaultNumberOfDays
        self.tasks = tasks
        self.isDefault = isDefault
        self.lastModified = lastModified
    }
}

enum TemplateCategory: String, Codable, CaseIterable {
    case health = "Health & Fitness"
    case productivity = "Productivity"
    case learning = "Learning & Skills"
    case mindfulness = "Mindfulness"
    case relationships = "Relationships"
    case finance = "Finance"
    case custom = "Custom"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .health:
            return "heart.fill"
        case .productivity:
            return "bolt.fill"
        case .learning:
            return "book.fill"
        case .mindfulness:
            return "brain.head.profile"
        case .relationships:
            return "person.2.fill"
        case .finance:
            return "dollarsign.circle.fill"
        case .custom:
            return "plus.circle.fill"
        }
    }
}

extension ProgramTemplate {
    /// Creates a Program from this template
    func createProgram(startDate: Date? = nil, endOfDayTime: Date? = nil, numberOfDays: Int? = nil) -> Program {
        return Program(
            id: UUID(),
            startDate: startDate ?? Date(),
            endOfDayTime: endOfDayTime ?? Calendar.current.startOfDay(for: Date()),
            lastCompletedDay: nil,
            templateID: id,
            customNumberOfDays: numberOfDays
        )
    }
} 