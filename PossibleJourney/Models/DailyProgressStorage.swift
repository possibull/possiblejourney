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
    
    private static func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
} 