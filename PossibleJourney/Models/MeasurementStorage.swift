import Foundation
import Combine

class MeasurementStorage: ObservableObject {
    @Published var measurements: [Measurement] {
        didSet {
            saveMeasurements()
        }
    }
    
    private let userDefaultsKey = "measurements"

    init() {
        if let savedMeasurementsData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedMeasurements = try? JSONDecoder().decode([Measurement].self, from: savedMeasurementsData) {
            self.measurements = decodedMeasurements
        } else {
            self.measurements = []
        }
    }

    private func saveMeasurements() {
        if let encodedMeasurements = try? JSONEncoder().encode(measurements) {
            UserDefaults.standard.set(encodedMeasurements, forKey: userDefaultsKey)
        }
    }

    // MARK: - CRUD Operations
    func addMeasurement(_ measurement: Measurement) {
        measurements.append(measurement)
    }

    func updateMeasurement(_ measurement: Measurement) {
        if let index = measurements.firstIndex(where: { $0.id == measurement.id }) {
            measurements[index] = measurement
        }
    }

    func deleteMeasurement(id: String) {
        measurements.removeAll { $0.id == id }
    }
    
    func getMeasurement(by id: String) -> Measurement? {
        measurements.first { $0.id == id }
    }

    // MARK: - Query Methods
    func getMeasurements(for metricId: String) -> [Measurement] {
        measurements.filter { $0.metricId == metricId }
            .sorted { $0.timestamp < $1.timestamp }
    }
    
    func getMeasurements(for metricId: String, from startDate: Date, to endDate: Date) -> [Measurement] {
        getMeasurements(for: metricId).filter { measurement in
            measurement.timestamp >= startDate && measurement.timestamp <= endDate
        }
    }
    
    func getLatestMeasurement(for metricId: String) -> Measurement? {
        getMeasurements(for: metricId).last
    }
    
    func getMeasurementsForDate(_ date: Date, metricId: String) -> [Measurement] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return getMeasurements(for: metricId, from: startOfDay, to: endOfDay)
    }
    
    func getRollingSum(for metricId: String, days: Int, from date: Date) -> Double {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days + 1, to: date)!
        let endDate = calendar.date(byAdding: .day, value: 1, to: date)!
        
        let relevantMeasurements = getMeasurements(for: metricId, from: startDate, to: endDate)
        return relevantMeasurements.reduce(0) { $0 + $1.value }
    }
    
    func getRollingAverage(for metricId: String, days: Int, from date: Date) -> Double {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days + 1, to: date)!
        let endDate = calendar.date(byAdding: .day, value: 1, to: date)!
        
        let relevantMeasurements = getMeasurements(for: metricId, from: startDate, to: endDate)
        guard !relevantMeasurements.isEmpty else { return 0 }
        
        let sum = relevantMeasurements.reduce(0) { $0 + $1.value }
        return sum / Double(relevantMeasurements.count)
    }
}
