//
//  ProgressRuleEvaluator.swift
//  PossibleJourney
//
//  Created by Ted Possible on 9/27/25.
//

import Foundation

// MARK: - Evaluation Result
struct ProgressRuleEvaluationResult {
    let passed: Bool
    let blockReason: BlockReason?
    let currentValue: Double?
    let comparisonValue: Double?
    let improvement: Double?
    let message: String
    
    init(
        passed: Bool,
        blockReason: BlockReason? = nil,
        currentValue: Double? = nil,
        comparisonValue: Double? = nil,
        improvement: Double? = nil,
        message: String
    ) {
        self.passed = passed
        self.blockReason = blockReason
        self.currentValue = currentValue
        self.comparisonValue = comparisonValue
        self.improvement = improvement
        self.message = message
    }
}

// MARK: - Progress Rule Evaluator
class ProgressRuleEvaluator {
    
    // MARK: - Main Evaluation Method
    static func evaluate(
        progressRule: ProgressRule,
        context: ProgramMetricContext,
        currentMeasurement: Measurement?
    ) -> ProgressRuleEvaluationResult {
        
        guard let currentMeasurement = currentMeasurement else {
            return ProgressRuleEvaluationResult(
                passed: false,
                blockReason: .noMeasurement,
                message: "No measurement recorded for today"
            )
        }
        
        switch progressRule {
        case .deltaThreshold(let minimumImprovement):
            return evaluateDeltaThreshold(
                minimumImprovement: minimumImprovement,
                context: context,
                currentMeasurement: currentMeasurement
            )
            
        case .countMin(let minimumCount):
            return evaluateCountMin(
                minimumCount: minimumCount,
                context: context,
                currentMeasurement: currentMeasurement
            )
            
        case .booleanCondition(let condition):
            return evaluateBooleanCondition(
                condition: condition,
                context: context,
                currentMeasurement: currentMeasurement
            )
            
        case .rollingWindow(let targetCount, let windowDays):
            return evaluateRollingWindow(
                targetCount: targetCount,
                windowDays: windowDays,
                context: context,
                currentMeasurement: currentMeasurement
            )
            
        case .threshold(let metricAlias, let comparator, let target):
            return evaluateThreshold(
                metricAlias: metricAlias,
                comparator: comparator,
                target: target,
                context: context,
                currentMeasurement: currentMeasurement
            )
        }
    }
    
    // MARK: - Delta Threshold Evaluation
    private static func evaluateDeltaThreshold(
        minimumImprovement: Double,
        context: ProgramMetricContext,
        currentMeasurement: Measurement
    ) -> ProgressRuleEvaluationResult {
        
        // Handle composite metrics (like strength training with weight + reps)
        if let compositeValue = currentMeasurement.compositeValue {
            return evaluateCompositeDeltaThreshold(
                compositeValue: compositeValue,
                minimumImprovement: minimumImprovement,
                context: context,
                currentMeasurement: currentMeasurement
            )
        }
        
        // Handle simple numeric metrics
        guard let comparisonValue = context.comparisonValue else {
            return ProgressRuleEvaluationResult(
                passed: false,
                blockReason: .noMeasurement,
                currentValue: currentMeasurement.value,
                message: "No comparison value available"
            )
        }
        
        let improvement = currentMeasurement.value - comparisonValue
        let passed = improvement >= minimumImprovement
        
        let message = passed 
            ? "Improved by \(String(format: "%.1f", improvement)) (required: \(String(format: "%.1f", minimumImprovement)))"
            : "Improvement of \(String(format: "%.1f", improvement)) below required \(String(format: "%.1f", minimumImprovement))"
        
        return ProgressRuleEvaluationResult(
            passed: passed,
            blockReason: passed ? nil : .insufficientImprovement,
            currentValue: currentMeasurement.value,
            comparisonValue: comparisonValue,
            improvement: improvement,
            message: message
        )
    }
    
    // MARK: - Composite Delta Threshold Evaluation (Strength Training)
    private static func evaluateCompositeDeltaThreshold(
        compositeValue: [String: Double],
        minimumImprovement: Double,
        context: ProgramMetricContext,
        currentMeasurement: Measurement
    ) -> ProgressRuleEvaluationResult {
        
        // For strength training: pass if reps >= lastReps+1 OR weight >= lastWeight+2.5
        guard let currentWeight = compositeValue["weight"], let currentReps = compositeValue["reps"] else {
            return ProgressRuleEvaluationResult(
                passed: false,
                blockReason: .conditionNotMet,
                currentValue: currentMeasurement.value,
                message: "Missing weight or reps data"
            )
        }
        
        // Find the last measurement for comparison
        let historicalMeasurements = context.measurements.filter { $0.timestamp < currentMeasurement.timestamp }
        guard let lastMeasurement = historicalMeasurements.last,
              let lastComposite = lastMeasurement.compositeValue,
              let lastWeight = lastComposite["weight"],
              let lastReps = lastComposite["reps"] else {
            return ProgressRuleEvaluationResult(
                passed: false,
                blockReason: .noMeasurement,
                currentValue: currentMeasurement.value,
                message: "No previous session to compare against"
            )
        }
        
        // Check OR condition: reps improvement OR weight improvement
        let repsImproved = currentReps >= lastReps + 1
        let weightImproved = currentWeight >= lastWeight + 2.5
        
        let passed = repsImproved || weightImproved
        
        let message: String
        if passed {
            if repsImproved && weightImproved {
                message = "Great! Improved both reps (\(String(format: "%.0f", currentReps)) vs \(String(format: "%.0f", lastReps))) and weight (\(String(format: "%.1f", currentWeight)) vs \(String(format: "%.1f", lastWeight)) lbs)."
            } else if repsImproved {
                message = "Reps improved! \(String(format: "%.0f", currentReps)) vs \(String(format: "%.0f", lastReps)) reps."
            } else {
                message = "Weight improved! \(String(format: "%.1f", currentWeight)) vs \(String(format: "%.1f", lastWeight)) lbs."
            }
        } else {
            message = "Need to improve: reps by +1 (currently \(String(format: "%.0f", currentReps)) vs \(String(format: "%.0f", lastReps))) OR weight by +2.5 lbs (currently \(String(format: "%.1f", currentWeight)) vs \(String(format: "%.1f", lastWeight)))."
        }
        
        return ProgressRuleEvaluationResult(
            passed: passed,
            blockReason: passed ? nil : .insufficientImprovement,
            currentValue: currentMeasurement.value,
            comparisonValue: lastWeight * lastReps, // Volume comparison
            improvement: (currentWeight * currentReps) - (lastWeight * lastReps),
            message: message
        )
    }
    
    // MARK: - Count Minimum Evaluation
    private static func evaluateCountMin(
        minimumCount: Int,
        context: ProgramMetricContext,
        currentMeasurement: Measurement
    ) -> ProgressRuleEvaluationResult {
        
        let currentCount = Int(currentMeasurement.value)
        let passed = currentCount >= minimumCount
        
        let message = passed
            ? "Completed \(currentCount) (required: \(minimumCount))"
            : "Completed \(currentCount), need at least \(minimumCount)"
        
        return ProgressRuleEvaluationResult(
            passed: passed,
            blockReason: passed ? nil : .belowMinimum,
            currentValue: currentMeasurement.value,
            message: message
        )
    }
    
    // MARK: - Boolean Condition Evaluation
    private static func evaluateBooleanCondition(
        condition: String,
        context: ProgramMetricContext,
        currentMeasurement: Measurement
    ) -> ProgressRuleEvaluationResult {
        
        // Handle complex boolean conditions with multiple metrics
        // Example: "sleep_hours >= 7 && phone_in_room == false && screen_free_mins >= 30"
        if condition.contains("&&") {
            return evaluateComplexBooleanCondition(
                condition: condition,
                context: context,
                currentMeasurement: currentMeasurement
            )
        }
        
        // Simple boolean evaluation for single conditions
        let value = currentMeasurement.value
        let passed: Bool
        
        switch condition.lowercased() {
        case "true", "yes", "1":
            passed = value > 0
        case "false", "no", "0":
            passed = value == 0
        default:
            // Try to parse as a comparison
            if condition.contains(">=") {
                let parts = condition.components(separatedBy: ">=")
                if parts.count == 2, let threshold = Double(parts[1].trimmingCharacters(in: .whitespaces)) {
                    passed = value >= threshold
                } else {
                    passed = false
                }
            } else if condition.contains("<=") {
                let parts = condition.components(separatedBy: "<=")
                if parts.count == 2, let threshold = Double(parts[1].trimmingCharacters(in: .whitespaces)) {
                    passed = value <= threshold
                } else {
                    passed = false
                }
            } else if condition.contains(">") {
                let parts = condition.components(separatedBy: ">")
                if parts.count == 2, let threshold = Double(parts[1].trimmingCharacters(in: .whitespaces)) {
                    passed = value > threshold
                } else {
                    passed = false
                }
            } else if condition.contains("<") {
                let parts = condition.components(separatedBy: "<")
                if parts.count == 2, let threshold = Double(parts[1].trimmingCharacters(in: .whitespaces)) {
                    passed = value < threshold
                } else {
                    passed = false
                }
            } else {
                passed = false
            }
        }
        
        let message = passed
            ? "Condition '\(condition)' satisfied (value: \(String(format: "%.1f", value)))"
            : "Condition '\(condition)' not satisfied (value: \(String(format: "%.1f", value)))"
        
        return ProgressRuleEvaluationResult(
            passed: passed,
            blockReason: passed ? nil : .conditionNotMet,
            currentValue: currentMeasurement.value,
            message: message
        )
    }
    
    // MARK: - Complex Boolean Condition Evaluation
    private static func evaluateComplexBooleanCondition(
        condition: String,
        context: ProgramMetricContext,
        currentMeasurement: Measurement
    ) -> ProgressRuleEvaluationResult {
        
        // Parse complex conditions like "sleep_hours >= 7 && phone_in_room == false && screen_free_mins >= 30"
        let conditionParts = condition.components(separatedBy: "&&")
        var allConditionsMet = true
        var conditionMessages: [String] = []
        
        for part in conditionParts {
            let trimmedPart = part.trimmingCharacters(in: .whitespaces)
            let (met, message) = evaluateSingleCondition(trimmedPart, context: context, currentMeasurement: currentMeasurement)
            allConditionsMet = allConditionsMet && met
            conditionMessages.append(message)
        }
        
        let overallMessage = allConditionsMet ? 
            "All conditions met: \(conditionMessages.joined(separator: ", "))" :
            "Conditions not met: \(conditionMessages.joined(separator: ", "))"
        
        return ProgressRuleEvaluationResult(
            passed: allConditionsMet,
            blockReason: allConditionsMet ? nil : .conditionNotMet,
            currentValue: currentMeasurement.value,
            message: overallMessage
        )
    }
    
    // MARK: - Single Condition Evaluation Helper
    private static func evaluateSingleCondition(
        _ condition: String,
        context: ProgramMetricContext,
        currentMeasurement: Measurement
    ) -> (Bool, String) {
        
        // Handle different condition types
        if condition.contains(">=") {
            let parts = condition.components(separatedBy: ">=")
            guard parts.count == 2 else { return (false, "Invalid condition format") }
            
            let metricName = parts[0].trimmingCharacters(in: .whitespaces)
            let threshold = Double(parts[1].trimmingCharacters(in: .whitespaces)) ?? 0
            
            // Get the metric value from current measurement or composite
            let value = getMetricValue(metricName: metricName, context: context, currentMeasurement: currentMeasurement)
            
            let met = value >= threshold
            let message = "\(metricName) \(met ? "≥" : "<") \(threshold) (current: \(String(format: "%.1f", value)))"
            return (met, message)
        }
        
        if condition.contains("==") {
            let parts = condition.components(separatedBy: "==")
            guard parts.count == 2 else { return (false, "Invalid condition format") }
            
            let metricName = parts[0].trimmingCharacters(in: .whitespaces)
            let expectedValue = parts[1].trimmingCharacters(in: .whitespaces)
            
            // Handle boolean comparisons
            if expectedValue.lowercased() == "true" || expectedValue.lowercased() == "false" {
                let boolValue = getBooleanMetricValue(metricName: metricName, context: context, currentMeasurement: currentMeasurement)
                let expectedBool = expectedValue.lowercased() == "true"
                let met = boolValue == expectedBool
                let message = "\(metricName) \(met ? "==" : "!=") \(expectedValue) (current: \(boolValue))"
                return (met, message)
            }
        }
        
        return (false, "Unsupported condition: \(condition)")
    }
    
    // MARK: - Metric Value Helpers
    private static func getMetricValue(
        metricName: String,
        context: ProgramMetricContext,
        currentMeasurement: Measurement
    ) -> Double {
        
        // Check if it's a composite metric
        if let compositeValue = currentMeasurement.compositeValue,
           let value = compositeValue[metricName] {
            return value
        }
        
        // Check if the metric name matches the current metric
        if context.metric.name.lowercased().contains(metricName.lowercased()) {
            return currentMeasurement.value
        }
        
        // For now, return the current measurement value
        // In a real implementation, you'd look up related metrics
        return currentMeasurement.value
    }
    
    private static func getBooleanMetricValue(
        metricName: String,
        context: ProgramMetricContext,
        currentMeasurement: Measurement
    ) -> Bool {
        
        // For boolean conditions, we might need to look at multiple measurements
        // For now, return the boolean value from the current measurement
        return currentMeasurement.booleanValue ?? false
    }
    
    // MARK: - Rolling Window Evaluation
    private static func evaluateRollingWindow(
        targetCount: Int,
        windowDays: Int,
        context: ProgramMetricContext,
        currentMeasurement: Measurement
    ) -> ProgressRuleEvaluationResult {
        
        let cutoff = currentMeasurement.timestamp.addingTimeInterval(-TimeInterval(windowDays * 24 * 60 * 60))
        let recentMeasurements = context.measurements.filter { $0.timestamp >= cutoff }
        
        // For connections example: sum(connections, last 7 days) >= 5
        // We need to sum the values, not count the measurements
        let rollingSum = recentMeasurements.reduce(0) { $0 + $1.value }
        let passed = rollingSum >= Double(targetCount)
        
        let message = passed
            ? "Rolling sum over \(windowDays) days is \(String(format: "%.1f", rollingSum)) (required: \(targetCount))"
            : "Rolling sum over \(windowDays) days is \(String(format: "%.1f", rollingSum)), need \(targetCount)"
        
        return ProgressRuleEvaluationResult(
            passed: passed,
            blockReason: passed ? nil : .rollingWindowFailed,
            currentValue: rollingSum,
            message: message
        )
    }
    
    // MARK: - Threshold Evaluation (75 Hard Style)
    private static func evaluateThreshold(
        metricAlias: String,
        comparator: String,
        target: Double,
        context: ProgramMetricContext,
        currentMeasurement: Measurement
    ) -> ProgressRuleEvaluationResult {
        
        let currentValue = currentMeasurement.value
        let passed: Bool
        
        switch comparator {
        case ">=":
            passed = currentValue >= target
        case "<=":
            passed = currentValue <= target
        case "==":
            passed = currentValue == target
        case "!=":
            passed = currentValue != target
        default:
            passed = false
        }
        
        let message = passed
            ? "\(metricAlias) \(comparator) \(String(format: "%.1f", target)) ✓ (current: \(String(format: "%.1f", currentValue)))"
            : "\(metricAlias) \(comparator) \(String(format: "%.1f", target)) ✗ (current: \(String(format: "%.1f", currentValue)))"
        
        return ProgressRuleEvaluationResult(
            passed: passed,
            blockReason: passed ? nil : .belowMinimum,
            currentValue: currentValue,
            comparisonValue: target,
            message: message
        )
    }
}
