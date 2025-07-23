import Foundation

struct ProgramStorage {
    private let key = "SavedProgram"
    
    func save(_ program: Program) {
        if let data = try? JSONEncoder().encode(program) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func load() -> Program? {
        print("DEBUG: ProgramStorage.load() called")
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(Program.self, from: data)
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
} 