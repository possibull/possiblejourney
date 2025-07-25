import Foundation

class DailyProgressStorage {
    private let keyPrefix = "dailyProgress_"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func save(progress: DailyProgress) {
        let key = keyPrefix + Self.dateString(progress.date)
        if let data = try? encoder.encode(progress) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func load(for date: Date) -> DailyProgress? {
        let key = keyPrefix + Self.dateString(date)
        guard let data = UserDefaults.standard.data(forKey: key),
              let progress = try? decoder.decode(DailyProgress.self, from: data) else {
            return nil
        }
        return progress
    }
    
    func clearAll() {
        let defaults = UserDefaults.standard
        for (key, _) in defaults.dictionaryRepresentation() {
            if key.hasPrefix(keyPrefix) {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    // MARK: - Missed Day Persistence
    private let missedDayKey = "earliestMissedDay"
    
    func setEarliestMissedDay(_ date: Date?) {
        let defaults = UserDefaults.standard
        if let date = date {
            let iso = ISO8601DateFormatter().string(from: date)
            defaults.set(iso, forKey: missedDayKey)
        } else {
            defaults.removeObject(forKey: missedDayKey)
        }
    }
    
    func getEarliestMissedDay() -> Date? {
        let defaults = UserDefaults.standard
        guard let iso = defaults.string(forKey: missedDayKey) else { return nil }
        return ISO8601DateFormatter().date(from: iso)
    }
    
    func clearEarliestMissedDay() {
        UserDefaults.standard.removeObject(forKey: missedDayKey)
    }
    
    private static func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
} 