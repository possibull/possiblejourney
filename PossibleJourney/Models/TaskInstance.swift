//
//  TaskInstance.swift
//  PossibleJourney
//
//  Created by Ted Possible on 9/27/25.
//

import Foundation

// MARK: - Task Instance Status Enum
enum TaskInstanceStatus: String, Codable, CaseIterable, Equatable {
    case pending = "pending"          // Not yet attempted
    case passed = "passed"            // Completed successfully
    case blocked = "blocked"          // Failed progress rule
    case skipped = "skipped"          // Manually skipped
    case maintenance = "maintenance"  // Maintenance task (always passes)
    case recovery = "recovery"        // Recovery task (warning on miss)
    
    var displayName: String {
        switch self {
        case .pending:
            return "Pending"
        case .passed:
            return "Completed"
        case .blocked:
            return "Blocked"
        case .skipped:
            return "Skipped"
        case .maintenance:
            return "Maintenance"
        case .recovery:
            return "Recovery"
        }
    }
    
    var isCompleted: Bool {
        return self == .passed || self == .maintenance
    }
    
    var isBlocked: Bool {
        return self == .blocked
    }
    
    var requiresAction: Bool {
        return self == .pending || self == .blocked
    }
}

// MARK: - Block Reason Enum
enum BlockReason: String, Codable, CaseIterable, Equatable {
    case progressRuleFailed = "progress_rule_failed"
    case noMeasurement = "no_measurement"
    case insufficientImprovement = "insufficient_improvement"
    case belowMinimum = "below_minimum"
    case conditionNotMet = "condition_not_met"
    case rollingWindowFailed = "rolling_window_failed"
    
    var displayName: String {
        switch self {
        case .progressRuleFailed:
            return "Progress Rule Failed"
        case .noMeasurement:
            return "No Measurement"
        case .insufficientImprovement:
            return "Insufficient Improvement"
        case .belowMinimum:
            return "Below Minimum"
        case .conditionNotMet:
            return "Condition Not Met"
        case .rollingWindowFailed:
            return "Rolling Window Failed"
        }
    }
    
    var description: String {
        switch self {
        case .progressRuleFailed:
            return "The progress rule for this task was not met"
        case .noMeasurement:
            return "No measurement was recorded for the linked metric"
        case .insufficientImprovement:
            return "The improvement was below the required threshold"
        case .belowMinimum:
            return "The value was below the minimum required"
        case .conditionNotMet:
            return "The boolean condition was not satisfied"
        case .rollingWindowFailed:
            return "The rolling window target was not achieved"
        }
    }
}

// MARK: - TaskInstance Model
struct TaskInstance: Codable, Identifiable, Equatable {
    let id: String
    let taskId: String
    let programId: String
    let date: Date
    let status: TaskInstanceStatus
    let blockReason: BlockReason?
    let measurementId: String?
    let completedAt: Date?
    let notes: String?
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        taskId: String,
        programId: String,
        date: Date,
        status: TaskInstanceStatus = .pending,
        blockReason: BlockReason? = nil,
        measurementId: String? = nil,
        completedAt: Date? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.taskId = taskId
        self.programId = programId
        self.date = date
        self.status = status
        self.blockReason = blockReason
        self.measurementId = measurementId
        self.completedAt = completedAt
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    var isCompleted: Bool {
        return status.isCompleted
    }
    
    var isBlocked: Bool {
        return status.isBlocked
    }
    
    var requiresAction: Bool {
        return status.requiresAction
    }
    
    var statusColor: String {
        switch status {
        case .pending:
            return "gray"
        case .passed, .maintenance:
            return "green"
        case .blocked:
            return "red"
        case .skipped:
            return "orange"
        case .recovery:
            return "blue"
        }
    }
    
    var statusIcon: String {
        switch status {
        case .pending:
            return "circle"
        case .passed, .maintenance:
            return "checkmark.circle.fill"
        case .blocked:
            return "xmark.circle.fill"
        case .skipped:
            return "minus.circle.fill"
        case .recovery:
            return "heart.circle.fill"
        }
    }
}

// MARK: - TaskInstance Factory
extension TaskInstance {
    static func createPending(
        taskId: String,
        programId: String,
        date: Date
    ) -> TaskInstance {
        return TaskInstance(
            taskId: taskId,
            programId: programId,
            date: date,
            status: .pending
        )
    }
    
    static func createPassed(
        taskId: String,
        programId: String,
        date: Date,
        measurementId: String? = nil,
        notes: String? = nil
    ) -> TaskInstance {
        return TaskInstance(
            taskId: taskId,
            programId: programId,
            date: date,
            status: .passed,
            measurementId: measurementId,
            completedAt: Date(),
            notes: notes
        )
    }
    
    static func createBlocked(
        taskId: String,
        programId: String,
        date: Date,
        blockReason: BlockReason,
        notes: String? = nil
    ) -> TaskInstance {
        return TaskInstance(
            taskId: taskId,
            programId: programId,
            date: date,
            status: .blocked,
            blockReason: blockReason,
            notes: notes
        )
    }
    
    static func createSkipped(
        taskId: String,
        programId: String,
        date: Date,
        notes: String? = nil
    ) -> TaskInstance {
        return TaskInstance(
            taskId: taskId,
            programId: programId,
            date: date,
            status: .skipped,
            notes: notes
        )
    }
}
